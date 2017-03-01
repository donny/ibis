import Kitura
import HeliumLogger
import Foundation

// Initialize HeliumLogger
HeliumLogger.use()

let router = IbisRouter.create()

let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "8090") ?? 8090

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: port, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
