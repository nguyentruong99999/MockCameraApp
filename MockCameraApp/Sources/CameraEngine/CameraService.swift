import Foundation
import AVFoundation

class CameraService: NSObject, ObservableObject {
    @Published var isConfigured = false
    
    override init() {
        super.init()
        self.isConfigured = true
    }
}
