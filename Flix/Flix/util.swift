//
//  util.swift
//  Flix
//
//  Created by Yijin Kang on 6/17/16.
//  Copyright © 2016 Yijin Kang. All rights reserved.
//

import Foundation
import UIKit

// this function is copied from https://coderwall.com/p/6rfitq/ios-ui-colors-with-hex-values-in-swfit
func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
}

let black = UIColor.blackColor()
let white = UIColor.whiteColor()
let lightPurple = UIColorFromHex(0xFAF5FF)
let darkPurple = UIColorFromHex(0x3D007A)
let veryDarkPurple = UIColorFromHex(0x140029)