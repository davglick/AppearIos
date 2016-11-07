//
//  Option.swift
//  Appear_Ios
//
//  Created by Davin Glick on 29/10/16.
//  Copyright © 2016 Appear. All rights reserved.
//

import UIKit

class Option: NSObject {
    
    var ID: String?
    var title:String?
    var inventoryCount: Int?
    var selected: Bool?
    
    convenience init(t: String?, count: Int?, i: String?) {
        self.init()
        title = t
        inventoryCount = count
        selected = false
        ID = i
        
    }
}

