# ibis

Ibis displays tone analysis of iOS App Store reviews using [IBM Watson Tone Analyzer](https://www.ibm.com/watson/developercloud/tone-analyzer.html) and hosted on [IBM Bluemix](https://developer.ibm.com/swift/swift-on-ibm-cloud/).

### Background

This project is part of [52projects](https://donny.github.io/52projects/) and the new stuff that I learn through this project: [Kitura](https://developer.ibm.com/swift/kitura/), [IBM Bluemix](https://developer.ibm.com/swift/swift-on-ibm-cloud/), and [IBM Watson Tone Analyzer](https://www.ibm.com/watson/developercloud/tone-analyzer.html).

This project extends the [Gallinule](https://github.com/donny/gallinule) project by showing tone analysis of the App Store user reviews.

### Project

Ibis gets the App Store reviews from Apple iTunes site. It shows the top three reviews for a particular app and shows the tone analysis scores for three tone categories: [emotional, social, and language tones](https://www.ibm.com/watson/developercloud/doc/tone-analyzer/understand-tone.html). The screenshot of Ibis can be found below:

![Screenshot](https://raw.githubusercontent.com/donny/ibis/master/screenshot.png)

### Implementation

Ibis is implemented using the [Swift](https://swift.org) programming language and the [Kitura](https://developer.ibm.com/swift/kitura/) web framework. Each user review comes as a JSON data structure that is parsed using [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) and fed into the [IBM Watson Tone Analyzer](https://www.ibm.com/watson/developercloud/tone-analyzer.html).

The tone analysis for each user review is then cached on [Redis Cloud](https://console.ng.bluemix.net/catalog/services/redis-cloud) using the [Kitura Redis](https://github.com/IBM-Swift/Kitura-redis) library.

The web UI is built using the [Stencil Template Engine](https://stencil.fuller.li/en/latest/) and [Skeleton](http://getskeleton.com), a simple and responsive CSS boilerplate.

Take a look at the file [`RouteApp.swift`](https://github.com/donny/ibis/blob/master/Sources/Ibis/RouteApp.swift) for the main implementation of Ibis. As a note, we use `Dispatch Group` and `Dispatch Queue` to schedule tasks and to avoid *callback hell*.

### Conclusion

...
