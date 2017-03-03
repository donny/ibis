import Foundation
import Kitura
import SwiftRedis
import SwiftyJSON
import RestKit
import Dispatch

public struct RouteApp {
  private static let cache = Cache(callback: { (error: NSError?) in
    if let error = error {
      print(error)
    }
  })

  private static let analyzer = Analyzer()

  private static let whitelisted = ["404667893", "319908646","1004229463", "474698182", "499208265"]

  private static func render(response: RouterResponse, name: String, context: [String: Any]) {
    do {
      try response.render(name, context: context).end()
    } catch {
      print("Failed to render template \(error)")
    }
  }

  private static func transformReview(json: JSON) -> [String: Any] {
    var revDict: [String: Any] = [:]
    revDict["title"] = json["title"]["label"].stringValue
    revDict["version"] = json["im:version"]["label"].stringValue
    revDict["rating"] = json["im:rating"]["label"].stringValue
    revDict["content"] = json["content"]["label"].stringValue
    revDict["author"] = json["author"]["name"]["label"].stringValue
    revDict["analysis"] = [String: String]()
    return revDict
  }

  public static func setup(router: Router) -> Void {

    router.get("/app/:id") {request, response, next in
      defer {
        next()
      }

      guard let appId = request.parameters["id"] else { return }
      if !whitelisted.contains(appId) {
        let context: [String: Any] = ["appId": appId]
        render(response: response, name: "app-error", context: context)
        return
      }

      let url = "https://itunes.apple.com/au/rss/customerreviews/id=\(appId)/sortBy=mostRecent/json"

      // Construct request
      let jsonType = "application/json"
      let request = RestRequest(method: .GET, url: url, acceptType: jsonType, contentType: jsonType)

      // Execute request
      request.responseJSON { reqResponse in
        switch reqResponse {

        case .failure(let error):

          let context: [String: Any] = ["appId": appId, "error": error]
          render(response: response, name: "app-error", context: context)

        case .success(let json):

          var reviews = json["feed"]["entry"].arrayValue
          reviews.remove(at: 0) // The first entry is not a review
          reviews = Array(reviews.prefix(3)) // We only get the first 5

          var reviewsDict = reviews.map({ transformReview(json: $0) })

          // Construct dispatch queue and group
          let queue: DispatchQueue = DispatchQueue.global(qos: .default)
          let group: DispatchGroup = DispatchGroup()

          // It's in this for-loop style because we would like to modify reviewsDict
          for index in 0..<reviewsDict.count {
            let review = reviewsDict[index]
            let key = "\(appId)-\(review["author"])-\(review["version"])"

            // Start of the group task
            group.enter()
            queue.async {
              guard let text = review["content"] as? String else {
                group.leave()
                return
              }

              // Check the cache
              cache.get(key) { (results: [String: String], redisError: NSError?) in
                if let _ = redisError {
                  group.leave()
                  return
                }

                // Use the cache
                if !results.isEmpty {
                  reviewsDict[index]["analysis"] = results
                  group.leave()
                } else {
                  // Get the tone analysis
                  analyzer.getTone(text: text, failure: { error in
                    group.leave()
                  }, success: { toneAnalysis in
                    reviewsDict[index]["analysis"] = toneAnalysis
                    // Save it to the cache
                    cache.set(key, dictionary: toneAnalysis) { _ in group.leave() }
                  })
                }
              }
            }
            // End of the group task
          }

          group.wait()

          let context: [String: Any] = ["reviews": reviewsDict, "appId": appId]
          render(response: response, name: "app", context: context)
        }
      }
    }

  }
}
