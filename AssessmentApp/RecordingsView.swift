import SwiftUI
import AVKit
import CoreData

struct RecordingsView: View {
    @FetchRequest(entity: RecordedSession.entity(), sortDescriptors: []) var recordings: FetchedResults<RecordedSession>

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(recordings, id: \.self) { recording in
                    RecordingCell(recording: recording)
                }
            }
            .padding()
        }
    }
}

struct RecordingCell: View {
    let recording: RecordedSession

    var body: some View {
        VStack {
            VideoPreview(url: URL(string: recording.videoURL ?? ""))
                .frame(height: 150)
                .cornerRadius(10)

            Text("Duration: \(formattedDuration(recording.duration))")
                .foregroundColor(.secondary)
                .padding(.top, 4)

            Text("Tag: \(recording.tag ?? "")")
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        return formatter.string(from: duration) ?? ""
    }
}

struct VideoPreview: View {
    let url: URL?

    var body: some View {
        if let url = url {
            VideoPlayer(player: AVPlayer(url: url))
                .onAppear {
                    AVPlayer.sharedQueuePlayer.removeAllItems()
                    AVPlayer.sharedQueuePlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
                    AVPlayer.sharedQueuePlayer.play()
                }
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.5))
        }
    }
}

extension AVPlayer {
    static let sharedQueuePlayer = AVQueuePlayer()
}
