import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

class MainViewController: UIViewController {

    private var signInButton = GIDSignInButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        signInButton.addAction(UIAction(handler: { [weak self] _ in
                    self?.setupGoogleSignIn()
                }), for: .touchUpInside)
    }

    private func setupGoogleSignIn() {
        signInButton.isUserInteractionEnabled = false
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                guard let self = self else { return }
                if user?.grantedScopes?.contains(kGTLRAuthScopeDrive) ?? false {
                    self.fetchFiles(user)
                } else {
                    user?.addScopes([kGTLRAuthScopeDrive], presenting: self) { result, error in
                        self.fetchFiles(user)
                    }
                }
                self.signInButton.isUserInteractionEnabled = true
            }
        } else {
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
                guard let self = self else { return }
                self.signInButton.isUserInteractionEnabled = true
                if let error {
                    print("Error", error)
                    return
                }
                guard let name = result?.user.profile?.name else {
                    print("Invalid user profile")
                    return
                }

                if result?.user.grantedScopes?.contains(kGTLRAuthScopeDrive) ?? false {
                    self.fetchFiles(result?.user)
                } else {
                    result?.user.addScopes([kGTLRAuthScopeDrive], presenting: self) { result, error in
                        self.fetchFiles(result?.user)
                    }
                }
            }
        }
    }

    func fetchFiles(_ user: GIDGoogleUser?) {
        guard let user = user else { return }

        let googleDriveService = GTLRDriveService()
        googleDriveService.authorizer = user.fetcherAuthorizer

        let serviceAssembly = FilesListServiceAssembly(googleDriveService: GoogleDriveService(googleDriveService), networkService: NetworkService())

        let filesListAssembly = FilesListAssembly(filesListServiceAssembly: serviceAssembly, userMail: user.profile?.email)

        let filesViewController = filesListAssembly.makeFilesListModule()

        navigationController?.pushViewController(filesViewController, animated: true)
    }

    func setupView() {
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
