import UIKit
import GoogleAPIClientForREST

final class FilesListViewController: UIViewController {

    enum Constants {
        static let googleDriveSize = 16.0
        static let googleDriveText = "Google Drive"
        static let userMailSize = 12.0
        static let constraintConstant = 20.0
        static let rowHeight = 85.0
        static let alertAnswer = "OK"
    }
    private var output: FilesListOutput

    private let refreshControl = UIRefreshControl()

    private let userMail: String?

    private lazy var googleDriveLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: Constants.googleDriveSize)
        label.text = Constants.googleDriveText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.isUserInteractionEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    var isDetailsOpenning = false

    init(output: FilesListOutput, userMail: String?) {
        self.output = output
        self.userMail = userMail
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        output.fetchFromDrive(replaceOldFiles: false, searchText: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDetailsOpenning = false
    }

    private func setupUI() {
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        searchBar.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        view.addSubview(googleDriveLabel)

        if userMail != nil {
            setupMailLabel()
        } else {
            googleDriveLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        }

        NSLayoutConstraint.activate([
            googleDriveLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.constraintConstant),
            googleDriveLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.constraintConstant),
        ])

        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: googleDriveLabel.bottomAnchor, constant: Constants.constraintConstant/2.0),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.constraintConstant),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.constraintConstant),
        ])
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        activityIndicator.startAnimating()

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FileCell.self, forCellReuseIdentifier: FileCell.Constants.reuseIdentifier)

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshFiles), for: .valueChanged)
    }

    private func setupMailLabel() {
        let userMailLabel = UILabel()
        userMailLabel.textAlignment = .center
        userMailLabel.text = userMail
        userMailLabel.font = UIFont.systemFont(ofSize: Constants.userMailSize)
        userMailLabel.textColor = .lightGray
        userMailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userMailLabel)
        NSLayoutConstraint.activate([
            userMailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            userMailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.constraintConstant),
            userMailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.constraintConstant),
            googleDriveLabel.topAnchor.constraint(equalTo: userMailLabel.bottomAnchor)
        ])
    }

    @objc func refreshFiles() {
        output.refreshFiles(text: searchBar.text)
    }
}

extension FilesListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.filesModels.count
     }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.Constants.reuseIdentifier, for: indexPath) as? FileCell else { return UITableViewCell()}
        cell.selectionStyle = .none
        output.configureCell(cell: cell, at: indexPath.row, searchText: searchBar.text)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isDetailsOpenning = true
        output.openDetails(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }
}


extension FilesListViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if !isDetailsOpenning {
            output.search(text: searchBar.text)
            searchBar.endEditing(true)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        output.search(text: searchBar.text)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        output.search(text: searchBar.text)
        searchBar.endEditing(true)
    }
}

extension FilesListViewController: FilesListInput {

    func openDetailsViewController(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }


    func stopRefreshControl() {
        refreshControl.endRefreshing()
    }

    func reloadData() {
        tableView.reloadData()
    }

    func setLoading(animated: Bool) {
        if animated {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func showAlert(title: String?) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.alertAnswer, style: .cancel) { _ in
            alert.dismiss(animated: true)
        })
        present(alert, animated: true) { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.refreshControl.endRefreshing()
        }
    }
}
