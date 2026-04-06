//
//  MoodCheckInView.swift
//  Mindful Moments
//
//  Mood check-in interface (before and after meditation)
//

import SwiftUI

enum MoodTiming {
    case before
    case after
}

struct MoodCheckInView: View {
    let timing: MoodTiming
    let onMoodSelected: (Mood) -> Void
    let onSkip: () -> Void
    
    @State private var selectedMood: Mood?
    @State private var showContent = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private static let darkCanvas = Color(red: 18 / 255, green: 30 / 255, blue: 42 / 255)
    private static let accentBlue = Color(red: 100 / 255, green: 181 / 255, blue: 246 / 255)
    /// Header icon color #7fb3e5 (outline / glyph)
    private static let checkInHeaderIconBlue = Color(red: 127 / 255, green: 179 / 255, blue: 229 / 255)
    private static let mutedBlueGray = Color(red: 142 / 255, green: 154 / 255, blue: 165 / 255)
    private static let lightGradientTop = Color(red: 230 / 255, green: 242 / 255, blue: 1)
    private static let continueGradientStart = Color(red: 124 / 255, green: 77 / 255, blue: 1)
    private static let continueGradientEnd = Color(red: 232 / 255, green: 64 / 255, blue: 218 / 255)
    
    private var title: String {
        timing == .before ? "How are you feeling?" : "How do you feel now?"
    }
    
