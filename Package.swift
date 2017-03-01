import PackageDescription

let package = Package(
    name: "ibis",
    targets: [
        Target(name: "RestKit"),
        Target(name: "ToneAnalyzer", dependencies: [.Target(name: "RestKit")]),
        Target(name: "Ibis", dependencies: [.Target(name: "ToneAnalyzer")])
    ],
    dependencies: [
      .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 6),
      .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 6),
      .Package(url: "https://github.com/IBM-Swift/Kitura-redis.git", majorVersion: 1, minor: 6),
      .Package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git", majorVersion: 1, minor: 6),
      .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 15, minor: 0)
    ]
)
