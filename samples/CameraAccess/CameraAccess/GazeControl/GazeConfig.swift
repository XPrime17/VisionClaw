import Foundation
import UIKit

enum GazeConfig {
  // Cursor server (Mac companion)
  static var cursorServerHost: String { SettingsManager.shared.cursorServerHost }
  static var cursorServerPort: Int { SettingsManager.shared.cursorServerPort }

  static var cursorServerBaseURL: String {
    "\(cursorServerHost):\(cursorServerPort)"
  }

  static var isCursorServerConfigured: Bool {
    return cursorServerHost != "http://YOUR_MAC_HOSTNAME.local"
      && !cursorServerHost.isEmpty
  }

  // Frame processing
  static let gazeUpdateInterval: TimeInterval = 1.0 / 30.0  // 30 fps (most frames are fast optical-flow-only)
  static let smoothingFactor: Double = 0.15  // Exponential moving average (lower = smoother)

  // JPEG quality for /locate frames (0.0-1.0, lower = smaller payload, faster upload)
  // 0.2 is sufficient — server downscales to 480px anyway
  static let locateJpegQuality: CGFloat = 0.2
}
