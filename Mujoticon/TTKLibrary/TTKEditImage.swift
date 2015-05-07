//
//  DissmissSegue.swift
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

class TTKEditImage {
    static func cutImage(image: UIImage, rect: CGRect) -> UIImage {
        let imageWidth: CGFloat = image.size.width
        let imageHeight: CGFloat = image.size.height
    
        // 描画するためのキャンバスを生成する
        UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height))
        // 画像を描画する
        image.drawInRect(CGRectMake(-rect.origin.x, -rect.origin.y, imageWidth, imageHeight))
        // 描画した画像を取得する
        let cutImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cutImage
    }
}

