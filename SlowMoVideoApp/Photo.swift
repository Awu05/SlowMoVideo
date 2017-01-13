//
//  Photo.swift
//  SlowMoVideoApp
//
//  Created by Andy Wu on 1/11/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import Foundation

class Photo {
    var imgURL: String
    var uuid: String
    
    
    init(url: String, uuid: String) {
        self.imgURL = url
        self.uuid = uuid
    }
    
    
}
