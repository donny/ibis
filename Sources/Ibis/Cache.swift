import Foundation
import SwiftRedis
import SwiftyJSON
import HeliumLogger
import LoggerAPI

public class Cache {
  private let redis = Redis()
  private let redisHost: String
  private let redisPort: Int32
  private let redisPass: String

  private var logger = HeliumLogger()

  init(callback: (NSError?) -> Void) {
    let serviceInfo = ProcessInfo.processInfo.environment["VCAP_SERVICES"] ?? "{}"
    let serviceInfoJson = JSON.parse(string: serviceInfo)
    let serviceCreds = serviceInfoJson["rediscloud"][0]["credentials"]
    redisHost = serviceCreds["hostname"].string ?? ""
    redisPort = Int32(serviceCreds["port"].string ?? "0") ?? 0
    redisPass = serviceCreds["password"].string ?? ""

    logger.colored = true
    Log.logger = logger

    redis.connect(host: redisHost, port: redisPort) { (redisError: NSError?) in
      if let error = redisError {
        Log.error("redis.connect")
        callback(error)
        return
      }

      redis.auth(redisPass) { (redisError: NSError?) in
        if let error = redisError {
          Log.error("redis.auth")
          callback(error)
        } else {
          Log.info("Cache connected and authenticated")
          callback(nil)
        }
      }
    }
  }

  func set(_ key: String, dictionary: [String: String], callback: (Bool, NSError?) -> Void) -> Void {
    var pairs = [(String, String)]()
    for (key, value) in dictionary {
      let k = key.replacingOccurrences(of: " ", with: "").lowercased()
      pairs.append((k, value))
    }

    redis.hmsetArrayOfKeyValues(key, fieldValuePairs: pairs) { (result: Bool, redisError: NSError?) in
      if let error = redisError {
        Log.error("redis.hmsetArrayOfKeyValues")
        callback(false, error)
        return
      }

      callback(result, nil)
    }
  }

  func get(_ key: String, callback: ([String: String], NSError?) -> Void) -> Void {
    var keyValues = [String: String]()

    redis.hgetall(key) { (result: [String: RedisString], redisError: NSError?) in
      if let error = redisError {
        Log.error("redis.hgetall")
        callback([:], error)
        return
      }

      for (key, value) in result { keyValues[key] = value.asString }
      callback(keyValues, nil)
    }
  }
}
