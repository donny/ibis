import Kitura
import HeliumLogger
import Foundation
import SwiftRedis
import SwiftyJSON


import KituraStencil // required for using StencilTemplateEngine
import Stencil // required for adding a Stencil namespace to StencilTemplateEngine


// Initialize HeliumLogger
HeliumLogger.use()

// Create a new router
let router = Router()

// Create a new cache
let cache = Cache(callback: { (error: NSError?) in
  if let error = error {
    print(error)
  }
})


// add Stencil Template Engine with a namespace with a custom tag
let namespace = Namespace()
router.add(templateEngine: StencilTemplateEngine(namespace: namespace))


// Handle HTTP GET requests to /
router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    next()
}

router.get("/articles") {
  request, response, next in
    defer {
        next()
    }
    do {
        // the example from https://github.com/kylef/Stencil
        let context: [String: Any] = [
            "articles": [
                [ "title": "Migrating from OCUnit to XCTest", "author": "Kyle Fuller" ],
                [ "title": "Memory Management with ARC", "author": "Kyle Fuller" ],
            ]
        ]

        // we have to specify file extension here since Stencil is not the default engine
        try response.render("document.stencil", context: context).end()
    } catch {
        print("Failed to render template \(error)")
    }
}



let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8090") ?? 8090

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: port, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
