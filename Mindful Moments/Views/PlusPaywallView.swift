//
//  PlusPaywallView.swift
//  Mindful Moments
//
//  Subscription paywall for Mindful Moments Plus
//

import SwiftUI
import StoreKit

struct PlusPaywallView: View {
    let subscriptionManager: SubscriptionManager
    var onDismiss: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PaywallPlan = .annual

    private enum PaywallPlan {
        case monthly
        case annual
    }

    private var isDark: Bool { colorScheme == .dark }

    private var gradientColors: [Color] {
        if isDark {
            return [
                Color(red: 0.12, green: 0.16, blue: 0.32),
                Color(red: 0.08, green: 0.28, blue: 0.38)
            ]
        }
        return [
            Color(red: 0.36, green: 0.64, blue: 0.94),
            Color(red: 0.22, green: 0.64, blue: 0.66)
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    benefitsSection
                    planSection
                    purchaseSection
                    footerSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            }
            .background {
                LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        close()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.appScaledSystem(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.white.opacity(0.18)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .task {
            await subscriptionManager.loadProducts()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(isDark ? 0.14 : 0.28))
                    .frame(width: 88, height: 88)
                Image(systemName: "sparkles")
                    .font(.appScaledSystem(size: 38, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text("Mindful Moments Plus")
                .font(.appScaledSystem(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("New guided themes and ambient sounds. Everything you already love stays free.")
                .font(.appScaledSystem(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))
                .multilineTextAlignment(.center)
        }
    }

    private var benefitsSection: some View {
        VStack(spacing: 12) {
            benefitRow(icon: "heart.circle.fill", title: "Self-Compassion", subtitle: "5, 10 & 15 min · Dominic & Mira")
            benefitRow(icon: "figure.mind.and.body", title: "Body Scan", subtitle: "5, 10 & 15 min · Dominic & Mira")
            benefitRow(icon: "waveform", title: "Theme ambient sounds", subtitle: "Matched background audio for Plus themes")
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(isDark ? 0.1 : 0.18))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
        }
    }

    private func benefitRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.appScaledSystem(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.appScaledSystem(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.appScaledSystem(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.78))
            }

            Spacer(minLength: 0)
        }
    }

    private var planSection: some View {
        VStack(spacing: 12) {
            if let annual = subscriptionManager.annualProduct {
                planButton(
                    plan: .annual,
                    title: "Annual",
                    price: annual.displayPrice,
                    badge: savingsBadge(monthly: subscriptionManager.monthlyProduct, annual: annual)
                )
            }

            if let monthly = subscriptionManager.monthlyProduct {
                planButton(
                    plan: .monthly,
                    title: "Monthly",
                    price: monthly.displayPrice,
                    badge: nil
                )
            }

            if subscriptionManager.monthlyProduct == nil && subscriptionManager.annualProduct == nil {
                SwiftUI.ProgressView()
                    .tint(.white)
                    .padding(.vertical, 12)
            }
        }
    }

    private func planButton(plan: PaywallPlan, title: String, price: String, badge: String?) -> some View {
        let isSelected = selectedPlan == plan

        return Button {
            HapticManager.selection()
            selectedPlan = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.appScaledSystem(size: 17, weight: .semibold, design: .rounded))
                        if let badge {
                            Text(badge)
                                .font(.appScaledSystem(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.1, green: 0.35, blue: 0.2))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color(red: 0.75, green: 1.0, blue: 0.82)))
                        }
                    }
                    Text("\(price) / \(plan == .annual ? "year" : "month")")
                        .font(.appScaledSystem(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.appScaledSystem(size: 22, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .foregroundStyle(.white)
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.22) : Color.white.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(isSelected ? 0.55 : 0.2), lineWidth: isSelected ? 2 : 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    private var purchaseSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await purchaseSelectedPlan() }
            } label: {
                Group {
                    if subscriptionManager.isLoading {
                        SwiftUI.ProgressView()
                            .tint(Color(red: 0.08, green: 0.35, blue: 0.72))
                    } else {
                        Text("Continue")
                            .font(.appScaledSystem(size: 17, weight: .bold, design: .rounded))
                    }
                }
                .foregroundStyle(Color(red: 0.08, green: 0.35, blue: 0.72))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    Capsule(style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                }
            }
            .buttonStyle(SpringScaleButtonStyle())
            .disabled(selectedProduct == nil || subscriptionManager.isLoading)

            if let error = subscriptionManager.purchaseError {
                Text(error)
                    .font(.appScaledSystem(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var footerSection: some View {
        VStack(spacing: 14) {
            Button("Restore Purchases") {
                Task {
                    await subscriptionManager.restorePurchases()
                    if subscriptionManager.isPlusActive {
                        close()
                    }
                }
            }
            .font(.appScaledSystem(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.white.opacity(0.9))
            .buttonStyle(.plain)

            Text("Payment will be charged to your Apple ID. Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period.")
                .font(.appScaledSystem(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
            }
            .font(.appScaledSystem(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var selectedProduct: Product? {
        switch selectedPlan {
        case .monthly: return subscriptionManager.monthlyProduct
        case .annual: return subscriptionManager.annualProduct
        }
    }

    private func purchaseSelectedPlan() async {
        guard let product = selectedProduct else { return }
        HapticManager.medium()
        let success = await subscriptionManager.purchase(product)
        if success {
            close()
        }
    }

    private func savingsBadge(monthly: Product?, annual: Product) -> String? {
        guard let monthly else { return "Best value" }
        let monthlyAnnualized = monthly.price * 12
        if annual.price < monthlyAnnualized {
            return "Best value"
        }
        return nil
    }

    private func close() {
        if let onDismiss {
            onDismiss()
        } else {
            dismiss()
        }
    }
}

#Preview {
    PlusPaywallView(subscriptionManager: SubscriptionManager())
}
