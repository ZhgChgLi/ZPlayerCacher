//
//  LocalDataFetcherStrategy.swift
//
//
//  Created by https://zhgchg.li on 2022/8/27.
//

import Combine
import CryptoKit
import Foundation

final class LocalDataFetcherStrategy: NSObject, DataFetcherStrategy {

    let url: URL

    private var urlHashString: String {
        guard let data = url.absoluteString.data(using: .utf8) else {
            return url.absoluteString
        }
        return Insecure.MD5.hash(data: data).map {
            String(format: "%02hhx", $0)
        }.joined()
    }

    private var metaDataKey: String {
        return "metaData_\(urlHashString)"
    }

    private var mediaDataKey: String {
        return "mediaData_\(urlHashString)"
    }
    
    private lazy var jsonEncoder: JSONEncoder = JSONEncoder()
    private lazy var jsonDecoder: JSONDecoder = JSONDecoder()

    private let cacher: Cacher

    init(cacher: Cacher, url: URL) {
        self.url = url
        self.cacher = cacher
    }

    func fetchMetaData() -> AnyPublisher<AssetMetaData, Error> {
        return Future { promise in
            guard let assetMetaRawData = self.cacher.get(key: self.metaDataKey),
                  let assetMetaData = try? self.jsonDecoder.decode(AssetMetaData.self, from: assetMetaRawData) else {
                promise(.failure(PlayerCacherError.metaDataNotFound(self.url.absoluteString)))
                return
            }
            promise(.success(assetMetaData))
        }.eraseToAnyPublisher()
    }

    func fetchMediaData(start: Int, length: DataFetcherRequestLength) -> AnyPublisher<Data, Error> {
        return Future { promise in
            guard let assetMetaRawData = self.cacher.get(key: self.metaDataKey),
                  let assetMetaData = try? self.jsonDecoder.decode(AssetMetaData.self, from: assetMetaRawData),
                  let assetData = self.cacher.get(key: self.mediaDataKey),
                  !assetData.isEmpty else {
                promise(.failure(PlayerCacherError.mediaDataNotFound(self.url.absoluteString)))
                return
            }

            let assetDataEnd: Int
            switch length {
            case .length(let length):
                assetDataEnd = start + length
            case .totalLength:
                assetDataEnd = assetMetaData.contentLength
            }

            if assetData.count >= assetDataEnd {
                let subData = assetData.subdata(in: Int(start) ..< Int(assetDataEnd))
                promise(.success(subData))
                return
            } else if start <= assetData.count {
                // has cache data...but not enough
                let subEnd = (assetData.count > assetDataEnd) ? Int(assetDataEnd) : (assetData.count)
                let subData = assetData.subdata(in: Int(start) ..< subEnd)
                promise(.success(subData))
                return
            }
        }.eraseToAnyPublisher()
    }

    func cancel() {
        // do nothing
    }

    func saveMetaData(metaData: AssetMetaData) {
        guard let metaData = try? jsonEncoder.encode(metaData) else { return }
        cacher.set(key: metaDataKey, data: metaData, completion: nil)
    }

    func saveMediaData(offset: Int, newData: Data) {
        if var assetData = cacher.get(key: mediaDataKey) {
            if offset <= assetData.count && (offset + newData.count) > assetData.count {
                let start = assetData.count - offset
                assetData.append(newData.subdata(in: start ..< newData.count))
                cacher.set(key: mediaDataKey, data: assetData, completion: nil)
            }
        } else {
            cacher.set(key: mediaDataKey, data: newData, completion: nil)
        }
    }
}
