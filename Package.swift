import PackageDescription

let package = Package(
    name: "ibis",
    dependencies: [
      .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 6),
      .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 1, minor: 6),
      .Package(url: "https://github.com/IBM-Swift/Kitura-redis.git", majorVersion: 1, minor: 6),
      .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", majorVersion: 15, minor: 0)
    ]
)
