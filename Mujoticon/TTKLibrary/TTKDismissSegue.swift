//
//  DissmissSegue.swift
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

class TTKDismissSegue: UIStoryboardSegue {
    override func perform() {
        let sourceViewController = self.sourceViewController as! UIViewController
        sourceViewController.dismissViewControllerAnimated(true, completion: {})
    }
}

