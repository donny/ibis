import Kitura
import HeliumLogger
import Foundation
import SwiftRedis
import SwiftyJSON

// Initialize HeliumLogger
HeliumLogger.use()

// Create a new router
let router = Router()

// Redis
let redis = Redis()

let redisInfo = ProcessInfo.processInfo.environment["VCAP_SERVICES"] ?? "{}"
let redisInfoJson = JSON.parse(string: redisInfo)
let redisCreds = redisInfoJson["rediscloud"][0]["credentials"]

let rHost = redisCreds["hostname"].string ?? ""
let rPort = Int32(redisCreds["port"].string ?? "0") ?? 0
let rPassword = redisCreds["password"].string ?? ""


print("Redis \(rHost) \(rPort) \(rPassword)")


redis.connect(host: rHost, port: rPort) { (redisError: NSError?) in
    if let error = redisError {
        print("________")
        print(error)
    }
    else {
      print("________")
        print("Connected to Redis")
        // set a key

        redis.auth(rPassword) { (redisError: NSError?) in

          redis.set("Redis", value: "on Swift") { (result: Bool, redisError: NSError?) in
              if let error = redisError {
                  print(error)
              }
              // get the same key
              redis.get("Redis") { (string: RedisString?, redisError: NSError?) in
                  if let error = redisError {
                      print(error)
                  }
                  else if let string = string?.asString {
                      print("Redis \(string)")
                  }
              }
          }

        }
    }
}

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
