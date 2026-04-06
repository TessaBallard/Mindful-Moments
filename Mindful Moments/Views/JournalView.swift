//
//  JournalView.swift
//  Mindful Moments
//
//  Journal entries list view
//

import SwiftUI

struct JournalView: View {
    let journalStore: JournalStore
    let sessionStore: SessionStore
    @State private var showingNewEntry = false
    @State private var showContent = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    if journalStore.entries.isEmpty {
                        EmptyJournalView()
                    } else {
                        VStack(spacing: 16) {
                            ForEach(Array(journalStore.entries.prefix(30).enumerated()), id: \.element.id) { index, entry in
                                JournalEntryCard(entry: entry, journalStore: journalStore)
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: journalStore.entries)
                            }
                            
                            if journalStore.entries.count > 30 {
                                Text("Showing 30 most recent of \(journalStore.entries.count) entries")
                                    .font(.brandCaption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            .opacity(showContent ? 1.0 : 0.0)
            .offset(y: showContent ? 0 : 20)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Journal")
                    .font(.brandLargeTitle)
                    .foregroundStyle(.primary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    HapticManager.selection()
                    showingNewEntry = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.appScaledSystem(size: 24, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
        }
        .background(
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(red: 0.000, green: 0.243, blue: 0.224), Color(red: 0.000, green: 0.784, blue: 0.702)]
                    : [Color(red: 0.000, green: 0.784, blue: 0.702), Color(red: 0.600, green: 0.902, blue: 0.871)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showingNewEntry) {
            NewJournalEntryView(journalStore: journalStore, sessionStore: sessionStore)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
}

struct EmptyJournalView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.appScaledSystem(size: 48, design: .rounded))
                .foregroundStyle(.secondary)
            
            Text("No journal entries yet")
                .font(.brandTitle2)
                .foregroundStyle(.primary)
            
            Text("Tap the + button to add your first reflection")
                .font(.brandSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 60)
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let journalStore: JournalStore
    @Environment(\.colorScheme) private var colorScheme
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formattedDate)
                    .font(.brandCaption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if let themeName = entry.themeName {
                    HStack(spacing: 6) {
                        Image(systemName: entry.themeIcon ?? "leaf.fill")
                            .font(.appScaledSystem(size: 12, design: .rounded))
                        
                        Text(themeName)
                            .font(.appScaledSystem(size: 12, design: .rounded))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.primary.opacity(0.1))
                    )
                }
            }
            
            Text(entry.content)
                .font(.brandBody)
                .foregroundStyle(.primary)
                .lineLimit(4)
        }
        .padding(16)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                        lineWidth: 1
                    )
            }
        }
        .cornerRadius(16)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.08), radius: 8, x: 0, y: 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    journalStore.deleteEntry(entry)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        JournalView(journalStore: JournalStore(), sessionStore: SessionStore())
    }
}
