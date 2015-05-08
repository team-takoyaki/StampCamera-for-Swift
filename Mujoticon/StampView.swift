//
//  ViewController.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

let DIRECTION_VIEW_SIZE: CGFloat = 35.0
let GARBAGE_VIEW_SIZE: CGFloat = 35.0
let DIRECTION_IMAGE: String = "direction.png"
let GARBAGE_IMAGE: String = "garbage.png"
let STAMP_RECT = CGRectMake(0, 0, 75 + DIRECTION_VIEW_SIZE / 2, 75 + DIRECTION_VIEW_SIZE / 2)

@objc protocol StampViewDelegate {
    /**
    * @brief スタンプが削除された後に呼び出される
    * @param stampView 削除されたスタンプ
    */
    optional func didDeleteStampView(stampView: StampView)
    optional func clearNoTouchedStampDecorations(touchedStampNumber: Int)
}

class StampView: UIView {

    var imageFrame: CGRect!
    var imageView: UIImageView!
    var directionView: UIImageView!
    var garbageView: UIButton!
    var isDrawRect: Bool = false
    var delegate: StampViewDelegate?
    var stampNumber: Int = -1
    var isDirection: Bool = false
    var beganTouchPoint: CGPoint!
    var startTransform: CGAffineTransform!
    var tmpMoveX: Float!
    var tmpMoveY: Float!
    var tmpPoint: CGPoint!
    var tmpTheta: CGFloat!
    var tmpRadius: CGFloat!
    
    override init(frame: CGRect) {
        // ImageViewの位置
        self.imageFrame = CGRectMake(frame.origin.x + GARBAGE_VIEW_SIZE / 2,
                                     frame.origin.y + DIRECTION_VIEW_SIZE / 2,
                                     frame.size.width,
                                     frame.size.height);
        // Viewの位置
        var newFrame = CGRectMake(frame.origin.x,
                                  frame.origin.y,
                                  frame.size.width  + DIRECTION_VIEW_SIZE / 2 + GARBAGE_VIEW_SIZE / 2,
                                  frame.size.height + DIRECTION_VIEW_SIZE / 2 + GARBAGE_VIEW_SIZE / 2);
    
        super.init(frame: newFrame)
        
        self.initWithView()
    }
    
