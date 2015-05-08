//
//  ViewController.swift
//  Mujoticon
//
//  Created by Kashima Takumi on 2015/05/07.
//  Copyright (c) 2015年 UNUUU FOUNDATION. All rights reserved.
//

extension Array {
  mutating func removeObject<E: Equatable>(object: E) -> Array {
    for var i = 0; i < self.count; i++ {
      if self[i] as! E == object {
        self.removeAtIndex(i)
        break
      }
    }
    return self
  }
}

