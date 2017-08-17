//
//  Data.swift
//  Timeline
//
//  Created by pbw on 2017. 8. 12..
//  Copyright © 2017년 pbw. All rights reserved.
//

import Foundation
import UIKit

let g_NumPerOneLoad = 3

class Post {
    var text:String
    var date:Int
    var imageView = UIImageView()
    
    init(_ text:String, _ date:Int) {
        self.text = text
        self.date = date
    }
}
