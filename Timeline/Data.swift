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
    var imageURL:String
    var image:UIImage?
    
    init(_ text:String, _ date:Int, _ imageURL:String) {
        self.text = text
        self.date = date
        self.imageURL = imageURL
    }
}
