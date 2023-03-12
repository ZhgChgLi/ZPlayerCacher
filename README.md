# ZPlayerCacher

![ZPlayerCacher](https://user-images.githubusercontent.com/33706588/224538295-374df52d-c162-4ad8-9eaa-1df7ebb784bc.jpg)

ZPlayerCacher is a lightweight implementation of the AVAssetResourceLoaderDelegate protocol that enables AVPlayerItem to support caching streaming files.

```swift
AVPlayerItem(asset: CacheableAVURLAssetFactory(cacher: PINCacher(), logger: DefaultPlayerCacherLogger()).makeCacheableAVURLAssetIfSupported(url: url))
```


