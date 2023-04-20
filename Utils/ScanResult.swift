import SwiftUI

struct ScannedText {
    let text: String
    let box: CGRect
}

struct ScanResultItem {
    let id: String
    let icon: String
    let items: [String]
}

struct ScanResult {
    let textDetected: Bool
    let safe: Bool
    let potentialThreats: [ScanResultItem]
}

extension ScanResult {
    func describe() -> String {
        if(!self.textDetected) {
            return "No text recognized"
        }
        if (self.safe) {
            return "No items to avoid"
        }
        else {
            let allCount = self.potentialThreats.reduce(0) { partialResult, it in
                partialResult + it.items.count
            }
            return "\(allCount) \(allCount == 1 ? "item" : "items") to avoid"
        }
    }
    
    static let safeResult = ScanResult(textDetected: true, safe: true, potentialThreats: [])
    static let noTextResult = ScanResult(textDetected: false, safe: true, potentialThreats: [])
}
