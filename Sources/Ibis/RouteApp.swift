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

      do {
        let context: [String: Any] = [
          "apps": [
            [ "name": "Realestate", "id": "123" ],
            [ "name": "Domain", "id": "456" ]
          ],
          "id": appId
        ]

        try response.render("app", context: context).end()
      } catch {
        print("Failed to render template \(error)")
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
