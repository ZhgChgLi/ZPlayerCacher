//
//  ViewController.swift
//  ZPlayerCacherExample
//
//  Created by 李仲澄 on 2024/2/1.
//

import UIKit
import ZPlayerCacher
import AVFoundation

class ViewController: UIViewController {
    
    private lazy var player: AVPlayer = makePlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        
        player.play()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        // Do any additional setup after loading the view.
    }
}

private extension ViewController {
    func makePlayer() -> AVPlayer {
        let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
        let cacher: Cacher = PINCacher()
        let avasset = CacheableAVURLAssetFactory(cacher: cacher, logger: DefaultPlayerCacherLogger()).makeCacheableAVURLAssetIfSupported(url: url)
        let playerItem = AVPlayerItem(asset: avasset)
        
        return AVPlayer(playerItem: playerItem)
    }
}

