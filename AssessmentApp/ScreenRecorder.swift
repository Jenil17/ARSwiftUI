//
//  ScreenRecorder.swift
//  AssessmentApp
//
//  Created by Jenil Jariwala on 2024-03-01.
//
import Foundation
import ReplayKit

class ScreenRecorder {
    private let recorder = RPScreenRecorder.shared()

    func startRecording(completion: @escaping (Bool, Error?) -> Void) {
        guard recorder.isAvailable else {
            completion(false, NSError(domain: "ScreenRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "Screen recording is not available."]))
            return
        }

        recorder.startRecording { error in
            completion(error == nil, error)
        }
    }

    func stopRecording(completion: @escaping (RPPreviewViewController?, Error?) -> Void) {
        recorder.stopRecording { previewViewController, error in
            completion(previewViewController, error)
        }
    }
}

