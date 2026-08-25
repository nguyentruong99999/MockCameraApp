import SwiftUI

struct ContentView: View {
    @StateObject private var cameraService = CameraService()
    
    var body: some View {
        VStack {
            Text("Mock Camera Active")
                .font(.headline)
                .padding()
            SampleBufferView()
                .frame(height: 300)
                .cornerRadius(12)
        }
        .padding()
    }
}