    private var subtitle: String {
        timing == .before
            ? "Let's check in before we begin"
            : "Notice any shifts after your practice"
    }
    
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        ZStack {
            checkInBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        HapticManager.light()
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(isDark ? Color.white : Color(red: 0.35, green: 0.38, blue: 0.42))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(isDark ? Color.black.opacity(0.38) : Color.black.opacity(0.06))
                            }
                            .overlay {
                                Capsule(style: .continuous)
                                    .stroke(isDark ? Color.white.opacity(0.18) : Color.clear, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                GeometryReader { geo in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            Spacer(minLength: 0)
                            
                            MoodCheckInHeaderMark(tint: Self.checkInHeaderIconBlue)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : -12)
                                .animation(.spring(response: 0.55, dampingFraction: 0.78), value: showContent)
                            
                            VStack(spacing: 10) {
                                Text(title)
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundStyle(isDark ? Color.white : Color.black)
                                    .multilineTextAlignment(.center)
                                
                                Text(subtitle)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundStyle(isDark ? Self.mutedBlueGray : Color(red: 0.45, green: 0.48, blue: 0.52))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 28)
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : -14)
                            .animation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.06), value: showContent)
                            
                            LazyVGrid(
                                columns: [
                                    GridItem(.flexible(), spacing: 6),
                                    GridItem(.flexible(), spacing: 6),
                                    GridItem(.flexible(), spacing: 6),
                                    GridItem(.flexible(), spacing: 6)
                                ],
                                spacing: 10
                            ) {
                                ForEach(Array(Mood.checkInMoods.enumerated()), id: \.element.id) { index, mood in
                                    MoodCard(
                                        mood: mood,
                                        isSelected: selectedMood == mood,
                                        onTap: {
                                            HapticManager.selection()
                                            selectedMood = mood
                                        }
                                    )
                                    .opacity(showContent ? 1 : 0)
                                    .scaleEffect(showContent ? 1 : 0.92)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.78)
                                            .delay(0.12 + Double(index) * 0.04),
                                        value: showContent
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            
                            Spacer(minLength: 0)
                        }
                        .frame(minHeight: geo.size.height)
                        .frame(maxWidth: .infinity)
                    }
                }
                
                VStack(spacing: 14) {
                    Button(action: {
                        HapticManager.medium()
                        if let mood = selectedMood {
                            onMoodSelected(mood)
                        }
                    }) {
                        HStack(spacing: 8) {
                            if let m = selectedMood {
                                Text(m.emoji)
                                    .font(.system(size: 20, design: .rounded))
                            }
                            Text("Continue")
                                .font(.brandHeadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background {
                            if selectedMood != nil {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Self.continueGradientStart, Self.continueGradientEnd],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .fill(isDark ? Color.white.opacity(0.12) : Color.black.opacity(0.12))
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .shadow(
                            color: selectedMood != nil ? Self.continueGradientStart.opacity(0.35) : .clear,
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedMood == nil)
                    
                    Button(action: {
                        HapticManager.light()
                        onSkip()
                    }) {
                        Text("Skip")
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundStyle(Self.accentBlue)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.78).delay(0.35), value: showContent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            showContent = true
        }
    }
    
    @ViewBuilder
    private var checkInBackground: some View {
        if isDark {
            Self.darkCanvas
        } else {
            LinearGradient(
                colors: [Self.lightGradientTop, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

/// Outline page + filled heart and “text” bars, all using `#7fb3e5` for strokes and fills (per design).
private struct MoodCheckInHeaderMark: View {
    var tint: Color
    
    private let pageWidth: CGFloat = 48
    private let pageHeight: CGFloat = 56
    private let pageCorner: CGFloat = 10
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: pageCorner, style: .continuous)
                .stroke(tint, lineWidth: 2.5)
                .frame(width: pageWidth, height: pageHeight)
            
            Image(systemName: "heart.fill")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(tint)
                .offset(x: 9, y: 9)
            
            VStack(alignment: .leading, spacing: 5) {
                Capsule(style: .continuous)
                    .fill(tint)
                    .frame(width: 26, height: 4)
                Capsule(style: .continuous)
                    .fill(tint)
                    .frame(width: 17, height: 4)
            }
            .offset(x: 9, y: 29)
        }
        .frame(width: pageWidth, height: pageHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Mood check-in")
    }
}

struct MoodCard: View {
    let mood: Mood
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    private static let darkCardFill = Color(red: 44 / 255, green: 53 / 255, blue: 63 / 255)
    private static let selectionPurple = Color(red: 124 / 255, green: 77 / 255, blue: 1)
    private static let selectionMagenta = Color(red: 218 / 255, green: 64 / 255, blue: 232 / 255)
    private static let mutedBlueGray = Color(red: 142 / 255, green: 154 / 255, blue: 165 / 255)
    
    private var isDark: Bool { colorScheme == .dark }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(mood.emoji)
                    .font(.system(size: 28, design: .rounded))
                
                Text(mood.displayName)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(isDark ? Color.white : Color.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(mood.description)
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundStyle(isDark ? Self.mutedBlueGray : Color(red: 0.45, green: 0.48, blue: 0.52))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(cardFill)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(borderStroke, lineWidth: isSelected ? 2 : 1)
            }
            .shadow(
                color: shadowColor,
                radius: isSelected ? 14 : 6,
                x: 0,
                y: isSelected ? 8 : 3
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mood.displayName)
        .accessibilityHint("Select \(mood.displayName): \(mood.description)")
    }
    
    private var cardFill: Color {
        if isSelected {
            if isDark {
                return Self.darkCardFill.opacity(0.95)
            }
            return Color.white.opacity(0.88)
        }
        if isDark {
            return Self.darkCardFill
        }
        return Color.white.opacity(0.55)
    }
    
    private var borderStroke: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Self.selectionPurple, Self.selectionMagenta],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        if isDark {
            return AnyShapeStyle(Color.white.opacity(0.08))
        }
        return AnyShapeStyle(Color.black.opacity(0.06))
    }
    
    private var shadowColor: Color {
        if isSelected {
            return Self.selectionPurple.opacity(isDark ? 0.45 : 0.35)
        }
        return Color.black.opacity(isDark ? 0.35 : 0.07)
    }
}

#Preview("Before — Light") {
    NavigationStack {
        MoodCheckInView(
            timing: .before,
            onMoodSelected: { _ in },
            onSkip: {}
        )
    }
}

#Preview("Before — Dark") {
    NavigationStack {
        MoodCheckInView(
            timing: .before,
            onMoodSelected: { _ in },
            onSkip: {}
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("After — Dark") {
    NavigationStack {
        MoodCheckInView(
            timing: .after,
            onMoodSelected: { _ in },
            onSkip: {}
        )
    }
    .preferredColorScheme(.dark)
}
