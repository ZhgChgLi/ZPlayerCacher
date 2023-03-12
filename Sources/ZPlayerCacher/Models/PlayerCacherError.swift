//
//  PlayerCacherError.swift
//
//
//  Created by https://zhgchg.li on 2022/8/29.
//

import Foundation

enum PlayerCacherError: Error {
    case metaDataNotFound(String)
    case mediaDataNotFound(String)
    case responseIsNotHTTPURLResponse(URLResponse?)
    case responseMissingRequiredHeader(String)
    case unexpected
}
