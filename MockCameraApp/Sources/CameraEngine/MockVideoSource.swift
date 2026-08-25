import Foundation
import AVFoundation

class MockVideoSource: NSObject, ObservableObject {
    @Published var isRunning = false
    
    func start() {
        isRunning = true
    }
    
    func stop() {
        isRunning = false
    }
}
