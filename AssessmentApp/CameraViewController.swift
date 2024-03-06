//
//  CameraViewContorller.swift
//  AssessmentApp
//
//  Created by Jenil Jariwala on 2024-03-01.
//

import UIKit
import AVFoundation
import CoreData

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession!
    var videoOutput: AVCaptureMovieFileOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var isRecording = false
    var onRecordingCompleted: ((URL, TimeInterval) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                }
            }
        default:
            
            print("Camera access is denied or restricted.")
        }
    }

    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        let cameraPosition: AVCaptureDevice.Position = .front
        
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
           let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
           captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Failed to create video input.")
            return
        }
        
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
           captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        } else {
            print("Failed to create audio input.")
            return
        }
        
        videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("Failed to add video output.")
            return
        }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }


    @objc func toggleRecording() {
        if isRecording {
            print("Stopping recording...")
            stopRecording()
        } else {
            print("Starting recording...")
            startRecording()
        }
    }
    
    func startRecording() {
        guard captureSession.isRunning else {
            print("Capture session is not running.")
            return
        }

        let outputPath = NSTemporaryDirectory() + UUID().uuidString + ".mov"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        
        videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
        isRecording = true
        print("Recording started...")
    }

    
    func stopRecording() {
        if videoOutput.isRecording {
            print("Actually stopping the recording now.")
            videoOutput.stopRecording()
            isRecording = false
        } else {
            print("Was asked to stop recording, but videoOutput was not recording.")
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput,
                        didFinishRecordingTo outputFileURL: URL,
                        from connections: [AVCaptureConnection],
                        error: Error?) {
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    print("Recording finished with error: \(error.localizedDescription)")
                } else {
                    print("Recording finished successfully. URL: \(outputFileURL.path)")
                    let duration = output.recordedDuration.seconds
                    print("Recording duration: \(duration) seconds")
                    self?.saveRecording(outputFileURL: outputFileURL, duration: duration)
                    self?.isRecording = false
                    self?.onRecordingCompleted?(outputFileURL, duration)
                }
            }
        }

    private func saveRecording(outputFileURL: URL, duration: TimeInterval) {
        let context = PersistenceController.shared.container.viewContext
        
        let newSession = RecordedSession(context: context)
        newSession.videoURL = outputFileURL.absoluteString
        newSession.duration = duration
        
        do {
            try context.save()
            print("Recording saved successfully.")
        } catch {
            print("Failed to save to Core Data: \(error.localizedDescription)")
        }
    }
}

