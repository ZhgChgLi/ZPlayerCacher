//
//  PINCacher.swift
//  ZPlayerCacherExample
//
//  Created by 李仲澄 on 2024/2/1.
//

import Foundation
import PINCache
import ZPlayerCacher

public final class PINCacher: Cacher {

    static let cache: PINCache = PINCache(name: "ResourceLoader")

    private lazy var jsonDecoder = JSONDecoder()
    
    public func set(key: String, data: Data, completion: ((Error?) -> Void)?) {
        PINCacher.cache.setObjectAsync(data, forKey: key, completion: nil)
    }

    public func get(key: String) -> Data? {
        let data = PINCacher.cache.object(forKey: key) as? Data
        return data
    }

    public static func clean() {
        PINCacher.cache.removeAllObjects()
    }

    public static func setByteLimit(memoryByteLimit: UInt, diskByteLimit: UInt) {
        PINCacher.cache.memoryCache.costLimit = memoryByteLimit
        PINCacher.cache.diskCache.byteLimit = diskByteLimit
    }
}
