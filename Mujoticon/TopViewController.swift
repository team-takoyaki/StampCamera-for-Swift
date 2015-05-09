//
//  ViewController.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIApplication.sharedApplication().statusBarHidden = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapCamera(sender: AnyObject) {
        // CameraViewControllerへ
        performSegueWithIdentifier("goToCameraView", sender: nil)
    }
    
    @IBAction func didTapAlbum(sender: AnyObject) {
        // AlbumViewControllerへ
        performSegueWithIdentifier("goToAlbumView", sender: nil)
    }
    
}

