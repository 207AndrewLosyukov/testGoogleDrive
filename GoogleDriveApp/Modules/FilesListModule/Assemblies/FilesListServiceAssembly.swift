import Foundation

final class FilesListServiceAssembly {

    let googleDriveService: GoogleDriveServiceProtocol
    let networkService: NetworkServiceProtocol

    init(googleDriveService: GoogleDriveServiceProtocol, networkService: NetworkServiceProtocol) {
        self.googleDriveService = googleDriveService
        self.networkService = networkService
    }
}
