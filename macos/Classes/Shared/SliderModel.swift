import Cocoa
internal import Combine
import Foundation

class SliderModel: NSObject {
    @objc dynamic var value: Double = 50.0 {
        didSet {
            onChange?(value)
        }
    }

    @objc dynamic var minValue: Double = 0.0
    @objc dynamic var maxValue: Double = 100.0

    var onChange: ((Double) -> Void)?
}
