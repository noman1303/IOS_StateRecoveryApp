//
//  NotesListView.swift
//  StateRecoveryApp
//
//  Created by Noman belim on 29/01/26.
//
 

import SwiftUI

struct NotesListView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var searchText = ""
    @State private var selectedTag: String?
    @State private var scrollOffset: CGFloat = 0
    
    private let screenId = "NotesListView"
    
    var filteredNotes: [Note] {
        var notes = appState.notes
        
        if !searchText.isEmpty {
            notes = notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let tag = selectedTag {
            notes = notes.filter { $0.tags.contains(tag) }
        }
        
        return notes.sorted { $0.modifiedAt > $1.modifiedAt }
    }
    
    var allTags: [String] {
        let tags = appState.notes.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                // Tag filter
                if !allTags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedTag == nil,
                                action: { selectedTag = nil }
                            )
                            
                            ForEach(allTags, id: \.self) { tag in
                                FilterChip(
                                    title: "#\(tag)",
                                    isSelected: selectedTag == tag,
                                    action: { selectedTag = tag }
                                )
                            }
                        }
                        .padding()
                    }
                    .background(Color(uiColor: .systemBackground))
                }
                
                // Notes list
                List {
                    ForEach(filteredNotes) { note in
                        NavigationLink(value: NavigationDestination.noteDetail(noteId: note.id)) {
                            NoteRowView(note: note)
                        }
                        .id(note.id)
                    }
                    .onDelete(perform: deleteNotes)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText, prompt: "Search notes...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appState.navigationPath.append(.addNote)
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .onAppear {
                restoreScrollPosition(proxy: proxy)
            }
            .onDisappear {
                saveScrollPosition()
            }
        }
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = filteredNotes[index]
            appState.deleteNote(note)
        }
    }
    
    private func restoreScrollPosition(proxy: ScrollViewProxy) {
        if let savedPosition = appState.getScrollPosition(for: screenId),
           let itemId = savedPosition.itemId {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    proxy.scrollTo(itemId, anchor: .top)
                }
            }
        }
    }
    
    private func saveScrollPosition() {
        if let firstNote = filteredNotes.first {
            let position = ScrollPosition(offset: 0, itemId: firstNote.id)
            appState.saveScrollPosition(position, for: screenId)
        }
    }
}

struct NoteRowView: View {
    let note: Note
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.headline)
            
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                if !note.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(note.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Text(note.modifiedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                appState.deleteNote(note)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotesListView()
            .environmentObject(AppStateManager.shared)
    }
}
