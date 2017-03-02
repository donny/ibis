import Foundation
import Kitura
import SwiftRedis
import SwiftyJSON
import RestKit
import Dispatch

public struct RouteApp {
  public static func setup(router: Router) -> Void {
    // Create a new cache
    let cache = Cache(callback: { (error: NSError?) in
      if let error = error {
        print(error)
      }
    })

    let analyzer = Analyzer()

    router.get("/app/:id") {request, response, next in
      defer {
        next()
      }

      guard let appId = request.parameters["id"] else { return }

      let url = "https://itunes.apple.com/au/rss/customerreviews/id=\(appId)/sortBy=mostRecent/json"

      // Construct request
      let request = RestRequest(
        method: .GET,
        url: url,
        acceptType: "application/json",
        contentType: "application/json"
      )

      // Execute request
      request.responseJSON { reqResponse in
        switch reqResponse {

        case .success(let json):

          var reviews = json["feed"]["entry"].arrayValue
          reviews.remove(at: 0) // The first entry is not a review
          reviews = Array(reviews.prefix(3))

          let reviewsDict = reviews.map({ review -> [String: String] in
              var revDict: [String: String] = [:]
              revDict["title"] = review["title"]["label"].stringValue
              revDict["version"] = review["im:version"]["label"].stringValue
              revDict["rating"] = review["im:rating"]["label"].stringValue
              revDict["content"] = review["content"]["label"].stringValue
              revDict["author"] = review["author"]["name"]["label"].stringValue
              return revDict
          })

          let queue: DispatchQueue = DispatchQueue.global(qos: .default)
          let group: DispatchGroup = DispatchGroup()

          reviewsDict.forEach { review in
            group.enter()
            queue.async {
              analyzer.getTone(text: review["content"] ?? "", failure: { error in
                print("ERROR")
                group.leave()
              }, success: { toneAnalysis in
                for toneCategory in toneAnalysis.documentTone {
                  print(toneCategory.name)
                  for tone in toneCategory.tones {
                    print("\(tone.name): \(tone.score)")
                  }
                  print("---")
                }
                group.leave()
              })
            }
          }

          group.wait()

          do {
            let context: [String: Any] = ["reviews": reviewsDict, "appId": appId]
            try response.render("app", context: context).end()
          } catch {
            print("Failed to render template \(error)")
          }

        case .failure(let error):

          do {
            let context: [String: Any] = ["appId": appId, "error": error]
            try response.render("app-error", context: context).end()
          } catch {
            print("Failed to render template \(error)")
          }

        }
      }
    }


  }
}
