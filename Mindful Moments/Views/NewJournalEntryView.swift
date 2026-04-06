//
//  NewJournalEntryView.swift
//  Mindful Moments
//
//  New journal entry creation view
//

import SwiftUI

struct NewJournalEntryView: View {
    let journalStore: JournalStore
    let sessionStore: SessionStore
    
    @State private var entryText = ""
    @State private var linkedSession: MeditationSession?
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private let maxCharacters = 2000
    
    private var charactersRemaining: Int {
        maxCharacters - entryText.count
    }
    
    private var isNearLimit: Bool {
        charactersRemaining <= 100 && charactersRemaining > 0
    }
    
    private var isAtLimit: Bool {
        charactersRemaining <= 0
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TextEditor(text: Binding(
                    get: { entryText },
                    set: { newValue in
                        if newValue.count <= maxCharacters {
                            entryText = newValue
                        }
                    }
                ))
                .font(.brandBody)
                .padding()
                .focused($isTextFieldFocused)
                .scrollContentBackground(.hidden)
                
                HStack {
                    Text("\(entryText.count) / \(maxCharacters) characters")
                        .font(.brandCaption)
                        .foregroundStyle(isAtLimit ? .red : isNearLimit ? .orange : .secondary)
                    
                    if isAtLimit {
                        Text("• Character limit reached")
                            .font(.brandCaption)
                            .foregroundStyle(.red)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            .onAppear {
                linkedSession = sessionStore.mostRecentSession
                isTextFieldFocused = true
            }
        }
    }
    
    private func saveEntry() {
        let entry = JournalEntry(
            text: entryText,
            themeName: linkedSession?.themeName,
            themeIcon: linkedSession?.themeIcon
        )
        journalStore.addEntry(entry)
        HapticManager.success()
        dismiss()
    }
}

#Preview {
    NewJournalEntryView(journalStore: JournalStore(), sessionStore: SessionStore())
}
