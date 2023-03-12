//
//  Cacher.swift
//
//
//  Created by https://zhgchg.li on 2022/9/3.
//

import Foundation

public protocol Cacher {
    func set(key: String, data: Data, completion: ((Error?) -> Void)?)
    func get(key: String) -> Data?
}
