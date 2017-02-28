import Kitura
import HeliumLogger
import Foundation
import SwiftRedis
import SwiftyJSON


import KituraStencil // required for using StencilTemplateEngine
import Stencil // required for adding a Stencil namespace to StencilTemplateEngine

import RestKit

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


router.setDefault(templateEngine: StencilTemplateEngine())
router.all("/static", middleware: StaticFileServer())

// Handle HTTP GET requests to /
router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    next()
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

        try response.render("document", context: context).end()
    } catch {
        print("Failed to render template \(error)")
    }
}



let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8090") ?? 8090

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: port, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
