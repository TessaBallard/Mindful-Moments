//
//  SubscriptionManager.swift
//  Mindful Moments
//
//  StoreKit 2 subscription management for Mindful Moments Plus
//

import Foundation
import StoreKit

enum PlusProductID {
    static let monthly = "com.tessaballard.Mindful_Moments_plus.monthly"
    static let annual = "com.tessaballard.Mindful_Moments.plus.annual"
    static let all = [monthly, annual]
}

@Observable
@MainActor
final class SubscriptionManager {
    var isPlusActive = false
    var monthlyProduct: Product?
    var annualProduct: Product?
    var isLoading = false
    var purchaseError: String?

    init() {
        Task { await listenForTransactions() }
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: PlusProductID.all)
            monthlyProduct = products.first { $0.id == PlusProductID.monthly }
            annualProduct = products.first { $0.id == PlusProductID.annual }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        if monthlyProduct == nil || annualProduct == nil {
            await loadProducts()
        }

        var hasPlus = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if grantsPlusAccess(transaction) {
                hasPlus = true
                break
            }
        }

        if !hasPlus {
            hasPlus = await hasActiveSubscriptionStatus()
        }

        isPlusActive = hasPlus
    }

    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                let unlocked = grantsPlusAccess(transaction)
                if unlocked {
                    isPlusActive = true
                }
                await transaction.finish()
                await refreshEntitlements()
                return isPlusActive
            case .userCancelled:
                return false
            case .pending:
                purchaseError = "Purchase is pending approval."
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }

    func restorePurchases() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if !isPlusActive {
                purchaseError = "No active Plus subscription found."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard let transaction = try? checkVerified(result) else { continue }
            if grantsPlusAccess(transaction) {
                isPlusActive = true
            }
            await transaction.finish()
            await refreshEntitlements()
        }
    }

    private func grantsPlusAccess(_ transaction: StoreKit.Transaction) -> Bool {
        guard PlusProductID.all.contains(transaction.productID) else { return false }
        if transaction.revocationDate != nil { return false }
        if let expirationDate = transaction.expirationDate {
            return expirationDate > Date()
        }
        return true
    }

    private func hasActiveSubscriptionStatus() async -> Bool {
        for product in [monthlyProduct, annualProduct].compactMap({ $0 }) {
            guard let subscription = product.subscription else { continue }
            guard let statuses = try? await subscription.status else { continue }
            for status in statuses {
                if isActiveSubscriptionState(status.state) {
                    return true
                }
            }
        }
        return false
    }

    private func isActiveSubscriptionState(_ state: Product.SubscriptionInfo.RenewalState) -> Bool {
        switch state {
        case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
            return true
        default:
            return false
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
