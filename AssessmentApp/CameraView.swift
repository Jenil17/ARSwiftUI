//
//  CameraView.swift
//  AssessmentApp
//
//  Created by Jenil Jariwala on 2024-03-01.
//



import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool
    var onRecordingCompleted: ((URL, TimeInterval) -> Void)?

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onRecordingCompleted = onRecordingCompleted
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if uiViewController.isRecording != self.isRecording {
            uiViewController.toggleRecording()
        }
    }
}
