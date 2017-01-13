//
//  DataAccessObject.swift
//  SlowMoVideoApp
//
//  Created by Andy Wu on 1/11/17.
//  Copyright © 2017 Andy Wu. All rights reserved.
//

import Foundation

class DataAccessObject {
    var photos = [Photo]()
    
    static let sharedManager = DataAccessObject()
    
    private init(){
        
    }

}
