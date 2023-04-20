import SwiftUI
import Foundation
import AVFoundation
import CoreGraphics




final class CameraPublisher: ObservableObject {
    
    enum AuthorizationStatus: Int {
        case unconfigured = 1
        case configured
        case unauthorized
        case failed
    }
    
    @Published var authorizeStatus: AuthorizationStatus = .unconfigured
    @Published var cameraError: CameraError? = nil
    
    
    public let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "me.lizhen.cameraPublisher", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    private let session = AVCaptureSession()
    
    init() {
        checkPermission()
        sessionQueue.async {
            self.configureCaptureSession()
            self.session.startRunning()
        }
    }
    
    deinit {
        session.stopRunning()
    }
    

    private func checkPermission() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.authorizeStatus = .unauthorized
                    self.setCameraError(error: .authorizationError)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            authorizeStatus = .unauthorized
            setCameraError(error: .authorizationError)
        case .denied:
            authorizeStatus = .unauthorized
            setCameraError(error: .authorizationError)
        case .authorized:
            break
        default:
            authorizeStatus = .unauthorized
            setCameraError(error: .authorizationError)
        }
    }
    
    
    private func setCameraError(error: CameraError) {
        DispatchQueue.main.async {
            self.cameraError = error
        }
    }
    
    
    private func configureCaptureSession() {
        guard authorizeStatus == .unconfigured else { return }
        
        session.beginConfiguration()
        
        defer { session.commitConfiguration() }
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            setCameraError(error: .unavailable)
            authorizeStatus = .failed
            return
        }
        
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            
            guard session.canAddInput(cameraInput) else {
                setCameraError(error: .inputError)
                authorizeStatus = .failed
                return
            }
                
            session.addInput(cameraInput)
        } catch {
            setCameraError(error: .inputError)
            authorizeStatus = .failed
            return
        }
        
        guard session.canAddOutput(videoOutput) else {
            setCameraError(error: .outputError)
            authorizeStatus = .failed
            return
        }
        session.addOutput(videoOutput)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        if let videoConnection = videoOutput.connection(with: .video) {
            videoConnection.videoOrientation = .portrait
        }
        
        authorizeStatus = .configured
    }
    
}
