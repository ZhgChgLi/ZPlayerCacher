//
//  DataFetcherStrategy.swift
//
//
//  Created by https://zhgchg.li on 2022/8/26.
//

import Combine
import Foundation

enum DataFetcherRequestLength {
    case length(Int)
    case totalLength
}

protocol DataFetcherStrategy: NSObject {
    func fetchMetaData() -> AnyPublisher<AssetMetaData, Error>
    func fetchMediaData(start: Int, length: DataFetcherRequestLength) -> AnyPublisher<Data, Error>
    func cancel()
}
