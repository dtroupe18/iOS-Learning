import Foundation
import ScreenSaver
import SwiftUI

final class PiScreenSaverView: ScreenSaverView {

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        // Enable layer-backed view for better rendering compatibility with SwiftUI
        wantsLayer = true

        let timeView = RotatingLinesView()
        let hostingController = NSHostingController(rootView: timeView)

        // Set frame directly to bounds and enable autoresizing
        hostingController.view.frame = bounds
        hostingController.view.autoresizingMask = [.width, .height]
        addSubview(hostingController.view)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        // Enable layer-backed view for better rendering compatibility with SwiftUI
        wantsLayer = true

        let timeView = RotatingLinesView()
        let hostingController = NSHostingController(rootView: timeView)

        // Set frame directly to bounds and enable autoresizing
        hostingController.view.frame = bounds
        hostingController.view.autoresizingMask = [.width, .height]
        addSubview(hostingController.view)
    }
}
