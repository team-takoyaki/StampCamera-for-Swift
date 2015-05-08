//
//  DissmissSegue.swift
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol TTKCameraDelegate {
    optional func didTakePicture(image: UIImage)
}

class TTKCamera : UIView {
    enum DeviceType: Int {
        case RearCamera = 0
        case FrontCamera
    }
    
    var delegate: TTKCameraDelegate!
    var isSquare: Bool = true
    var session: AVCaptureSession!
    var previewView: UIView!
    var stillImageOutput: AVCaptureStillImageOutput?
    var videoInput: AVCaptureDeviceInput!

    init(frame: CGRect, delegate: TTKCameraDelegate) {
        super.init(frame: frame)
        
        self.delegate = delegate
        
        self.initWithView()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initWithView() {
        self.previewView = UIView(frame: self.frame)
    
        self.isSquare = true
        
        self.setupAVCapture()
    }
    
    func setupAVCapture() {
        self.session = AVCaptureSession()
        self.session.beginConfiguration()
        let videoInput = self.getDeviceInput(DeviceType.RearCamera)
        if videoInput == nil {
            return
        }
        self.videoInput = videoInput!
        self.session.addInput(videoInput)
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.session.addOutput(self.stillImageOutput)
        self.session.commitConfiguration()
        
        let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        captureVideoPreviewLayer.frame = self.previewView.frame
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        let previewLayer = self.previewView.layer
        previewLayer.masksToBounds = true
        previewLayer.addSublayer(captureVideoPreviewLayer)
        self.previewView!.backgroundColor = UIColor.redColor()
        
        self.addSubview(self.previewView!)
    }
    
    func start() {
        self.session!.startRunning()
    }
    
    func stop() {
        self.session!.stopRunning()
    }
    
    func take() {
        let videoConnection = self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo)
        if videoConnection == nil {
            return
        }
        
        self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler:  { (imageDataSampleBuffer: CMSampleBuffer?, error: NSError?) -> Void in
            if imageDataSampleBuffer == nil {
                return
            }
            
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
            let image = UIImage(data: imageData)
            
            var distImageWidth: CGFloat = 0
            var distImageHeight: CGFloat = 0
            
            // 最終的な画像の大きさ(比)を設定する
            // 正方形の時
            if self.isSquare {
                distImageWidth = self.frame.size.width
                distImageHeight = self.frame.size.width
            } else {
                distImageWidth = self.frame.size.width
                distImageHeight = self.frame.size.height
            }
        
            // 画像の大きさを取得する
            // 画面とは縦、横が逆のため逆にする
            var realImageWidth: CGFloat = image!.size.width
            var realImageHeight: CGFloat = image!.size.height

            // 画像の大きさと最終的な画像の大きさの比を取得する
            // 最終的な画像の大きさより写真の方が大きい
            let rate: CGFloat = distImageWidth / realImageWidth;

            // 写真の縦の大きさに比をかけて最終的な画像の大きさに直す
            let imageHeight: CGFloat = realImageHeight * rate;
        
            // 画像の大きさと最終的な画像の大きさの差を取得する
            let h: CGFloat = imageHeight - distImageHeight;
    
            // 画像の方が縦が最終的な画像より大きいため上下を切りとる
            // そのための上下のスペースの大きさ
            let oneSpace: CGFloat = h / 2;

            // スペースを実際の写真の大きさの比をかけて取得する
            let realOneSpace: CGFloat = oneSpace * (1 / rate);
        
            // 切り取る縦の大きさを取得する
            realImageHeight = realImageHeight - realOneSpace * 2;
        
            // 整数にする
            realImageWidth  = floor(realImageWidth);
            realImageHeight = floor(realImageHeight);
        
            // 切り取る領域を取得する
            let cutRect: CGRect = CGRectMake(0,
                                            realOneSpace,
                                            realImageWidth,
                                            realImageHeight);
        
            // 写真を切り取る
            let cutImage = TTKEditImage.cutImage(image!, rect: cutRect)

            // 撮影して切り抜いた画像をデリゲートに渡す
            if self.delegate != nil {
                self.delegate.didTakePicture!(cutImage)
            }
        })
    }
    
    func setDeviceInputWithType(type: DeviceType) {
        self.setDeviceInput(self.getDeviceInput(type));
    }
 
    func setDeviceInput(deviceInput: AVCaptureDeviceInput?) {
        assert(deviceInput != nil, "device input is nil.")
        self.session.beginConfiguration()
        self.session.removeInput(self.videoInput)
        self.videoInput = deviceInput;
        self.session.addInput(self.videoInput);
        self.session.commitConfiguration()
    }
    
    func getDeviceInput(type: DeviceType) -> AVCaptureDeviceInput? {
        var findPosition: AVCaptureDevicePosition!
        
        switch type {
            case DeviceType.FrontCamera:
                findPosition = AVCaptureDevicePosition.Front;
                break;
            default:
                findPosition = AVCaptureDevicePosition.Back;
                break;
        }
    
        let devices = AVCaptureDevice.devices()
        var deviceInput: AVCaptureDeviceInput? = nil
        for d in devices {
            let device = d as! AVCaptureDevice
            if !device.hasMediaType(AVMediaTypeVideo) {
                continue
            }
            
            if device.position != findPosition {
                continue
            }
            
            // ビデオを探す
            var error: NSErrorPointer = nil
            deviceInput = AVCaptureDeviceInput.deviceInputWithDevice(device, error: error) as? AVCaptureDeviceInput
            if error != nil {
                LOG("カメラが取得できませんでした")
                return nil
            }
            
            break
        }
        
        if deviceInput == nil {
            var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) as AVCaptureDevice?
            var error: NSErrorPointer = nil
            deviceInput = AVCaptureDeviceInput(device: device, error: error) as AVCaptureDeviceInput?
            
            if error != nil || deviceInput == nil {
                LOG("カメラが取得できませんでした")
                return nil
            }
        }
        
        return deviceInput
    }
}

