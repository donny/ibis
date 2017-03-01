import Kitura

public struct RouteIndex {
  public static func setup(router: Router) -> Void {
    router.get("/") {request, response, next in
      defer {
          next()
      }
      do {
        let context: [String: Any] = [
          "apps": [
            [ "name": "Realestate", "id": "123" ],
            [ "name": "Domain", "id": "456" ]
          ]
        ]

        try response.render("index", context: context).end()
      } catch {
        print("Failed to render template \(error)")
      }
    }
  }
}
