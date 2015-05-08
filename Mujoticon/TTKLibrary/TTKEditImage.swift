//
//  DissmissSegue.swift
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

import UIKit

class TTKEditImage {
    /**
    * @brief Viewから画像を取得する
    * @param view 画像を取得したいView
    * @return 取得した画像
    */
    static func getImageFromView(view: UIView, scale: CGFloat) -> UIImage {
        let size = view.frame.size;
        let layer = view.layer;
        UIGraphicsBeginImageContextWithOptions(size, false, scale);
        let context = UIGraphicsGetCurrentContext();
        layer.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image
    }

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
    
    /**
    * @brief 画像を反転させる
    * @param image 対象の画像
    * @return 反転させた画像
    */
    static func reverseImage(image: UIImage) -> UIImage {
        // TODO: 何で左右に反転してるの？
        UIGraphicsBeginImageContext(image.size);
        var context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, image.size.width, image.size.height);
        CGContextScaleCTM(context, -1.0, -1.0);
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
        let reverseImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return reverseImage
    }
}

