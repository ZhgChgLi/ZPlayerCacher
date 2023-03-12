//
//  Network.swift
//
//
//  Created by https://zhgchg.li on 2022/8/31.
//

import Foundation

protocol NetworkTask {
    func resume()
}

protocol NetworkDelegate: AnyObject {
    func network(_ network: Network, didReceive data: Data)
    func network(_ network: Network, didCompleteWithError error: Error?)
}

protocol Network {
    var delegate: NetworkDelegate? { get set }
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkTask
    func dataTask(with request: URLRequest) -> NetworkTask
    func invalidateAndCancel()
}
