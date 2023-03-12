//
//  FakeCacher.swift
//  
//
//  Created by https://zhgchg.li on 2023/3/12.
//

import Foundation
@testable import ZPlayerCacher

public final class FakeCacher: Cacher {

    private var data: [String: Data] = [:]

    private lazy var jsonDecoder = JSONDecoder()
    
    public func set(key: String, data: Data, completion: ((Error?) -> Void)?) {
        self.data[key] = data
    }

    public func get(key: String) -> Data? {
        return self.data[key]
    }
}
