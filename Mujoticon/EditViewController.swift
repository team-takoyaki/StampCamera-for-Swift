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
        
        
        // ImageViewの大きさを画像の大きさに合わせる
        let imageViewSize = self.imageView.frame.size;
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rate: CGFloat = 0
        if image.size.width > image.size.height {
            height = imageViewSize.height
            rate = height / image.size.height
            width = imageViewSize.width * rate
        } else {
            width = imageViewSize.width;
            rate = width / image.size.width;
            height = image.size.height * rate;
        }
    
        // 整数にする
        width = floor(width);
        height = floor(height);
    
        // ImageViewの位置を調整する
        let winSize = GET_WINSIZE()
        let toolBarHeight: CGFloat = 0
        let y = (winSize.height - height - toolBarHeight) / 2;
        let imageViewFrame = self.imageView.frame;
        self.imageView.frame = CGRectMake(imageViewFrame.origin.x,
                                      y,
                                      width, height);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

