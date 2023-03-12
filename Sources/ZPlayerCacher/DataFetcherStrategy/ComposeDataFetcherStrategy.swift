//
//  ComposeDataFetcherStrategy.swift
//
//
//  Created by https://zhgchg.li on 2022/8/27.
//

import Combine
import Foundation

final class ComposeDataFetcherStrategy: NSObject, DataFetcherStrategy {

    private let local: LocalDataFetcherStrategy
    private let remote: RemoteDataFetcherStrategy

    init(local: LocalDataFetcherStrategy, remote: RemoteDataFetcherStrategy) {
        self.local = local
        self.remote = remote
        super.init()
    }

    func fetchMetaData() -> AnyPublisher<AssetMetaData, Error> {
        return local.fetchMetaData()
            .map { assetMetaData -> AssetMetaData in
                return assetMetaData
            }
            .catch { error -> AnyPublisher<AssetMetaData, Error> in
                if case PlayerCacherError.metaDataNotFound = error {
                    return self.remote.fetchMetaData().map { assetMetaData -> AssetMetaData in
                        self.local.saveMetaData(metaData: assetMetaData)
                        return assetMetaData
                    }.eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }

    func fetchMediaData(start: Int, length: DataFetcherRequestLength) -> AnyPublisher<Data, Error> {
        return fetchMetaData().flatMap { assetMetaData -> AnyPublisher<Data, Error> in
            let mediaDataEnd: Int
            switch length {
            case .length(let length):
                mediaDataEnd = length
            case .totalLength:
                mediaDataEnd = assetMetaData.contentLength
            }

            var offset = start
            return self.local.fetchMediaData(start: start, length: .length(mediaDataEnd)).map { data -> Data in
                offset += data.count
                return data
            }.catch { error -> AnyPublisher<Data?, Error> in
                if case PlayerCacherError.mediaDataNotFound = error {
                    return Future<Data?, Error> { promise in
                        promise(.success(nil))
                    }.eraseToAnyPublisher()
                } else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }.flatMap { localData -> AnyPublisher<Data?, Error> in
                if offset >= mediaDataEnd {
                    // local data enough
                    return Future<Data?, Error> { promise in
                        promise(.success(localData))
                    }.eraseToAnyPublisher()
                } else {
                    return Future<Data?, Error> { promise in
                        promise(.success(localData))
                    }.eraseToAnyPublisher()
                        .merge(with: self.remote.fetchMediaData(start: offset, length: .length(mediaDataEnd)).map { remoteData in
                            self.local.saveMediaData(offset: Int(offset), newData: remoteData)
                            offset += remoteData.count
                            return remoteData
                        })
                        .eraseToAnyPublisher()
                }
            }.compactMap { data in
                return data
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }

    func cancel() {
        local.cancel()
        remote.cancel()
    }
}
