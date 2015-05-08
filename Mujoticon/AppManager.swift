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
    var stampList: Array<String>? = nil
    var selectedStampIndex: Int = -1
    var selectedStampViewList: Array<StampView> = []

    static func sharedManager() -> AppManager {
        if sharedInstance == nil {
            sharedInstance = AppManager()
        }
        return sharedInstance!
    }
    
    init() {
        self.initWithSetting()
    }
    
    func initWithSetting() {
        self.takenImage = UIImage(named: "abc.jpg")
        
        self.readStamp()
    }
    
    func readStamp() {
        let path: String? = NSBundle.mainBundle().pathForResource("stamp", ofType: "json")
        let fileHandle: NSFileHandle? = NSFileHandle(forReadingAtPath: path!)
        if fileHandle == nil {
            return
        }
        let data: NSData = fileHandle!.readDataToEndOfFile()
        var stampList: Array = NSJSONSerialization.JSONObjectWithData(data,
                                            options: NSJSONReadingOptions.AllowFragments,
                                            error: nil) as! Array<String>
        self.stampList = stampList
    }
}

