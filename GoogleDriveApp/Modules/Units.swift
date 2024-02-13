import Foundation

public struct Units {

    public let bytes: Double

    public var kilobytes: Double {
        return Double(bytes) / 1024
    }

    public var megabytes: Double {
        return kilobytes / 1024
    }

    public var gigabytes: Double {
        return megabytes / 1024
    }

    public init(bytes: Double) {
        self.bytes = bytes
    }

    public func getReadableUnit() -> String {

        switch bytes {
        case 0..<1024:
            return "\(bytes) bytes"
        case 1024..<(1024 * 1024):
            return "\(String(format: "%.2f", kilobytes)) KB"
        case 1024..<(1024 * 1024 * 1024):
            return "\(String(format: "%.2f", megabytes)) MB"
        case (1024 * 1024 * 1024)...Double.greatestFiniteMagnitude:
            return "\(String(format: "%.2f", gigabytes)) GB"
        default:
            return "\(bytes) bytes"
        }
    }
}
