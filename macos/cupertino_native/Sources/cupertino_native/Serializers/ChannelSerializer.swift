import SwiftUI

protocol Identifiable {
    func identityKey() -> String
}

protocol CNChannelDeserializable: Identifiable {
    init?(channel: [String: Any], viewId: Int64)
    var viewDebugId: String { get }
    mutating func applyPatch(_ channel: [String: Any])
}

enum CNChannelDeserialization {
    static func decode<T: CNChannelDeserializable>(_ raw: Any?, viewId: Int64) -> T? {
        guard let dict = raw as? [String: Any] else { return nil }
        return T(channel: dict, viewId: viewId)
    }

    static func decodeArray<T: CNChannelDeserializable>(_ raw: Any?, viewId: Int64) -> [T] {
        guard let array = raw as? [Any] else { return [] }
        return array.compactMap { decode($0, viewId: viewId) as T? }
    }

    static func asDict(_ value: Any?) -> [String: Any]? {
        value as? [String: Any]
    }

    static func asArray(_ value: Any?) -> [Any] {
        value as? [Any] ?? []
    }

    static func decodeString(_ value: Any?) -> String? {
        if value is NSNull {
            return nil
        }
        return value as? String
    }

    static func decodeBool(_ value: Any?) -> Bool? {
        if value is NSNull {
            return nil
        }
        return (value as? NSNumber)?.boolValue ?? value as? Bool
    }

    static func decodeInt(_ value: Any?) -> Int? {
        if value is NSNull {
            return nil
        }
        return (value as? NSNumber)?.intValue ?? value as? Int
    }

    static func decodeDouble(_ value: Any?) -> Double? {
        if value is NSNull {
            return nil
        }
        if value is String {
            let stringValue = value as! String
            if stringValue == "infinity" {
                return Double.infinity
            } else if stringValue == "-infinity" {
                return -Double.infinity
            } else if stringValue == "nan" {
                return Double.nan
            } else if stringValue == "zero" {
                return Double.zero
            }
        }
        return (value as? NSNumber)?.doubleValue ?? value as? Double
    }

    static func decodeCGFloat(_ value: Any?) -> CGFloat? {
        if value is NSNull {
            return nil
        }
        if value is String {
            let stringValue = value as! String
            if stringValue == "infinity" {
                return CGFloat.infinity
            } else if stringValue == "-infinity" {
                return -CGFloat.infinity
            } else if stringValue == "nan" {
                return CGFloat.nan
            } else if stringValue == "zero" {
                return CGFloat.zero
            }
        }

        if let number = value as? NSNumber {
            return CGFloat(truncating: number)
        }
        if let doubleValue = value as? Double {
            return CGFloat(doubleValue)
        }
        return nil
    }

    static func resolveButtonRole(_ role: String?) -> ButtonRole? {
        switch role {
        case "cancel": .cancel
        case "close": .close
        case "confirm": .confirm
        case "destructive": .destructive
        default: nil
        }
    }
}

protocol CNChannelSerializable {
    init?(channel: [String: Any])
    func toChannel() -> [String: Any]
}

enum CNChannelSerialization {
    static func asDict(_ value: Any?) -> [String: Any]? {
        value as? [String: Any]
    }

    static func asArray(_ value: Any?) -> [Any] {
        value as? [Any] ?? []
    }

    static func decode<T: CNChannelSerializable>(_ value: Any?) -> T? {
        guard let dict = asDict(value) else { return nil }
        return T(channel: dict)
    }

    static func decodeArray<T: CNChannelSerializable>(_ value: Any?) -> [T] {
        asArray(value).compactMap { decode($0) as T? }
    }

    static func encode(_ value: (some CNChannelSerializable)?) -> [String: Any]? {
        value?.toChannel()
    }

    static func encodeArray(_ values: [some CNChannelSerializable]) -> [[String: Any]] {
        values.map { $0.toChannel() }
    }
}
