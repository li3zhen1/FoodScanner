import SwiftUI
import AVFoundation


final class PixelBufferPublisher: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    
    @Published var buffer: CVImageBuffer?
    
    let queue = DispatchQueue(label: "me.lizhen.pixelBufferManager", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let imageBuffer = sampleBuffer.imageBuffer {
            DispatchQueue.main.async {
                self.buffer = imageBuffer
            }
        }
    }
    
}
