
import UIKit

extension UIView {
    var width: CGFloat {
        get {
            return frame.width
        }
        set {
            frame = CGRect(x: frame.minX, y: frame.width, width: newValue, height: frame.height)
        }
    }
   
    var height: CGFloat {
        get {
            return frame.height
        }
        set {
            frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: newValue)
        }
    }
}