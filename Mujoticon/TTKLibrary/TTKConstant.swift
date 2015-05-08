//
//  DissmissSegue.swift
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

func LOG(_ body: AnyObject! = "", function: String = __FUNCTION__) {
    TTKConstant.Log(body: body, function: function)
}

func GET_WINSIZE() -> CGSize {
    return TTKConstant.getWinSize()
}

let STROKE_WIDTH: CGFloat = 1.5

class TTKConstant {
    static func Log(body: AnyObject! = "", function: String = __FUNCTION__) {
        print("\(function):")
        println("\(body)")
    }

    static func getWinSize() -> CGSize {
        return UIScreen.mainScreen().bounds.size
    }
}

