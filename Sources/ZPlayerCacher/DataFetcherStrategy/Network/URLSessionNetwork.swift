//
//  URLSessionNetwork.swift
//
//
//  Created by https://zhgchg.li on 2022/8/31.
//

import Foundation

final class URLSessionNetworkTask: NetworkTask {
    private let dataTask: URLSessionDataTask

    init(dataTask: URLSessionDataTask) {
        self.dataTask = dataTask
    }

    func resume() {
        dataTask.resume()
    }
}

final class URLSessionNetwork: NSObject, Network {

    private var urlSession: URLSession!

    override init() {
        super.init()

        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }

    weak var delegate: NetworkDelegate?

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask {
        let dataTask = urlSession.dataTask(with: request, completionHandler: completionHandler)
        return URLSessionNetworkTask(dataTask: dataTask)
    }

    func dataTask(with request: URLRequest) -> NetworkTask {
        let dataTask = urlSession.dataTask(with: request)
        return URLSessionNetworkTask(dataTask: dataTask)
    }

    func invalidateAndCancel() {
        urlSession.invalidateAndCancel()
    }
}

extension URLSessionNetwork: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        delegate?.network(self, didReceive: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.network(self, didCompleteWithError: error)
    }
}
