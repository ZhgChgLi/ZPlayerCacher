//
//  PINCacher.swift
//
//
//  Created by https://zhgchg.li on 2022/8/31.
//

import Foundation
import PINCache

public final class PINCacher: Cacher {

    static let cache: PINCache = PINCache(name: "ResourceLoader")

    private lazy var jsonDecoder = JSONDecoder()
    
    func set(key: String, data: Data, completion: ((Error?) -> Void)?) {
        PINCacher.cache.setObjectAsync(data, forKey: key, completion: nil)
    }

    func get(key: String) -> Data? {
        let data = PINCacher.cache.object(forKey: key) as? Data
        return dataMigration(data: data)
    }

    public static func clean() {
        PINCacher.cache.removeAllObjects()
    }

    public static func setByteLimit(memoryByteLimit: UInt, diskByteLimit: UInt) {
        PINCacher.cache.memoryCache.costLimit = memoryByteLimit
        PINCacher.cache.diskCache.byteLimit = diskByteLimit
    }
}