    func initWithView() {
        // 画像の設定
        self.imageView = UIImageView(frame: self.imageFrame)
        self.addSubview(self.imageView)
     
        // 指示Viewの設定
        var directionViewFrame = CGRectMake(GARBAGE_VIEW_SIZE / 2 + self.imageFrame.size.width - DIRECTION_VIEW_SIZE / 2,
                                            0,
                                            DIRECTION_VIEW_SIZE,
                                            DIRECTION_VIEW_SIZE)
        
        self.directionView = UIImageView(frame: directionViewFrame)
        self.directionView.image = UIImage(named: DIRECTION_IMAGE)
        self.addSubview(self.directionView)
        
        // 表示にする
        self.directionView.hidden = false
        
        // ゴミ箱Viewの設定
        var garbageViewFrame = CGRectMake(0,
                                          GARBAGE_VIEW_SIZE / 2 + self.imageFrame.size.height - GARBAGE_VIEW_SIZE / 2,
                                          GARBAGE_VIEW_SIZE,
                                          GARBAGE_VIEW_SIZE);
        
        self.garbageView = UIButton(frame: garbageViewFrame)
        self.garbageView.setBackgroundImage(UIImage(named: GARBAGE_IMAGE), forState: UIControlState.Normal)
        self.garbageView.addTarget(self, action: "deleteForAnimation", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(self.garbageView)
        
        // 表示にする
        self.garbageView.hidden = false

        // 線を描画する
        self.isDrawRect = true
        
        // 背景を透明にする
        self.backgroundColor = UIColor.clearColor()
        
        // タッチを有効にする
        self.userInteractionEnabled = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.delegate != nil {
            // TTK_StampViewDelegateでEditViewControllerのtouchesEndedに自分のstampNumberとイベント検出を通知
            self.delegate!.clearNoTouchedStampDecorations!(self.stampNumber)
        }
        
        var touch = touches.first as! UITouch
        var point = touch.locationInView(self)
        
        // タッチの座標を親Viewの座標からに変換する
        var pointFromSuperView = self.convertPoint(point, toView: self.superview)
        
        // 指示Viewの座標を親Viewからに変換する
        var directionRect = self.convertRect(self.directionView.frame, toView: self.superview)
        
        // タッチした領域が指示Viewかどうか
        if CGRectContainsPoint(directionRect, pointFromSuperView) {
            self.isDirection = true
        } else {
            self.isDirection = false
        }
        
        // スタート位置を保存する
        self.beganTouchPoint = pointFromSuperView;
    
        // スタート時のtransformを保存する
        self.startTransform = self.transform;
    
        // 枠を表示する
        self.drawRect()

        // 指示Viewを表示する
        self.directionView.hidden = false
        
        // ゴミ箱Viewを表示する
        self.garbageView.hidden = false
    
        // tmpMoveX, tmpMoveYの初期化
        self.tmpMoveX = 0.0
        self.tmpMoveY = 0.0
        self.tmpPoint = pointFromSuperView
    
        // tmpThetaの初期化
        self.tmpTheta = self.getTheta(pointFromSuperView.x, pointY: pointFromSuperView.y)
    
        // tmpRadiusの初期化
        self.tmpRadius = self.getRadius(pointFromSuperView.x, pointY: pointFromSuperView.y);
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch
        var point = touch.locationInView(self)
        
        // タッチの座標を親Viewの座標からに変換する
        var pointFromSuperView = self.convertPoint(point, toView: self.superview)
        
        // 指示Viewがタッチされている時
        if self.isDirection {
            // TODO: 縮小拡大、回転をする
            var theta = self.getTheta(pointFromSuperView.x, pointY: pointFromSuperView.y)
            var radius = self.getRadius(pointFromSuperView.x, pointY: pointFromSuperView.y)
            
            // 拡大変化率を求める
            var zoomRate = radius / self.tmpRadius;
    
            // 移動量を求める(回転する角度)
            // 逆回転もあるので絶対値は取らない
            var arg = theta - self.tmpTheta;
    
            // 拡大処理
            self.transform = CGAffineTransformScale(self.transform, zoomRate, zoomRate);

            // 回転処理
            self.transform = CGAffineTransformRotate(self.transform, arg);
        
            // 指示Viewを拡大率分小さくする処理を入れました
            self.directionView.transform = CGAffineTransformScale(self.directionView.transform, 1 / zoomRate, 1 / zoomRate);

            // ゴミ箱Viewを拡大率分小さくする処理を入れました
            self.garbageView.transform = CGAffineTransformScale(self.garbageView.transform, 1 / zoomRate, 1 / zoomRate);
        
            // tmpデータ更新
            self.tmpTheta = theta;
            self.tmpRadius = radius;
        } else {
            // TODO: 移動の処理
            var moveX: CGFloat = 0
            var moveY: CGFloat = 0
        
            // 移動量 = タッチされた場所 - 前いた場所
            moveX = -self.tmpPoint.x + pointFromSuperView.x;
            moveY = -self.tmpPoint.y + pointFromSuperView.y;
        
            // 移動場所を一旦保存
            var t1 = CGAffineTransformMakeTranslation(moveX, moveY);

            // 回転後移動するために合わせる
            self.transform = CGAffineTransformConcat(self.transform, t1);

            // 今いる場所を保存
            self.tmpPoint = pointFromSuperView;
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    }
    
    // 枠線描画
    func drawRect() {
        self.isDrawRect = true
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        // まずViewのbackgroundColorを設定しておく
        var context = UIGraphicsGetCurrentContext();
        // 線の太さの設定
        CGContextSetLineWidth(context, STROKE_WIDTH);
        var r = CGRectMake(self.imageFrame.origin.x + STROKE_WIDTH / 2,
                           self.imageFrame.origin.y + STROKE_WIDTH / 2,
                           self.imageFrame.size.width - STROKE_WIDTH,
                           self.imageFrame.size.height - STROKE_WIDTH);
        
        // スタンプの周りの線を表示する
        if self.isDrawRect {
            CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor);
        } else {
            CGContextSetStrokeColorWithColor(context, UIColor.clearColor().CGColor);
        }
        
        // 四角形の描画
        CGContextStrokeRect(context, r);
    }
    
    // 枠線を消す
    func clearRect() {
        self.isDrawRect = false
        self.setNeedsDisplay()
    }
    
    // 指示ビューを消す
    func clearDirectionView() {
        self.directionView.hidden = true
    }
    
    // ゴミ箱Viewを消す
    func clearGarbageView() {
        self.garbageView.hidden = true
    }
    
    // 座標のなす角を求める
    func getTheta(pointX: CGFloat, pointY: CGFloat) -> CGFloat {
        var vectorX: CGFloat = 0
        var vectorY: CGFloat = 0
        var theta: CGFloat = 0
        
        // Y座標はステータスバー方向が正
        // XYの平行移動後は回転軸がずれる
        // CP = OP - OC
        //    = pointX - (imgViewの角 + 中心までの距離)
        vectorY = -(pointY - self.center.y) + self.transform.ty;
        vectorX = pointX - self.center.x - self.transform.tx;
        // atan2の引数の順番は違う
        theta = atan2(vectorY, vectorX);

        // 0 <+ theta < 2 * Pi
        if theta < 0 {
            theta = theta + CGFloat(2 * M_PI);
        }
    
        // 回転方向を合わせるために-を返す
        return (-1 * theta);
    }

    // 中心から座標までの距離を求める
    func getRadius(pointX: CGFloat, pointY: CGFloat) -> CGFloat {
        var vectorX: CGFloat = 0
        var vectorY: CGFloat = 0
        vectorY = -(pointY - self.center.y) + self.transform.ty;
        vectorX = pointX - self.center.x - self.transform.tx;
        return CGFloat(sqrtf(Float(vectorX * vectorX + vectorY * vectorY)))
    }
    
    func deleteForAnimation() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.1)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector("delete")
        self.alpha = 0
        UIView.commitAnimations()
    }
    
    func delete() {
        // スタンプを削除する
        self.removeFromSuperview()
        if self.delegate != nil {
            self.delegate?.didDeleteStampView!(self)
        }
    }
}

