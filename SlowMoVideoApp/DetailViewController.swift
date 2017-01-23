//
//  DetailViewController.swift
//  SlowMoVideoApp
//
//  Created by Andy Wu on 1/12/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer
import MobileCoreServices

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    var img = UIImage()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.scrollView.delegate = self
        
        fullScreenImage()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView;
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
    
    func fullScreenImage() {
        
        imgView.image = img
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        imgView.addGestureRecognizer(tap)
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        
        dismiss(animated: true, completion: nil)
    }

}
