//
//  Fonts.swift
//  Mindful Moments
//
//  App typography: SF Pro Rounded (aligned with meditation duration chips).
//

import SwiftUI

extension Font {
    // MARK: - Display
    
    /// Large title — 34pt bold rounded
    static let brandLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    
    /// Title — 28pt bold rounded
    static let brandTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    
    /// Title 2 — 22pt medium rounded
    static let brandTitle2 = Font.system(size: 22, weight: .medium, design: .rounded)
    
    /// Title 3 — 20pt medium rounded (player / section headers)
    static let brandTitle3 = Font.system(size: 20, weight: .medium, design: .rounded)
    
    /// Navigation title — 34pt bold rounded
    static let brandNavigationTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    
    // MARK: - Body
    
    /// Headline — 17pt medium rounded
    static let brandHeadline = Font.system(size: 17, weight: .medium, design: .rounded)
    
    /// Subheadline — 15pt regular rounded
    static let brandSubheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    
    /// Body — 16pt regular rounded
    static let brandBody = Font.system(size: 16, weight: .regular, design: .rounded)
    
    /// Caption — 12pt regular rounded
    static let brandCaption = Font.system(size: 12, weight: .regular, design: .rounded)
    
    // MARK: - Numbers & chips (meditation detail duration row)
    
    /// Digits on reference-style duration chips (5 / 10 / 15)
    static let brandDurationDigit = Font.system(size: 35, weight: .bold, design: .rounded)
    
    /// “MIN” on reference-style duration chips
    static let brandDurationMinLabel = Font.system(size: 11, weight: .semibold, design: .rounded)
    
    /// Large stat numbers — 48pt bold rounded
    static let brandNumber = Font.system(size: 48, weight: .bold, design: .rounded)
    
    /// Medium numbers — 32pt medium rounded
    static let brandNumberMedium = Font.system(size: 32, weight: .medium, design: .rounded)
    
    /// Timer / large countdown — 56pt bold rounded
    static let brandTimer = Font.system(size: 56, weight: .bold, design: .rounded)
}
