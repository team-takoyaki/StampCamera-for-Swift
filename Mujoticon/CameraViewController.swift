//
//  CameraViewController.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, TTKCameraDelegate  {
    
    @IBOutlet var previewView: UIView!
    
    @IBOutlet var changeAspectFrame1: UIView!
    @IBOutlet var changeAspectFrame2: UIView!
    
    var camera: TTKCamera!
    var isSquare: Bool!
    var isRearCamera: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.initWithView()
    }

    func initWithView() {
        UIApplication.sharedApplication().statusBarHidden = true
        
        let frame = CGRectMake(0, 0, self.previewView.frame.width, self.previewView.frame.height)
        self.camera = TTKCamera(frame: frame, delegate: self)
        self.previewView.addSubview(self.camera)
        // アスペクトの調整より下に表示する
        self.camera.layer.zPosition = -1
        
        self.isSquare = true
        self.camera.isSquare = self.isSquare
        self.setAspect(self.isSquare)
        
        self.isRearCamera = true
        self.setIsRearCamera(self.isRearCamera)
        
        self.camera.start()
    }
    
    func setIsRearCamera(isRearCamera: Bool) {
        if isRearCamera {
            self.camera.setDeviceInputWithType(TTKCamera.DeviceType.RearCamera)
        } else {
            self.camera.setDeviceInputWithType(TTKCamera.DeviceType.FrontCamera)
        }
    }
    
    func setAspect(isSquare: Bool) {
        // 正方形の時は正方形になるように薄黒いViewを表示
        if (isSquare) {
            self.changeAspectFrame1.hidden = false
            self.changeAspectFrame2.hidden = false
        // 3:4の時は薄黒いViewを非表示
        } else {
            self.changeAspectFrame1.hidden = true
            self.changeAspectFrame2.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePicture(sender: AnyObject) {
        self.camera.take()
    }
    
    func didTakePicture(image: UIImage) {
        // 画像を保存する
        AppManager.sharedManager().takenImage = image
        
        self.goToEditView()
    }
    
    @IBAction func didTapChangeCamera(sender: AnyObject) {
        self.isRearCamera = !self.isRearCamera
        self.setIsRearCamera(self.isRearCamera)
    }

    @IBAction func didTapAspect(sender: AnyObject) {
        // アスペクト比を変更する
        self.isSquare = !self.isSquare
        self.camera.isSquare = self.isSquare
        self.setAspect(self.isSquare)
    }
    
    @IBAction func didTapBack(sender: AnyObject) {
        self.goToTopView()
    }
    
    func goToEditView() {
        // EditViewControllerへ
        performSegueWithIdentifier("goToEditView", sender: nil)
    }
    
    func goToTopView() {
        // TopViewControllerへ
        performSegueWithIdentifier("backToTopView", sender: nil)
    }
}

