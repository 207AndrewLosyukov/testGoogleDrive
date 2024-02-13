import UIKit

protocol FilesListOutput {

    var filesModels: [FileModel] { get }

    func refreshFiles(text: String?)

    func fetchFromDrive(replaceOldFiles: Bool, searchText: String?)

    func configureCell(cell: FileCell, at indexPathRow: Int, searchText: String?)

    func search(text: String?)

    func openDetails(at indexPathRow: Int)

}
