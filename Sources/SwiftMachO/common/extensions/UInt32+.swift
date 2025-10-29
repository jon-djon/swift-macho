import Foundation


extension UInt32 {
    public var hexDescription: String {
        String(format: "%008x", self)
    }
}
