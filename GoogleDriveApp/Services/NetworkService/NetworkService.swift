import Foundation

class NetworkService: NetworkServiceProtocol {

    let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            URLSession.shared.dataTask(with: urlRequest, completionHandler: completion).resume()
        }
    }
}
