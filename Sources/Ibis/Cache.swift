import Foundation
import SwiftRedis
import SwiftyJSON

public class Cache {
  private let redis = Redis()
  private let redisHost: String
  private let redisPort: Int32
  private let redisPass: String

  init(callback: (NSError?) -> Void) {
    let serviceInfo = ProcessInfo.processInfo.environment["VCAP_SERVICES"] ?? "{}"
    let serviceInfoJson = JSON.parse(string: redisInfo)
    let serviceCreds = redisInfoJson["rediscloud"][0]["credentials"]
    redisHost = serviceCreds["hostname"].string ?? ""
    redisPort = Int32(serviceCreds["port"].string ?? "0") ?? 0
    redisPass = serviceCreds["password"].string ?? ""

    redis.connect(host: redisHost, port: redisPort) { (redisError: NSError?) in
      if let error = redisError {
        callback(error)
        return
      }

      redis.auth(redisPass) { (redisError: NSError?) in
        if let error = redisError {
          callback(error)
        } else {
          callback(nil)
        }
      }
    }
  }
}
