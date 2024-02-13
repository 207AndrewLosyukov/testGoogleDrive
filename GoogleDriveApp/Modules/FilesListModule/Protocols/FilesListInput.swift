import UIKit

protocol FilesListInput: AnyObject {

    func showAlert(title: String?)

    func reloadData()

    func setLoading(animated: Bool)
    
    func stopRefreshControl()

    func openDetailsViewController(_ viewController: UIViewController)
}
