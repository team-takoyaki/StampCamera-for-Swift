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
    
    var camera: TTKCamera!
    
    var isSquare: Bool!
    
    var isRearCamera: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.initWithView()
    }

    func initWithView() {
        UIApplication.sharedApplication().statusBarHidden = true
        
        self.camera = TTKCamera(frame: self.previewView.bounds, delegate: self)
        self.previewView.addSubview(self.camera)
        
        self.isSquare = true
        self.camera.isSquare = self.isSquare
        
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

    func goToEditView() {
        // EditViewControllerへ
        performSegueWithIdentifier("goToEditView", sender: nil)
    }
}

