//
//  ButtonStyles.swift
//  Mindful Moments
//
//  Created by Tessa Ballard on 24/06/2026.
//

import SwiftUI

/// A button style that applies a subtle spring scale when pressed.
/// Works correctly inside ScrollView without competing with scroll gestures.
struct SpringScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
