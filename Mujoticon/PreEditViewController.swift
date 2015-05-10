//
//  ViewController.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

@objc protocol PreEditViewControllerDelegate {
    optional func didDismissPreEditViewControllerAndGotoTop()
    optional func didDismissPreEditViewController()
}

class PreEditViewController: UIViewController,
                             UIScrollViewDelegate,
                             EditViewControllerDelegate {

    @IBOutlet var changeAspectFrame1: UIView!
    @IBOutlet var changeAspectFrame2: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    var isSquare: Bool = true
    var offset: CGFloat = 0.0
    var delegate: PreEditViewControllerDelegate? = nil

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
        // スクロールビューの設定
        self.scrollView.delegate = self
    
        // スクロールビューの大きさを調整する
        var frame = self.scrollView.frame
        var winSize = GET_WINSIZE()
        var toolBarHeight = 0
        var scrollViewY = winSize.height / 2 - self.scrollView.frame.size.height / 2
        self.scrollView.frame = CGRectMake(frame.origin.x,
                                           scrollViewY,
                                           self.scrollView.frame.width,
                                           self.scrollView.frame.height)
        
        // 選択中の画像を表示する
        var image = AppManager.sharedManager().takenImage
        self.imageView.image = image
    
        self.isSquare = true;
        self.settingAspect(self.isSquare)
    
        // ImageViewの調整をする
        self.updateImageView()
    
        // スクロールビューの調整をする
        self.updateScrollView()
    }

    func updateImageView() {
        // ImageViewの変形を初期化する
        self.imageView.transform = CGAffineTransformIdentity
        
        // ImageViewの大きさを設定する
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        // 画像の横の方が縦より大きい時
        var image = self.imageView.image!
        if image.size.width >= image.size.height {
            // 縦はアスペクト比によって最低限の大きさが変わる
            height = self.scrollView.frame.height - self.offset * 2.0
            var rate = height / image.size.height
            width = image.size.width * rate
        // 画像の縦の方が横より大きい時
        } else {
            width = self.scrollView.frame.width
            var rate = width / image.size.width
            height = image.size.height * rate;
        }
        let frame = CGRectMake(0.0, 0.0, width, height)
        self.imageView.bounds = frame
        self.imageView.frame = self.imageView.bounds
    }

    /**
    * @brief スクロールビューのスクロール域を変更する
    */
    func updateScrollView() {
        // 画像は自動で真ん中に配置されるため、そのオフセットは無視する
        var space = self.offset
        
        // 空白分をInsetに設定してスクロール域を変更する
        self.scrollView.contentInset = UIEdgeInsetsMake(space, 0, space, 0)
        
        // ImageViewの大きさがScrollViewのContentSizeになる
        self.scrollView.contentSize = self.imageView.frame.size
        
        // LOG("offsetX: \(self.scrollView.contentOffset.x), \(self.scrollView.contentOffset.y)")
    }
    
    /**
    * アスペクト比の設定
    */
    func settingAspect(isSquare: Bool) {
        // 正方形の時は正方形になるように薄黒いViewを表示
        if self.isSquare {
            self.changeAspectFrame1.hidden = false
            self.changeAspectFrame2.hidden = false
        // 3:4の時は薄黒いViewを非表示
        } else {
            self.changeAspectFrame1.hidden = true
            self.changeAspectFrame2.hidden = true
        }
        
        // アスペクト比によってオフセットを変更する
        if self.isSquare {
            self.offset = (self.scrollView.frame.height - self.scrollView.frame.width) / 2
        } else {
            self.offset = 0.0
        }
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func scrollViewDidZoom(scrollView: UIScrollView) {
        // スクロールビューの調整をする
        self.updateScrollView()
    }

    @IBAction func didTapReselect(sender: AnyObject) {
        // ViewControllerを閉じて写真を選び直す
        self.dismissViewControllerAnimated(false, completion: {
            if self.delegate != nil {
                self.delegate!.didDismissPreEditViewController!()
            }
        })
    }

    @IBAction func didTapAspect(sender: AnyObject) {
        // アスペクト比を変更する
        self.isSquare = !self.isSquare
        self.settingAspect(self.isSquare)

        // ImageViewの調整をする
        self.updateImageView()
    
        // スクロールビューの調整をする
        self.updateScrollView()
    }
    
    @IBAction func didTapNext(sender: AnyObject) {
        // 画像を表示されている位置で切り抜く
        var image = self.imageView.image!
    
        var transform = self.imageView.transform
        var scale: CGFloat = transform.a
    
        var x: CGFloat = self.scrollView.contentOffset.x / scale;
        var y: CGFloat = self.scrollView.contentOffset.y / scale;
    
        // オフセットを無視する
        y += self.offset / scale;
    
        // 実際の画像サイズを考慮したx, yに変更するためのレートを計算する
        var rate: CGFloat = 0.0
        let scrollViewSize = self.scrollView.frame.size;
        if image.size.width >= image.size.height {
            rate = image.size.height / (scrollViewSize.height - self.offset * 2)
        } else {
            rate = image.size.width / scrollViewSize.width
        }
    
        x *= rate;
        y *= rate;

        // 切り抜き後の大きさを計算する
        var width: CGFloat = scrollViewSize.width / scale * rate
        var height: CGFloat = (scrollViewSize.height - self.offset * 2) / scale * rate
    
        // 整数にする
        x = floor(x);
        y = floor(y);
        width = floor(width);
        height = floor(height);
    
        // 切り抜き処理
        var preEditImage = TTKEditImage.cutImage(image, rect: CGRectMake(x, y, width, height))
        LOG("切り抜いた画像の大きさ \(preEditImage.size.width), \(preEditImage.size.height)");
        
        // 編集画面に切り抜いた画像を送るためにシングルトンに保存する
        AppManager.sharedManager().takenImage = preEditImage
    
        self.performSegueWithIdentifier("goToEditView", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "goToEditView" {
            return
        }
        
        // 遷移先コントローラを取得
        var controller = segue.destinationViewController as! EditViewController
        
        // 遷移元ポインタを渡しておく
        controller.delegate = self
    }

    /**
    * EditViewControllerを閉じてTopViewControllerに戻りたい時に呼ばれる
    */
    func didDismissEditViewControllerAndGoToTop() {
        // CameraViewControllerを閉じてTopViewControllerに戻る
        self.dismissViewControllerAnimated(false, completion: {
            if self.delegate != nil {
                self.delegate!.didDismissPreEditViewControllerAndGotoTop!()
            }
        })
    }
}

