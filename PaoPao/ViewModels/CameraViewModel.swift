import AVFoundation
import SwiftUI
import Photos

enum CaptureState: Equatable {
    case idle
    case recording(startTime: Date)
    case captured(fileName: String, mediaType: MediaType)
}

@Observable
final class CameraViewModel: NSObject {
    let session = AVCaptureSession()
    var captureState: CaptureState = .idle
    var recordingProgress: Double = 0
    var cameraPermissionGranted = false

    private var photoOutput = AVCapturePhotoOutput()
    private var movieOutput = AVCaptureMovieFileOutput()
    private var recordingTimer: Timer?
    private var photoContinuation: CheckedContinuation<String, Error>?

    func requestPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraPermissionGranted = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermissionGranted = granted
                    if granted { self?.setupSession() }
                }
            }
        default:
            cameraPermissionGranted = false
        }
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: camera) else { return }

        if session.canAddInput(videoInput) { session.addInput(videoInput) }

        if let mic = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: mic),
           session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }

        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
            movieOutput.maxRecordedDuration = CMTime(seconds: 10, preferredTimescale: 600)
        }

        session.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func startRecording() {
        let fileName = "\(UUID().uuidString).mov"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        movieOutput.startRecording(to: url, recordingDelegate: self)
        captureState = .recording(startTime: Date())
        recordingProgress = 0

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self, case .recording(let start) = self.captureState else { return }
            let elapsed = Date().timeIntervalSince(start)
            self.recordingProgress = min(elapsed / 10.0, 1.0)
            if elapsed >= 10 { self.stopRecording() }
        }
    }

    func stopRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        movieOutput.stopRecording()
    }

    private func saveMediaFile(data: Data, ext: String) -> String {
        let fileName = "\(UUID().uuidString).\(ext)"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        try? data.write(to: url)
        return fileName
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        let fileName = saveMediaFile(data: data, ext: "jpg")
        DispatchQueue.main.async {
            self.captureState = .captured(fileName: fileName, mediaType: .photo)
        }
    }
}

extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let fileName = outputFileURL.lastPathComponent
        DispatchQueue.main.async {
            self.captureState = .captured(fileName: fileName, mediaType: .video)
        }
    }
}
