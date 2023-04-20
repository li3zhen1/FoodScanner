import SwiftUI


struct RawColor: Codable {
    let r: Double
    let g: Double
    let b: Double
}

extension RawColor {
    func toColor() -> Color {
        return Color(red: self.r, green: self.g, blue: self.b)
    }
    
    func getGradient() -> LinearGradient {
        return LinearGradient(
            gradient: Gradient(colors: [
                .init(red: self.r*1.02 + 0.02, green: self.g*1.02 + 0.02, blue: self.b*1.02 + 0.02),
                .init(red: self.r, green: self.g, blue: self.b),
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
