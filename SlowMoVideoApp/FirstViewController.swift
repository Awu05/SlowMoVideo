//
//  FirstViewController.swift
//  SlowMoVideoApp
//
//  Created by Andy Wu on 1/10/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import UIKit


//Home Screen: Display all the files that were uplaoded onto Firebase
class FirstViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

