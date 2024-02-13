import UIKit

class FilesListAssembly {

    private let serviceAssembly: FilesListServiceAssembly
    private let userMail: String?

    init(filesListServiceAssembly: FilesListServiceAssembly, userMail: String?) {
        self.serviceAssembly = filesListServiceAssembly
        self.userMail = userMail
    }

    func makeFilesListModule() -> UIViewController {
        let presenter = FilesListPresenter(serviceAssembly: serviceAssembly)
        let viewController = FilesListViewController(output: presenter, userMail: userMail)
        presenter.viewInput = viewController

        return viewController
    }
}

