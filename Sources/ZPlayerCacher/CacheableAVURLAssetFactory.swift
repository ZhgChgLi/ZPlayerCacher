//
//  CacheableAVURLAssetFactory.swift
//
//
//  Created by https://zhgchg.li on 2022/8/26.
//

import AVFoundation
import Foundation

public struct CacheableAVURLAssetFactory {
    private let customSchemeForTriggerResourceLoader: String
    private let supportedURLSchemes: [String]
    private let logger: PlayerCacherLogger
    private let cacher: Cacher
    
    public init(customSchemeForTriggerResourceLoader: String = "cacheableScheme", supportedURLSchemes: [String] = ["http", "https"], cacher: Cacher, logger: PlayerCacherLogger) {
        self.customSchemeForTriggerResourceLoader = customSchemeForTriggerResourceLoader
        self.supportedURLSchemes = supportedURLSchemes
        self.cacher = cacher
        self.logger = logger
    }

    public func makeCacheableAVURLAssetIfSupported(url: URL, options: [String: Any]? = nil) -> AVURLAsset {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let originScheme = components.scheme,
              supportedURLSchemes.contains(originScheme) else {
            return AVURLAsset(url: url, options: options)
        }

        components.scheme = customSchemeForTriggerResourceLoader
        let resourceLoader = ResourceLoader(originScheme: originScheme, cacher: cacher, logger: logger)
        let asset = CacheableAVURLAsset(url: components.url ?? url, options: options)
        asset.setResourceLoaderDelegate(resourceLoader)
        return asset
    }
}
