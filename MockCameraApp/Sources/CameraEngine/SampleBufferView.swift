import SwiftUI
import UIKit
import AVFoundation
import CoreImage

struct SampleBufferDisplayView: UIViewRepresentable {
    @Binding var currentImage: UIImage?

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = currentImage
    }
}
