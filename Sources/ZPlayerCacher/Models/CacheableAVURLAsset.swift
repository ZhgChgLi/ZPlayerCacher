//
//  CacheableAVURLAsset.swift
//
//
//  Created by https://zhgchg.li on 2022/8/26.
//

import AVFoundation
import Foundation

public final class CacheableAVURLAsset: AVURLAsset {

    private var _resourceLoader: AVAssetResourceLoaderDelegate?

    func setResourceLoaderDelegate(_ resourceLoader: ResourceLoader?) {
        _resourceLoader = resourceLoader
        self.resourceLoader.setDelegate(resourceLoader, queue: resourceLoader?.loaderQueue)
    }
}
