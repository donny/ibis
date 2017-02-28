import Kitura
import HeliumLogger
import Foundation
import SwiftRedis
import SwiftyJSON

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

// Handle HTTP GET requests to /
router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    next()
}

let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8090") ?? 8090

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: port, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
