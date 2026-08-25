# MockCameraApp (iOS Video Stream & Camera Test Harness)

Dự án iOS mẫu hoàn chỉnh để thử nghiệm xử lý luồng Video & Giả lập Camera (`AVFoundation`) trên iPhone/iPad và iOS Simulator.

---

## 📁 Cấu trúc thư mục

```
C:\Users\Admin\Downloads\sdt\
├── .github/
│   └── workflows/
│       └── build_ipa.yml       # Tự động build ra file .ipa trên GitHub Actions (macOS)
├── MockCameraApp/
│   ├── Sources/
│   │   ├── MockCameraApp.swift # Entry point SwiftUI
│   │   ├── ContentView.swift   # Giao diện điều khiển (Chọn video, Preview, bật tắt Stream)
│   │   └── CameraEngine/
│   │       ├── CameraService.swift    # Quản lý AVCaptureSession thực tế
│   │       ├── MockVideoSource.swift  # Bộ giải mã và phát Frame video giả lập
│   │       └── FrameBufferView.swift  # View UIKit render CMSampleBuffer
│   └── Resources/
│       └── Info.plist          # Cấu hình quyền truy cập Camera, Photo Library & Chia sẻ file
└── README.md
```

---

## 🚀 Cách sử dụng & Xuất file `.ipa`

### Cách 1: Tự động xuất file `.ipa` qua GitHub Actions (Không cần máy Mac)
1. Đưa toàn bộ thư mục này lên một **GitHub Repository** của bạn:
   ```bash
   cd C:\Users\Admin\Downloads\sdt
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/<tai-khoan>/<repo-name>.git
   git push -u origin main
   ```
2. Vào tab **Actions** trên GitHub và chọn chạy workflow **Build iOS IPA**.
3. Sau khi quá trình build hoàn tất (khoảng 2-3 phút), tải file `MockCameraApp.ipa` từ mục **Artifacts**.

### Cách 2: Cài đặt file `.ipa` lên iPhone (Trên Windows)
* Sử dụng **Sideloadly** hoặc **AltStore** trên Windows để cài đặt file `.ipa` trực tiếp vào iPhone qua cáp Lightning/Type-C.
