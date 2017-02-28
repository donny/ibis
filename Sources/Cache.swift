import Foundation
import SwiftRedis
import SwiftyJSON

public class Cache {
  private let redis = Redis()
  private let redisHost: String
  private let redisPort: Int32
  private let redisPass: String

  init(callback: (NSError?) -> Void) {
    let redisInfo = ProcessInfo.processInfo.environment["VCAP_SERVICES"] ?? "{}"
    let redisInfoJson = JSON.parse(string: redisInfo)
    let redisCreds = redisInfoJson["rediscloud"][0]["credentials"]
    redisHost = redisCreds["hostname"].string ?? ""
    redisPort = Int32(redisCreds["port"].string ?? "0") ?? 0
    redisPass = redisCreds["password"].string ?? ""


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
