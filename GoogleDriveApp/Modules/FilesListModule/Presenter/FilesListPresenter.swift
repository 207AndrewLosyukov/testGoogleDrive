import UIKit

class FilesListPresenter {

    var filesModels: [FileModel] = []

    let googleService: GoogleDriveServiceProtocol
    let networkService: NetworkServiceProtocol

    var token: String? = ""

    weak var viewInput: FilesListInput?

    init(serviceAssembly: FilesListServiceAssembly) {
        googleService = serviceAssembly.googleDriveService
        networkService = serviceAssembly.networkService
    }
}

extension FilesListPresenter: FilesListOutput {

    func refreshFiles(text: String?) {
        token = ""
        fetchFromDrive(replaceOldFiles: true, searchText: text == "" ? nil : text)
    }

    func fetchFromDrive(replaceOldFiles: Bool, searchText: String?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.googleService.fetchAllFiles(searchText, token: self?.token ?? "") { [weak self] (files, pageToken, error) in
                if let arrFiles = files {
                    let filesModels = arrFiles.map { fileModel in
                            FileModel(name: fileModel.name, size: fileModel.size?.doubleValue, modifiedTime: fileModel.modifiedTime?.date, fileExtension: fileModel.fileExtension, mimeType: fileModel.mimeType, iconLink: fileModel.iconLink, thumbnailLink: fileModel.thumbnailLink, hasThumbnail: fileModel.hasThumbnail)
                    }
                    pageToken != nil && !replaceOldFiles ? (self?.filesModels += filesModels) : (self?.filesModels = filesModels)
                    self?.token = pageToken
                    DispatchQueue.main.async {
                        self?.viewInput?.reloadData()
                        self?.viewInput?.setLoading(animated: false)
                        self?.viewInput?.stopRefreshControl()
                    }
                } else {
                    // очень редкая ошибка при огромном количестве запросов в один момент с разными токенами, описание от гугла отсутствует, не нарушает работоспособность
                    if error?.localizedDescription != "Invalid Value" {
                        DispatchQueue.main.async {
                            self?.viewInput?.showAlert(title: error?.localizedDescription)
                        }
                    }
                }
            }
        }
    }

    func search(text: String?) {
        token = ""
        fetchFromDrive(replaceOldFiles: true, searchText: text == "" ? nil : text)
    }

    func configureCell(cell: FileCell, at indexPathRow: Int, searchText: String?) {
        cell.configureCell(filesModels[indexPathRow])
        if filesModels[indexPathRow].hasThumbnail == true {
            if let stringUrl = filesModels[indexPathRow].thumbnailLink {
                setupImage(cell: cell, with: stringUrl)
            }
        } else {
            if let stringUrl = filesModels[indexPathRow].iconLink {
                setupImage(cell: cell, with: stringUrl)
            }
        }
        if indexPathRow == filesModels.count - 1 && (searchText == nil || searchText == "") {
            fetchFromDrive(replaceOldFiles: false, searchText: nil)
        }
    }

    func openDetails(at indexPathRow: Int) {
        let viewController = DetailsViewController(file: filesModels[indexPathRow], networkService: networkService)
        viewInput?.openDetailsViewController(viewController)
    }

    private func setupImage(cell: FileCell, with string: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let url = URL(string: string) else { return }
            self?.networkService.fetchData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    cell.fileImageView.image = UIImage(data: data)
                }
            }
        }
    }
}
