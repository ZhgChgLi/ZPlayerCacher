//
//  CacheableAVURLAssetFacotry_Tests.swift
//
//
//  Created by https://zhgchg.li on 2022/3/17.
//

import AVFoundation
@testable import ZPlayerCacher
import XCTest

class CacheableAVURLAssetFacotry_Tests: XCTestCase {

    private let logger: PlayerCacherLogger = DefaultPlayerCacherLogger()
    private let cacher: Cacher = FakeCacher()

    func testMakeCacheableAVURLAsset_initWithCacheableURLScheme() throws {
        let customScheme = "unitTestCustomScheme"
        let fileURL = URL(string: "https://zhgchg.li/1.mp4")!
        let factory = CacheableAVURLAssetFactory(customSchemeForTriggerResourceLoader: customScheme, supportedURLSchemes: ["http", "https"], cacher: cacher, logger: logger)
        let asset = factory.makeCacheableAVURLAssetIfSupported(url: fileURL)

        XCTAssertTrue(asset is CacheableAVURLAsset)
        XCTAssertEqual(asset.url.scheme, customScheme)
        XCTAssertEqual(asset.url.path, fileURL.path)
        XCTAssertEqual(asset.url.query, fileURL.query)
    }

    func testMakeCacheableAVURLAsset_initWithUnCacheableURLScheme() throws {
        let customScheme = "unitTestCustomScheme"
        let fileURL = URL(string: "ftp://zhgchg.li/1.mp4")!
        let factory = CacheableAVURLAssetFactory(customSchemeForTriggerResourceLoader: customScheme, supportedURLSchemes: ["http", "https"], cacher: cacher, logger: logger)
        let asset = factory.makeCacheableAVURLAssetIfSupported(url: fileURL)

        XCTAssertFalse(asset is CacheableAVURLAsset)
        XCTAssertEqual(asset.url.absoluteString, fileURL.absoluteString)
    }

    func testMakeCacheableAVURLAsset_cacheableAVURLAssetResourceLoaderLifeCycle() throws {
        let customScheme = "unitTestCustomScheme"
        let fileURL = URL(string: "https://zhgchg.li/1.mp4")!
        let factory = CacheableAVURLAssetFactory(customSchemeForTriggerResourceLoader: customScheme, supportedURLSchemes: ["http", "https"], cacher: cacher, logger: logger)

        var asset: AVURLAsset? = factory.makeCacheableAVURLAssetIfSupported(url: fileURL)
        XCTAssertNotNil(asset?.resourceLoader.delegate)

        asset = nil
        XCTAssertNil(asset?.resourceLoader.delegate)
    }
}

private class DefaultPlayerCacherLogger: PlayerCacherLogger {
    var loggerLevel: PlayerCacherLevel = .error
}
