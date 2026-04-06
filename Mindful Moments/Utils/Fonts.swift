//
//  Fonts.swift
//  Mindful Moments
//
//  App typography: SF Pro Rounded (aligned with meditation duration chips).
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

/// iPad-only scaling so text stays readable at arm’s length (device + Simulator).
enum AppTypography {
    static var iPadTextScale: CGFloat {
        #if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad ? 1.22 : 1.0
        #else
        1.0
        #endif
    }
}

extension Font {
    /// Use instead of `Font.system(size:…)` so sizes grow on iPad only.
    static func appScaledSystem(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
        .system(size: size * AppTypography.iPadTextScale, weight: weight, design: design)
    }
    
    private static func scaledRounded(size: CGFloat, weight: Font.Weight) -> Font {
        appScaledSystem(size: size, weight: weight, design: .rounded)
    }
    
    // MARK: - Display
    
    /// Large title — 34pt bold rounded
    static var brandLargeTitle: Font { scaledRounded(size: 34, weight: .bold) }
    
    /// Title — 28pt bold rounded
    static var brandTitle: Font { scaledRounded(size: 28, weight: .bold) }
    
    /// Title 2 — 22pt medium rounded
    static var brandTitle2: Font { scaledRounded(size: 22, weight: .medium) }
    
    /// Title 3 — 20pt medium rounded (player / section headers)
    static var brandTitle3: Font { scaledRounded(size: 20, weight: .medium) }
    
    /// Navigation title — 34pt bold rounded
    static var brandNavigationTitle: Font { scaledRounded(size: 34, weight: .bold) }
    
    // MARK: - Body
    
    /// Headline — 17pt medium rounded
    static var brandHeadline: Font { scaledRounded(size: 17, weight: .medium) }
    
    /// Subheadline — 15pt regular rounded
    static var brandSubheadline: Font { scaledRounded(size: 15, weight: .regular) }
    
    /// Body — 16pt regular rounded
    static var brandBody: Font { scaledRounded(size: 16, weight: .regular) }
    
    /// Caption — 12pt regular rounded
    static var brandCaption: Font { scaledRounded(size: 12, weight: .regular) }
    
    // MARK: - Numbers & chips (meditation detail duration row)
    
    /// Digits on reference-style duration chips (5 / 10 / 15)
    static var brandDurationDigit: Font { scaledRounded(size: 35, weight: .bold) }
    
    /// “MIN” on reference-style duration chips
    static var brandDurationMinLabel: Font { scaledRounded(size: 11, weight: .semibold) }
    
    /// Large stat numbers — 48pt bold rounded
    static var brandNumber: Font { scaledRounded(size: 48, weight: .bold) }
    
    /// Medium numbers — 32pt medium rounded
    static var brandNumberMedium: Font { scaledRounded(size: 32, weight: .medium) }
    
    /// Timer / large countdown — 56pt bold rounded
    static var brandTimer: Font { scaledRounded(size: 56, weight: .bold) }
}
