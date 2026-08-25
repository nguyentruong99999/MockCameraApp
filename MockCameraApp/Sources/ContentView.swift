import SwiftUI
import UIKit
import PhotosUI
import AVFoundation
import CoreImage

enum AppMode: String, CaseIterable, Identifiable {
    case realCamera = "Camera Thật"
    case mockVideo = "Video Giả Lập (VCam)"
    var id: String { self.rawValue }
}

struct ContentView: View {
    @StateObject private var cameraService = CameraService()
    private let mockSource = MockVideoSource()
    private let ciContext = CIContext()

    @State private var selectedMode: AppMode = .mockVideo
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var currentPreviewImage: UIImage? = nil
    @State private var statusMessage: String = "Chưa nạp video giả lập"
    @State private var isStreamingMock = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("VCam & Video Stream Test")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 8)

                Picker("Chế độ", selection: $selectedMode) {
                    ForEach(AppMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedMode, perform: { newMode in
                    handleModeChange(newMode)
                })

                ZStack {
                    SampleBufferDisplayView(currentImage: $currentPreviewImage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.darkGray))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedMode == .mockVideo ? Color.green : Color.blue, lineWidth: 2)
                        )

                    VStack {
                        HStack {
                            Label(selectedMode == .mockVideo ? "VIRTUAL FEED" : "LIVE CAMERA",
                                  systemImage: selectedMode == .mockVideo ? "play.circle.fill" : "camera.fill")
                                .font(.caption.bold())
                                .padding(8)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(selectedMode == .mockVideo ? .green : .blue)
                                .cornerRadius(8)
                            Spacer()
                        }
                        Spacer()
                    }
                    .padding()
                }
                .padding(.horizontal)

                VStack(spacing: 12) {
                    if selectedMode == .mockVideo {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .videos) {
                            HStack {
                                Image(systemName: "video.badge.plus")
                                Text("Chọn Video từ Thư viện")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .font(.headline)
                        }
                        .onChange(of: selectedPhotoItem, perform: { item in
                            loadSelectedVideo(item: item)
                        })
                    } else {
                        Button(action: {
                            if cameraService.isSessionRunning {
                                cameraService.stop()
                            } else {
                                cameraService.start()
                            }
                        }) {
                            HStack {
                                Image(systemName: cameraService.isSessionRunning ? "pause.circle.fill" : "play.circle.fill")
                                Text(cameraService.isSessionRunning ? "Tạm dừng Camera" : "Bắt đầu Camera")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            setupEngine()
        }
    }

    private func setupEngine() {
        cameraService.delegate = self
        mockSource.delegate = self
        cameraService.checkPermissions()
    }

    private func handleModeChange(_ mode: AppMode) {
        if mode == .realCamera {
            mockSource.stopStreaming()
            isStreamingMock = false
            cameraService.start()
            statusMessage = "Đang chạy Camera thật"
        } else {
            cameraService.stop()
            statusMessage = "Đang ở chế độ Video giả lập"
        }
    }

    private func loadSelectedVideo(item: PhotosPickerItem?) {
        guard let item = item else { return }
        statusMessage = "Đang tải video..."

        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_vcam.mp4")
                    try data.write(to: tempURL)
                    await MainActor.run {
                        self.mockSource.startStreaming(with: tempURL)
                        self.isStreamingMock = true
                        self.statusMessage = "Đang phát luồng video giả lập"
                    }
                }
            } catch {
                await MainActor.run {
                    self.statusMessage = "Lỗi nạp video: \(error.localizedDescription)"
                }
            }
        }
    }

    private func processSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        if let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.currentPreviewImage = uiImage
            }
        }
    }
}

extension ContentView: CameraServiceDelegate, MockVideoSourceDelegate {
    func cameraService(_ service: CameraService, didOutput sampleBuffer: CMSampleBuffer) {
        if selectedMode == .realCamera {
            processSampleBuffer(sampleBuffer)
        }
    }

    func mockVideoSource(_ source: MockVideoSource, didOutput sampleBuffer: CMSampleBuffer) {
        if selectedMode == .mockVideo {
            processSampleBuffer(sampleBuffer)
        }
    }
}
