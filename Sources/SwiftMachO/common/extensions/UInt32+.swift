import Foundation


extension UInt32 {
    var hex: String {
        String(format: "0x%08x", self)
    }
}
