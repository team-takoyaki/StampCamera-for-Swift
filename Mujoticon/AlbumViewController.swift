//
//  ViewController.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController,
                           UINavigationControllerDelegate,
                           UIImagePickerControllerDelegate,
                           PreEditViewControllerDelegate {

    var picker: UIImagePickerController!
    var isShowPickerFirst = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.sharedApplication().statusBarHidden = false
        
        self.initWithView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func initWithView() {
        self.picker = UIImagePickerController()
        self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.picker.delegate = self
        self.isShowPickerFirst = true
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.isShowPickerFirst {
            self.isShowPickerFirst = false
            self.showPhotoLibrary()
        }
    }
    
    func showPhotoLibrary() {
        self.presentViewController(self.picker, animated: false, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            // 選択された画像を取得する
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
            // 選択された画像を編集するため一度シングルトンに保存
            AppManager.sharedManager().takenImage = image
        }
        
        // 編集ビューに移動する
        picker.dismissViewControllerAnimated(false, completion:{
            self.performSegueWithIdentifier("goToPreEditView", sender: nil)
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        // 対象セグエ以外ならここでリターン
        if segue.identifier != "goToPreEditView" {
            return
        }
        
        // 遷移先コントローラを取得
        var controller = segue.destinationViewController as! PreEditViewController

        // 遷移元ポインタを渡しておく
        controller.delegate = self;
    }
    
    func didDismissPreEditViewControllerAndGotoTop()
    {
        // トップに戻る
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didDismissPreEditViewController()
    {
        // エディタ画面を閉じた時にフォトライブラリを開く
        self.showPhotoLibrary()
    }
}
