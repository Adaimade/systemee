import SwiftUI

/// 依系統「文字大小」等動態類型調整版面，避免裁切或選單列消失。
enum TypeScaling {

    static func cardMinWidth(for dynamicType: DynamicTypeSize) -> CGFloat {
        switch dynamicType {
        case .accessibility3, .accessibility4, .accessibility5:
            return 520
        case .accessibility1, .accessibility2, .xxxLarge, .xxLarge:
            return 460
        default:
            return 400
        }
    }

    /// 選單列單行文字在空間不足時的最小縮放比例（愈大字級愈小）。
    static func menuBarMinimumScale(for dynamicType: DynamicTypeSize) -> CGFloat {
        switch dynamicType {
        case .accessibility3, .accessibility4, .accessibility5:
            return 0.48
        case .accessibility1, .accessibility2:
            return 0.6
        case .xxxLarge, .xxLarge, .xLarge:
            return 0.72
        default:
            return 0.82
        }
    }
}
