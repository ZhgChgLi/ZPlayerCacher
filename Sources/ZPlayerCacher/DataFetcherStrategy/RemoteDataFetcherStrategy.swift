//
//  RemoteDataFetcherStrategy.swift
//
//
//  Created by https://zhgchg.li on 2022/8/27.
//

import Combine
import Foundation

final class RemoteDataFetcherStrategy: NSObject, DataFetcherStrategy {

    let url: URL

    private var network: Network
    private var subject = PassthroughSubject<Data, Error>.init()
    private let dispatchQueue: DispatchQueue

    init(url: URL, network: Network, dispatchQueue: DispatchQueue) {
        self.url = url
        self.network = network
        self.dispatchQueue = dispatchQueue
        super.init()

        self.network.delegate = self
    }

    func fetchMetaData() -> AnyPublisher<AssetMetaData, Error> {
        return Future { promise in
            var urlRequest = URLRequest(url: self.url)
            urlRequest.setValue("bytes=0-1", forHTTPHeaderField: "Range")

            let dataTask = self.network.dataTask(with: urlRequest) { _, response, responseError in

                if let error = responseError {
                    promise(.failure(error))
                    return
                }

                guard let urlResponse = response as? HTTPURLResponse else {
                    promise(.failure(PlayerCacherError.responseIsNotHTTPURLResponse(response)))
                    return
                }

                var allHeaderFields: [String: String] = [:]
                urlResponse.allHeaderFields.forEach { key, value in
                    if let keyString = key as? String, let valueString = value as? String {
                        allHeaderFields[keyString.lowercased()] = valueString
                    }
                }

                guard let contentType = allHeaderFields["content-type"] else {
                    promise(.failure(PlayerCacherError.responseMissingRequiredHeader("content-type")))
                    return
                }

                guard let contentRange = allHeaderFields["content-range"],
                      let contentLength = Int(contentRange.split(separator: "/").map { String($0) }.last ?? "0") else {
                    promise(.failure(PlayerCacherError.responseMissingRequiredHeader("content-range")))
                    return
                }

                guard let acceptRanges = allHeaderFields["accept-ranges"] else {
                    promise(.failure(PlayerCacherError.responseMissingRequiredHeader("accept-ranges")))
                    return
                }

                let isByteRangeAccessSupported = (acceptRanges == "bytes") ? true : false

                promise(.success(AssetMetaData(contentLength: contentLength, contentType: contentType, isByteRangeAccessSupported: isByteRangeAccessSupported)))
            }

            self.dispatchQueue.async {
                dataTask.resume()
            }
        }.receive(on: dispatchQueue).eraseToAnyPublisher()
    }

    func fetchMediaData(start: Int, length: DataFetcherRequestLength) -> AnyPublisher<Data, Error> {
        return subject.handleEvents { _ in

            let rangeString: String
            switch length {
            case .totalLength:
                rangeString = "bytes=\(String(start))-"
            case .length(let length):
                rangeString = "bytes=\(String(start))-\(String(start + length))"
            }

            var urlRequest = URLRequest(url: self.url)
            urlRequest.setValue(rangeString, forHTTPHeaderField: "Range")

            self.dispatchQueue.async {
                let dataTask = self.network.dataTask(with: urlRequest)
                dataTask.resume()
            }
        } receiveOutput: { _ in

        } receiveCompletion: { _ in

        } receiveCancel: {} receiveRequest: { _ in

        }.eraseToAnyPublisher()
    }

    func cancel() {
        network.invalidateAndCancel()
    }
}

extension RemoteDataFetcherStrategy: NetworkDelegate {
    func network(_ network: Network, didReceive data: Data) {
        dispatchQueue.async {
            self.subject.send(data)
        }
    }

    func network(_ network: Network, didCompleteWithError error: Error?) {
        dispatchQueue.async {
            if let error = error {
                self.subject.send(completion: .failure(error))
            } else {
                self.subject.send(completion: .finished)
            }
        }
    }
}
