import SwiftUI
import Foundation

enum CameraError: Error {
    case unavailable
    case outputError
    case inputError
    case authorizationError
}
