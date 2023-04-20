import SwiftUI
import VisionKit
import Vision

enum ScanError: Error {
    case noTextRecognized
    case scanFailure
    case textRecognizeFailure
}

enum ScannerStatus {
    case streaming
    case capturedAndRecognizing
    case recognized
}

final class ScannerViewModel: ObservableObject {
    
    
    @Published var image: CGImage?
    @Published var status: ScannerStatus = .streaming
    @Published var capturedImage: CGImage? = nil
    @Published var capturedImageHasContent: Bool = false
    
    @Published var result: ScanResult? = nil
    @Published var scanError: ScanError? = nil
    
    
    
    let camera: CameraPublisher
    let pixelBuffer: PixelBufferPublisher
    
    init() {
        camera = CameraPublisher()
        pixelBuffer = PixelBufferPublisher()
        startSubscription()
    }
    
    public func startSubscription() {
        
        camera.videoOutput.setSampleBufferDelegate(pixelBuffer, queue: pixelBuffer.queue)
        
        pixelBuffer.$buffer
            .receive(on: RunLoop.main)
            .compactMap { buffer in
                return buffer?.toCGImage()
            }
            .assign(to: &$image)
        
        $capturedImage
            .receive(on: RunLoop.main)
            .compactMap { ci in
                return ci != nil
            }
            .assign(to: &$capturedImageHasContent)
        
    }
    
    
    public func captureAndRecognize(
        onGetObservations: @escaping ([VNRecognizedTextObservation]?) -> ScanResult,
        onRecognized: @escaping (ScanResult) -> Void,
        forceImage: CGImage? = nil
    ) async {
        guard status == .streaming else { return }
        guard let image = forceImage ?? self.image else { return }
        
        DispatchQueue.main.sync {
            self.capturedImage = image
            self.status = .capturedAndRecognizing
        }
        
        
        guard let capturedImage = self.capturedImage else { return }
        
        Task {
            var scanResult: ScanResult? = nil
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["zh-Hans", "en-US"]
            
            
            let imageRequestHandler = VNImageRequestHandler(cgImage: capturedImage)
            
            
            do {
                try imageRequestHandler.perform([request])
                
                guard let observations = request.results else {
                    DispatchQueue.main.async {
                        self.scanError = .noTextRecognized
                    }
                    return
                }
                
                scanResult = onGetObservations(observations)
                
            } catch {
                DispatchQueue.main.sync {
                    self.scanError = .scanFailure
                }
            }
            
            DispatchQueue.main.sync {
                self.status = .recognized
            }
            
            if let scanResult {
                DispatchQueue.main.sync {
                    onRecognized(scanResult)
                }
            }
        }
        
    }
    
    public func restartCapturing() {
        guard status == .recognized else {return}
        capturedImage = nil
        status = .streaming
    }
    
    
}
