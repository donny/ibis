import Foundation
import Kitura
import SwiftRedis
import SwiftyJSON
import RestKit

public struct RouteApp {
  public static func setup(router: Router) -> Void {
    // Create a new cache
    let cache = Cache(callback: { (error: NSError?) in
      if let error = error {
        print(error)
      }
    })

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

          let reviewsDict = reviews.map({ review -> [String: String] in
              var revDict: [String: String] = [:]
              revDict["title"] = review["title"]["label"].stringValue
              revDict["version"] = review["im:version"]["label"].stringValue
              revDict["rating"] = review["im:rating"]["label"].stringValue
              revDict["content"] = review["content"]["label"].stringValue
              revDict["author"] = review["author"]["name"]["label"].stringValue
              return revDict
          })

          do {
            let context: [String: Any] = ["reviews": reviewsDict, "appId": appId]
            try response.render("app", context: context).end()
          } catch {
            print("Failed to render template \(error)")
          }

        case .failure(let error):

          do {
            let context: [String: Any] = ["appId": appId]
            try response.render("app-error", context: context).end()
          } catch {
            print("Failed to render template \(error)")
          }

        }
      }
    }

    router.get("/analyzer") {
        request, response, next in

        let analyzer = Analyzer()
        let text = "Hello World How are you Today, I'm so mad"
        let failure = { (error: RestError) in print(error) }

        analyzer.getTone(text: text, failure: failure) { tones in
          print(tones)
        }


        response.send("Hello, World!")
        next()
    }
  }
}
