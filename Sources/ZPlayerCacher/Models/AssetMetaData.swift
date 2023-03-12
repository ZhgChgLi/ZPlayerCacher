//
//  AssetMetaData.swift
//
//
//  Created by https://zhgchg.li on 2022/8/26.
//

import Foundation

struct AssetMetaData: Codable {
    let contentLength: Int
    let contentType: String
    let isByteRangeAccessSupported: Bool
}
