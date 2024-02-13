import Foundation
import GoogleAPIClientForREST

protocol GoogleDriveServiceProtocol {

    func fetchAllFiles(_ fileName: String?, token: String?, onCompleted: @escaping ([GTLRDrive_File]?, String?, Error?) -> ())
}
