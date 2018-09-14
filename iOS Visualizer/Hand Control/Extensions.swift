import Foundation
import CoreGraphics

postfix operator ❞
postfix operator ❜

extension CGFloat {

    static postfix func ❞(inches: CGFloat) -> CGFloat {
        let meters = inches * 2.54 / 100
        return meters
    }

    static postfix func ❜(feet: CGFloat) -> CGFloat {
        let inches = feet * 12
        let meters = inches❞
        return meters
    }

}
