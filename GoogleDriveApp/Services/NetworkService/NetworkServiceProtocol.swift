import Foundation

protocol NetworkServiceProtocol {

    func fetchData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ())
}
