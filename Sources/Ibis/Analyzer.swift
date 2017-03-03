import Foundation
import ToneAnalyzer
import SwiftyJSON
import RestKit

public class Analyzer {
  private let toneAnalyzer: ToneAnalyzer
  private let username: String
  private let password: String
  private let version = "2016-05-19"

  init() {
    let serviceInfo = ProcessInfo.processInfo.environment["VCAP_SERVICES"] ?? "{}"
    let serviceInfoJson = JSON.parse(string: serviceInfo)
    let serviceCreds = serviceInfoJson["tone_analyzer"][0]["credentials"]
    username = serviceCreds["username"].string ?? ""
    password = serviceCreds["password"].string ?? ""

    toneAnalyzer = ToneAnalyzer(username: username, password: password, version: version)
  }

  func getTone(text: String, failure: ((RestError) -> Void)? = nil, success: @escaping ([String: String]) -> Void) {
    toneAnalyzer.getTone(text: text, failure: failure, success: { toneAnalysis in
      var toneDictionary = [String: String]()
      for toneCategory in toneAnalysis.documentTone {
        for tone in toneCategory.tones {
          toneDictionary[tone.name] = String(tone.score)
        }
      }
      success(toneDictionary)
    })
  }
}
