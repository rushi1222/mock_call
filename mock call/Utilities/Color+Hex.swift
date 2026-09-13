//
//  Color+Hex.swift
//  mock call
//

import SwiftUI

extension Color {
    init(hex: String) {
        var hexValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&hexValue)
        let r = Double((hexValue & 0xFF0000) >> 16) / 255
        let g = Double((hexValue & 0x00FF00) >> 8) / 255
        let b = Double(hexValue & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
