import Foundation
import GoogleAPIClientForREST

class GoogleDriveService: GoogleDriveServiceProtocol {

    private let service: GTLRDriveService

    init(_ service: GTLRDriveService) {
        self.service = service
    }

    public func fetchAllFiles(_ fileName: String?, token: String?, onCompleted: @escaping ([GTLRDrive_File]?, String?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        if let fileName = fileName {
            let root = "(name contains '\(fileName)')"
            query.q = root
        }
        query.pageSize = 30
        query.pageToken = token
        query.fields = "files(id,name,mimeType,modifiedTime,fileExtension,size,iconLink,thumbnailLink, hasThumbnail),nextPageToken"
        service.executeQuery(query) { (ticket, results, error) in
            onCompleted((results as? GTLRDrive_FileList)?.files, (results as? GTLRDrive_FileList)?.nextPageToken, error)
        }
    }
}
