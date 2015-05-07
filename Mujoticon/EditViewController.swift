//
//  ViewController.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        self.initWithView()
    }
    
    func initWithView() {
        var manager = AppManager.sharedManager()
        if manager.takenImage == nil {
            LOG("撮影された画像がありませんでした")
            return
        }
        
        let image: UIImage = manager.takenImage!
        self.imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

