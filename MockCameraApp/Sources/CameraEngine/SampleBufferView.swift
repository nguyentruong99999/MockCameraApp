import SwiftUI
import AVFoundation

struct SampleBufferView: UIViewRepresentable {
    class SampleBufferUIView: UIView {
        override class var layerClass: AnyClass {
            return AVSampleBufferDisplayLayer.self
        }
        
        var sampleBufferLayer: AVSampleBufferDisplayLayer {
            return layer as! AVSampleBufferDisplayLayer
        }
    }
    
    func makeUIView(context: Context) -> SampleBufferUIView {
        let view = SampleBufferUIView()
        view.sampleBufferLayer.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIView(_ uiView: SampleBufferUIView, context: Context) {}
}
