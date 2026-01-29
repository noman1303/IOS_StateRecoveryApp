//
//  ContentView.swift
//  StateRecoveryApp
//
//  Created by Noman belim on 29/01/26.
//
 
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $appState.navigationPath) {
                ItemsListView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Items", systemImage: "square.grid.2x2")
            }
            .tag(0)
            
            NavigationStack {
                NotesListView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("Notes", systemImage: "note.text")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .itemDetail(let itemId):
            if let item = appState.items.first(where: { $0.id == itemId }) {
                ItemDetailView(item: item)
            } else {
                Text("Item not found")
            }
            
        case .noteDetail(let noteId):
            if let note = appState.notes.first(where: { $0.id == noteId }) {
                NoteDetailView(note: note)
            } else {
                Text("Note not found")
            }
            
        case .settings:
            SettingsView()
            
        case .addItem:
            AddItemView()
            
        case .addNote:
            AddNoteView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppStateManager.shared)
}
