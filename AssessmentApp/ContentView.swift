//
//  ContentView.swift
//  AssessmentApp
//
//  Created by Jenil Jariwala on 2024-03-01.
//
import SwiftUI
import AVFoundation
import CoreData

struct ContentView: View {
    @State private var isRecording = false
    @State private var selectedMustache = "Mustache"
    
    @State private var tag = ""
    @State private var showTagPopup = false
    @State private var showAlert = false
    @State private var recordedVideoURL: URL?
    @State private var recordedVideoDuration: TimeInterval = 0

    
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            VStack {
                Picker("Select Mustache", selection: $selectedMustache) {
                    Text("Mustache").tag("Mustache")
                    Text("Mustache2").tag("Mustache2")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                ZStack {
                    ARViewContainer(isRecording: $isRecording, selectedMustache: $selectedMustache)
                        .edgesIgnoringSafeArea(.all)
                    
                
                    CameraView(isRecording: $isRecording)
                        .edgesIgnoringSafeArea(.all)
                }
               
                Button(action: toggleRecording) {
                    Text(isRecording ? "Stop Recording" : "Start Recording")
                        .foregroundColor(.white)
                        .padding()
                        .background(isRecording ? Color.red : Color.blue)
                        .clipShape(Capsule())
                }
                .padding()

                NavigationLink(destination: RecordingsView()) {
                    Text("Recordings")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .clipShape(Capsule())
                }
                .padding()
            }
            .navigationBarTitle("Video Screen")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Tag for the recording"),
                    message: Text("Enter a tag for your recording."),
                    dismissButton: .default(Text("Save")) {
                        saveRecordingWithTags(tag: tag)
                    }
                )
            }
            .sheet(isPresented: $showTagPopup) {
                TagEntryView(tag: $tag, onSave: { enteredTag in
                    self.showTagPopup = false
                    self.showAlert = true
                    self.tag = enteredTag
                })
            }
        }
        
        .environment(\.managedObjectContext, viewContext)
    }

    private func toggleRecording() {
        if self.isRecording {
            self.isRecording = false
            self.showTagPopup = true
        } else {
            self.isRecording = true
        }
    }

    private func saveRecordingWithTags(tag: String) {
        guard let recordedVideoURL = recordedVideoURL else {
            print("Recorded video URL is nil.")
            return
        }
        print("Recording saved with tag: \(tag)")
        let newRecording = RecordedSession(context: viewContext)
        newRecording.videoURL = recordedVideoURL.absoluteString
        newRecording.tag = tag
        
        do {
            try viewContext.save()
            print("Recording saved successfully.")
        } catch {
            print("Failed to save recording: \(error.localizedDescription)")
        }
        self.tag = ""
        self.recordedVideoURL = nil
    }
}

struct TagEntryView: View {
    @Binding var tag: String
    var onSave: (String) -> Void

    var body: some View {
        VStack {
            TextField("Enter Tag", text: $tag)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Save Tag") {
                onSave(tag)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview{
    ContentView()
}
