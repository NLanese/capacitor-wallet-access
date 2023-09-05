import Foundation

@objc public class WalletAccess: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
