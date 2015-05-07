//
//  AppDelegate.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

class AppManager {
    static var sharedInstance: AppManager? = nil

    var takenImage: UIImage? = nil

    static func sharedManager() -> AppManager {
        if sharedInstance == nil {
            sharedInstance = AppManager()
        }
        return sharedInstance!
    }
}

