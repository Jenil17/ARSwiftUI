//
//  CameraViewControllerRepresentable.swift
//  AssessmentApp
//
//  Created by Jenil Jariwala on 2024-03-02.
//

import Foundation
import UIKit
import AVFoundation
import CoreData
import SwiftUI



struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isRecording: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        if uiViewController.isRecording != self.isRecording {
            uiViewController.toggleRecording()
        }
    }
}
