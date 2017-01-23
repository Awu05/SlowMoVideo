//
//  VideoPlayerViewController.swift
//  SlowMoVideoApp
//
//  Created by Andy Wu on 1/18/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer
import MobileCoreServices


class VideoPlayerViewController: UIViewController {

    @IBOutlet weak var slowmoSliderProp: UISlider!
    
    @IBAction func slowmoSlider(_ sender: Any) {
        avPlayer.rate = self.slowmoSliderProp.value
    }
    
    var filePath: String = ""
    var avPlayer = AVPlayer()
    var avPlayerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // An AVPlayerLayer is a CALayer instance to which the AVPlayer can
        // direct its visual output. Without it, the user will see nothing.
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        
        let url = URL (fileURLWithPath: filePath)
        let playerItem = AVPlayerItem(url: url)
        avPlayer.replaceCurrentItem(with: playerItem)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer.play() // Start the playback
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout subviews manually
        avPlayerLayer.frame = view.bounds
        self.view.bringSubview(toFront: slowmoSliderProp)
    }

}
