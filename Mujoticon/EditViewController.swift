//
//  ViewController.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

@objc protocol EditViewControllerDelegate {
    optional func didDismissEditViewControllerAndGoToTop()
}

class EditViewController: UIViewController,
                          StampListViewControllerDelegate,
                          StampViewDelegate {
    
    @IBOutlet var imageView: UIImageView!
    var stampNumber = -1
    var delegate: EditViewControllerDelegate? = nil

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
        self.view.userInteractionEnabled = true
        
        var manager = AppManager.sharedManager()
        if manager.takenImage == nil {
            LOG("撮影された画像がありませんでした")
            return
        }
        
        let image: UIImage = manager.takenImage!
        self.imageView.image = image
        self.imageView.userInteractionEnabled = true
        
        self.stampNumber = 0
        
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
        // 枠などを消す
        self.clearStampDecoration(AppManager.sharedManager().selectedStampViewList)
    
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
    
    func goToStampListView() {
        // StampListViewControllerへ
        performSegueWithIdentifier("goToStampListView", sender: nil)
    }
    
    @IBAction func didTapRetake(sender: AnyObject) {
        self.goToCameraView()
    }
    
    @IBAction func didTapRotate(sender: AnyObject) {
        let takenImage = AppManager.sharedManager().takenImage
        let rotateImage = TTKEditImage.rotateImage(takenImage!, angle: 90)
        AppManager.sharedManager().takenImage = rotateImage
        self.imageView.image = rotateImage
    }
    
    @IBAction func didTapStamp(sender: AnyObject) {
        self.goToStampListView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        // 対象セグエ以外ならここでリターン
        if segue.identifier != "goToStampListView" {
            return;
        }

        // 遷移先コントローラを取得
        let controller = segue.destinationViewController as! StampListViewController

        // 遷移元ポインタを渡しておく
        controller.delegate = self;
    }
    
    func didDissmissStampListViewController() {
        var stampIndex = AppManager.sharedManager().selectedStampIndex
    
        // スタンプが選択されていない時は何もしない
        if -1 == stampIndex {
            return;
        }

        self.clearStampDecoration(AppManager.sharedManager().selectedStampViewList)

        // 選択されたスタンプを取得する
        // 全てのスタンプを取得
        var stampList = AppManager.sharedManager().stampList!
        // 選択されたスタンプの名前を取得
        var stampName = stampList[stampIndex]
        // 選択されたスタンプの画像を作る
        var stampImage = UIImage(named: stampName)
        // 選択されたスタンプの番号を1加える
        self.stampNumber = self.stampNumber + 1;
    
        // スタンプを作る
        var stampView =  StampView(frame: STAMP_RECT);
    
        // TTK_StampRotateViewからdelegate出来るようにする
        stampView.delegate = self;
        
        stampView.imageView.image = stampImage

        // 真ん中にスタンプを配置する
        var imageSize = self.imageView.frame.size
        var stampSize = stampView.frame.size
        stampView.frame = CGRectMake(imageSize.width  / 2 - stampSize.width  / 2,
                                     imageSize.height / 2 - stampSize.height / 2,
                                     stampSize.width, stampSize.height)
        
        stampView.stampNumber = self.stampNumber;
        self.imageView.addSubview(stampView)
        
        AppManager.sharedManager().selectedStampViewList.append(stampView)
    }
    
    /**
    * 渡されたStampViewの全ての装飾を消す
    */
    func clearStampDecoration(stampViewList: Array<StampView>) {
        for stampView in stampViewList {
            stampView.clearRect()
            stampView.clearDirectionView()
            stampView.clearGarbageView()
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var stampIndex = AppManager.sharedManager().selectedStampIndex
        // スタンプが選択されていない時は何もしない
        if -1 == stampIndex {
            return;
        }
        
         // EditViewControllerがタッチイベントを取得しているので現在のスタンプリストの全ての枠を消す
        self.clearStampDecoration(AppManager.sharedManager().selectedStampViewList)
    }
    
    @IBAction func didTapTop(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: {
            if self.delegate != nil {
                self.delegate!.didDismissEditViewControllerAndGoToTop!()
            }
        })
    }
    
    /**
    * スタンプが削除した時に呼ばれる
    */
    func didDeleteStampView(stampView: StampView) {
        // 削除されたスタンプを選択されているスタンプから削除する
        AppManager.sharedManager().selectedStampViewList.removeObject(stampView)
    }
    
    /**
    * タッチされていないスタンプの装飾を消す
    * touchedStampNumber: タッチされたスタンプのStampNumber
    */
    func clearNoTouchedStampDecorations(touchedStampNumber: Int) {
        var selectedStampViewList = AppManager.sharedManager().selectedStampViewList
        // TTK_StampRotateViewからdelegateされたので押されたスタンプ以外のスタンプの装飾を消す        
        for stampView in selectedStampViewList {
            stampView.clearRect()
            stampView.clearDirectionView()
        }
    }
}

