import Foundation

enum DeserializerUtils {
    static func deepMerge(_ base: [String: Any], with patch: [String: Any]) -> [String: Any] {
        var result = base

        for (key, patchValue) in patch {
            if patchValue is NSNull {
                result.removeValue(forKey: key)
                continue
            }

            if let patchMap = patchValue as? [String: Any],
               let baseMap = result[key] as? [String: Any]
            {
                result[key] = deepMerge(baseMap, with: patchMap)
            } else {
                result[key] = patchValue
            }
        }

        return result
    }
}
