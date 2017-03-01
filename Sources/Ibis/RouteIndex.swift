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
            [ "name": "Realestate", "id": "404667893" ],
            [ "name": "Domain", "id": "319908646" ],
            [ "name": "Homely", "id": "1004229463" ],
            [ "name": "realestateView", "id": "474698182" ],
            [ "name": "All Homes", "id": "499208265" ]
          ]
        ]

        try response.render("index", context: context).end()
      } catch {
        print("Failed to render template \(error)")
      }
    }
  }
}
