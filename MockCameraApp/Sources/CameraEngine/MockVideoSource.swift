import Foundation
import AVFoundation
import CoreMedia

protocol MockVideoSourceDelegate: AnyObject {
    func mockVideoSource(_ source: MockVideoSource, didOutput sampleBuffer: CMSampleBuffer)
}

final class MockVideoSource {
    weak var delegate: MockVideoSourceDelegate?

    private var assetReader: AVAssetReader?
    private var trackOutput: AVAssetReaderTrackOutput?
    private var timer: Timer?
    private var videoURL: URL?
    private(set) var isRunning: Bool = false

    func startStreaming(with url: URL, frameRate: Double = 30.0) {
        stopStreaming()
        self.videoURL = url
        self.isRunning = true
        setupReader(with: url)

        let interval = 1.0 / frameRate
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.readNextFrame()
        }
    }

    func stopStreaming() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        assetReader?.cancelReading()
        assetReader = nil
        trackOutput = nil
    }

    private func setupReader(with url: URL) {
        let asset = AVURLAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else { return }

        do {
            let reader = try AVAssetReader(asset: asset)
            let settings: [String: Any] = [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
            ]
            let output = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
            output.alwaysCopiesSampleData = false

            if reader.canAdd(output) {
                reader.add(output)
                reader.startReading()
                self.assetReader = reader
                self.trackOutput = output
            }
        } catch {
            print("Lỗi khởi tạo AVAssetReader: \(error.localizedDescription)")
        }
    }

    private func readNextFrame() {
        guard let output = trackOutput, let reader = assetReader else { return }

        if reader.status == .reading {
            if let sampleBuffer = output.copyNextSampleBuffer() {
                delegate?.mockVideoSource(self, didOutput: sampleBuffer)
            } else {
                // Hết video -> Reset đọc lại từ đầu (Loop)
                if let url = self.videoURL {
                    setupReader(with: url)
                }
            }
        } else if reader.status == .completed || reader.status == .failed {
            if let url = self.videoURL {
                setupReader(with: url)
            }
        }
    }
}
