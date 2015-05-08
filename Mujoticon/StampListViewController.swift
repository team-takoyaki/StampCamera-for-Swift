//
//  ViewController.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

class StampListViewController: UIViewController,
                               UICollectionViewDataSource,
                               UICollectionViewDelegate {

    var stampList: Array<String>!
    @IBOutlet var collectionView: UICollectionView!
    
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
        // スタンプの一覧を取得する
        self.stampList = AppManager.sharedManager().stampList
        
        // 選択したスタンプのindexを初期化する
        AppManager.sharedManager().selectedStampIndex = -1
    
        // CollectionViewのデリゲートを設定する
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    // MARK: - UICollectionViewDelegate Protocol
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell =  self.collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        cell.backgroundColor = UIColor.whiteColor()
        let imageView = cell.viewWithTag(1) as! UIImageView
        let stampName = self.stampList[indexPath.row]
        imageView.image = UIImage(named: stampName)
        
        return cell
    }
 
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
 
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.stampList.count;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        LOG(indexPath.row);

        // 選択されたスタンプのindexを保存する
        AppManager.sharedManager().selectedStampIndex = indexPath.row
        
        // StampListViewControllerを閉じる
//        [self dismissViewControllerAnimated:YES completion:^{
//            if (_delegate) {
//                [_delegate didDismissStampListViewController];
//            }
//        }];
    }
}

