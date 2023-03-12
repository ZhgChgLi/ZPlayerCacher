# ZPlayerCacher

![ZPlayerCacher](https://user-images.githubusercontent.com/33706588/224538295-374df52d-c162-4ad8-9eaa-1df7ebb784bc.jpg)

<p align="center">
  <a href="https://codecov.io/gh/ZhgChgLi/ZPlayerCacher" target="_blank"><img src="https://codecov.io/gh/ZhgChgLi/ZPlayerCacher/branch/main/graph/badge.svg?token=DtFM8tKJye"></a>
  <a href="https://github.com/ZhgChgLi/ZPlayerCacher/actions/workflows/ci.yml" target="_blank"><img src="https://github.com/ZhgChgLi/ZPlayerCacher/actions/workflows/ci.yml/badge.svg"></a>
  <a href="https://cocoapods.org/pods/ZPlayerCacher" target="_blank"><img src="https://img.shields.io/cocoapods/v/ZPlayerCacher.svg?style=flat"></a>
  <a href="https://swift.org/package-manager/" target="_blank"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
  <br />
  <a href="https://raw.githubusercontent.com/ZhgChgLi/ZPlayerCacher/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/ZPlayerCacher.svg?style=flat" target="_blank"></a>
  <a href="https://github.com/ZhgChgLi/ZPlayerCacher" target="_blank"><img src="https://img.shields.io/cocoapods/p/ZPlayerCacher.svg?style=flat"></a>
</p>

ZPlayerCacher is a lightweight implementation of the AVAssetResourceLoaderDelegate protocol that enables AVPlayerItem to support caching streaming files.

> Please note that while this project serves as a demonstration of AVFoundation AVAssetResourceLoaderDelegate and the use of Combine to manage data flow, the code may not be written to the highest standard of cleanliness. If you have any suggestions for improving the code, please feel free to create an issue or pull request on the repository.

- [Technical Detail - AVPlayer 實踐本地 Cache 功能大全](https://medium.com/zrealm-ios-dev/avplayer-%E5%AF%A6%E8%B8%90%E6%9C%AC%E5%9C%B0-cache-%E5%8A%9F%E8%83%BD%E5%A4%A7%E5%85%A8-6ce488898003)


## Installation

### Swift Package Manager

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/ZhgChgLi/ZPlayerCacher.git`
- Select "Up to Next Major" with "1.0.0"

or 

```swift
...
dependencies: [
  .package(url: "https://github.com/ZhgChgLi/ZPlayerCacher.git", from: "1.0.0"),
]
...
.target(
    ...
    dependencies: [
        "ZPlayerCacher",
    ],
    ...
)
```

### CocoaPods
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
  pod 'ZPlayerCacher', '~> 1.0.0'
end
```

## Usage
```swift
let cacher: Cacher = // your implementation of Local Cache policy (Cacher Protocol), ref: PINCacher.md
let logger = DefaultPlayerCacherLogger() // could use default
let factory = CacheableAVURLAssetFactory(cacher: cacher, logger: logger).makeCacheableAVURLAssetIfSupported(url: url)

let playerItem = AVPlayerItem(asset: asset) // than playerItem will support caching
```

## Things to know
- Due to limitations in the Apple iOS system, currently unsupported video formats such as HLS file format(.ts) are not supported by ZPlayerCacher.

## Who is using
[![pinkoi](https://user-images.githubusercontent.com/33706588/221343295-3e3831e6-f76d-430a-87e3-4daf9815297d.jpg)](https://en.pinkoi.com)

[Pinkoi.com](https://en.pinkoi.com) is Asia's leading online marketplace for original design goods, digital creations, and workshop experiences.

## About
- [ZhgChg.Li](https://zhgchg.li/)
- [ZhgChgLi's Medium](https://blog.zhgchg.li/)

## Other works
- [ZMarkupParser](https://github.com/ZhgChgLi/ZMarkupParser) is a pure-Swift library that helps you convert HTML strings into NSAttributedString with customized styles and tags.
- [ZReviewTender](https://github.com/ZhgChgLi/ZReviewTender) is a tool for fetching app reviews from the App Store and Google Play Console and integrating them into your workflow.
- [ZMediumToMarkdown](https://github.com/ZhgChgLi/ZMediumToMarkdown) is a powerful tool that allows you to effortlessly download and convert your Medium posts to Markdown format. 

# Donate

[![Buy Me A Coffe](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20beer!&emoji=%F0%9F%8D%BA&slug=zhgchgli&button_colour=FFDD00&font_colour=000000&font_family=Bree&outline_colour=000000&coffee_colour=ffffff)](https://www.buymeacoffee.com/zhgchgli)

If you find this library helpful, please consider starring the repo or recommending it to your friends.

Feel free to open an issue or submit a fix/contribution via pull request. :)


