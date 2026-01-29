//
//  NoteDetailView.swift
//  StateRecoveryApp
//
//  Created by Noman belim on 29/01/26.
//
 

import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @EnvironmentObject var appState: AppStateManager
    @State private var isEditing = false
    @State private var scrollOffset: CGFloat = 0
    
    private var screenId: String {
        "NoteDetailView-\(note.id)"
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(note.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("Modified: \(note.modifiedAt.formatted(date: .long, time: .shortened))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Created: \(note.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if !note.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(note.tags, id: \.self) { tag in
                                        Text("#\(tag)")
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.green.opacity(0.2))
                                            .foregroundColor(.green)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .id("header")
                    
                    // Content
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Content")
                            .font(.headline)
                        
                        Text(note.content)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .id("content")
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Statistics")
                            .font(.headline)
                        
                        HStack {
                            StatisticView(
                                icon: "character",
                                label: "Characters",
                                value: "\(note.content.count)"
                            )
                            
                            StatisticView(
                                icon: "text.word.spacing",
                                label: "Words",
                                value: "\(note.content.split(separator: " ").count)"
                            )
                            
                            StatisticView(
                                icon: "tag",
                                label: "Tags",
                                value: "\(note.tags.count)"
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .id("stats")
                    
                    // Related notes
                    if !relatedNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Notes")
                                .font(.headline)
                            
                            ForEach(relatedNotes, id: \.id) { relatedNote in
                                NavigationLink(value: NavigationDestination.noteDetail(noteId: relatedNote.id)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(relatedNote.title)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                            
                                            Text(relatedNote.content.prefix(50) + "...")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .id("related")
                    }
                }
                .padding()
            }
            .navigationTitle("Note Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                EditNoteView(note: note) { updatedNote in
                    appState.updateNote(updatedNote)
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
    
    private var relatedNotes: [Note] {
        appState.notes.filter { otherNote in
            otherNote.id != note.id &&
            !Set(otherNote.tags).isDisjoint(with: Set(note.tags))
        }.prefix(3).map { $0 }
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
        let position = ScrollPosition(offset: scrollOffset, itemId: "content")
        appState.saveScrollPosition(position, for: screenId)
    }
}

struct StatisticView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        NoteDetailView(note: Note.sampleData[0])
            .environmentObject(AppStateManager.shared)
    }
}
