import Kitura
import Foundation
import KituraStencil
import Stencil

public struct IbisRouter {
  public static func create() -> Router {

    let router = Router()
    router.setDefault(templateEngine: StencilTemplateEngine())

    router.all("/static", middleware: StaticFileServer())

    RouteIndex.setup(router: router)
    RouteApp.setup(router: router)

    return router
  }
}
