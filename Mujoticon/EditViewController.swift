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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
            width = imageViewSize.width
            rate = width / image.size.width
            height = image.size.height * rate
        }
    
        // 整数にする
        width = floor(width);
        height = floor(height);
    
        // ImageViewの位置を調整する
        let winSize = GET_WINSIZE()
        let toolBarHeight: CGFloat = 0
        let imageViewFrame = self.imageView.frame
        let y = winSize.height / 2 - height / 2
        self.imageView.frame = CGRectMake(imageViewFrame.origin.x,
                                      y,
                                      width, height);
    }

    @IBAction func didTapReverse(sender: AnyObject) {
        let takenImage = AppManager.sharedManager().takenImage
        let reverseImage = TTKEditImage.reverseImage(takenImage!)
        AppManager.sharedManager().takenImage = reverseImage
        self.imageView.image = reverseImage
    }
    
    @IBAction func didTapSave(sender: AnyObject) {
        // メインのImageViewから画像を生成する
        // 元の画像サイズのスケールで画像を生成する
        var scale: CGFloat = self.imageView.image!.size.width / self.imageView.frame.size.width
        
        // 小数第5位以下を切り捨てる
        scale = floor(scale * 10000) / 10000;
    
        let image = TTKEditImage.getImageFromView(self.imageView, scale: scale);
    
        // アルバムに保存して保存後にメソッドを呼び出す
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
    
        // 保存に失敗した時
        if error != nil {
            var errorMessage = error.description
            LOG(errorMessage)
            
            var alert = UIAlertView(title: "失敗", message: errorMessage, delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        LOG("saved");
    
        var alert = UIAlertView(title: "完了", message: "保存しました", delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func goToCameraView() {
        // CameraViewControllerへ
        performSegueWithIdentifier("backToCameraView", sender: nil)
    }
    
    @IBAction func didTapRetake(sender: AnyObject) {
        self.goToCameraView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

