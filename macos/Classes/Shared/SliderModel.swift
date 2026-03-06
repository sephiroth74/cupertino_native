import Cocoa
internal import Combine
import Foundation

class SliderModel: NSObject {
    @objc dynamic var value: Double = 50.0 {
        didSet {
            if value != oldValue {
                onChange?(value)
            }
        }
    }

    @objc dynamic var minValue: Double = 0.0
    @objc dynamic var maxValue: Double = 100.0

    var onChange: ((Double) -> Void)?

    public func updateValues(minValue: Double, maxValue: Double, value: Double) {
        guard minValue < maxValue else {
            NSLog("minValue must be less than maxValue")
            return
        }

        guard value >= minValue && value <= maxValue else {
            NSLog("value must be between minValue and maxValue")
            return
        }

        self.minValue = minValue
        self.maxValue = maxValue
        self.value = value
    }
}
