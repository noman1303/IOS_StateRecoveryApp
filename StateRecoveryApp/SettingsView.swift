//
//  SettingsView.swift
//  StateRecoveryApp
//
//  Created by Noman belim on 29/01/26.
//
 
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showResetAlert = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        List {
            Section("State Recovery") {
                HStack {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Automatic State Recovery")
                            .font(.headline)
                        Text("App restores your position when reopened")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                NavigationLink {
                    StateInfoView()
                } label: {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("How It Works")
                    }
                }
            }
            
            Section("Current State") {
                StateDetailRow(
                    icon: "square.stack.3d.up",
                    title: "Navigation Stack",
                    value: "\(appState.navigationPath.count) screen(s)"
                )
                
                StateDetailRow(
                    icon: "tray.fill",
                    title: "Items",
                    value: "\(appState.items.count)"
                )
                
                StateDetailRow(
                    icon: "note.text",
                    title: "Notes",
                    value: "\(appState.notes.count)"
                )
                
                StateDetailRow(
                    icon: "scroll",
                    title: "Scroll Positions",
                    value: "\(appState.scrollPositions.count) saved"
                )
            }
            
            Section("Actions") {
                Button {
                    appState.saveState()
                    showSuccessAlert = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.blue)
                        Text("Save State Now")
                            .foregroundColor(.primary)
                    }
                }
                
                Button {
                    appState.restoreState()
                    showSuccessAlert = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.green)
                        Text("Restore State Now")
                            .foregroundColor(.primary)
                    }
                }
                
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Reset All State")
                    }
                }
            }
            
            Section("Features Demonstrated") {
                FeatureRow(
                    icon: "arrow.triangle.turn.up.right.diamond",
                    title: "Screen Stack Restoration",
                    description: "Navigation history is preserved across app launches"
                )
                
                FeatureRow(
                    icon: "cylinder.fill",
                    title: "Data Restoration",
                    description: "All items and notes are saved automatically"
                )
                
                FeatureRow(
                    icon: "arrow.up.and.down.text.horizontal",
                    title: "Scroll Position Recovery",
                    description: "Lists remember where you left off"
                )
            }
            
            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2025.01")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Operation completed successfully")
        }
        .alert("Reset All State?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appState.resetAllState()
            }
        } message: {
            Text("This will clear all saved data and navigation history. This action cannot be undone.")
        }
    }
}

struct StateDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.title3)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct StateInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                InfoSection(
                    icon: "arrow.triangle.turn.up.right.diamond",
                    title: "Screen Stack Restoration",
                    description: "The app remembers which screens you had open and restores them exactly as they were.",
                    details: [
                        "Navigation path is saved automatically",
                        "Deep links are preserved",
                        "Modal presentations are restored",
                        "Tab selection is remembered"
                    ]
                )
                
                InfoSection(
                    icon: "cylinder.fill",
                    title: "Data Restoration",
                    description: "All your data is automatically saved and restored when you reopen the app.",
                    details: [
                        "Items and notes are persisted",
                        "User preferences are saved",
                        "Draft content is preserved",
                        "Changes are saved in real-time"
                    ]
                )
                
                InfoSection(
                    icon: "arrow.up.and.down.text.horizontal",
                    title: "Scroll Position Recovery",
                    description: "Lists remember exactly where you were scrolling when you left.",
                    details: [
                        "Scroll positions are tracked per screen",
                        "Works across all list views",
                        "Restores smoothly on return",
                        "Independent for each view"
                    ]
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Technical Implementation")
                        .font(.headline)
                    
                    Text("This app uses UserDefaults for persistence and SwiftUI's NavigationStack with a path binding for navigation state management. Scroll positions are tracked using ScrollViewReader and saved to a dictionary keyed by screen identifier.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("How It Works")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoSection: View {
    let icon: String
    let title: String
    let description: String
    let details: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(details, id: \.self) { detail in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text(detail)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppStateManager.shared)
    }
}
