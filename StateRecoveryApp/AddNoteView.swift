//
//  AddNoteView.swift
//  StateRecoveryApp
//
//  Created by Noman belim on 29/01/26.
//
 

import SwiftUI

struct AddNoteView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var tagInput = ""
    @State private var tags: [String] = []
    
    var body: some View {
        Form {
            Section("Note Information") {
                TextField("Title", text: $title)
                
                TextEditor(text: $content)
                    .frame(minHeight: 150)
                    .overlay(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("Enter note content...")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
            }
            
            Section("Tags") {
                HStack {
                    TextField("Add tag", text: $tagInput)
                        .textInputAutocapitalization(.never)
                    
                    Button("Add") {
                        addTag()
                    }
                    .disabled(tagInput.isEmpty)
                }
                
                if !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(tags, id: \.self) { tag in
                                HStack {
                                    Text("#\(tag)")
                                        .font(.subheadline)
                                    
                                    Button {
                                        removeTag(tag)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            
            Section {
                Button("Create Note") {
                    saveNote()
                }
                .disabled(title.isEmpty || content.isEmpty)
            }
        }
        .navigationTitle("New Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveNote() {
        let newNote = Note(
            title: title,
            content: content,
            tags: tags,
            createdAt: Date(),
            modifiedAt: Date()
        )
        
        appState.addNote(newNote)
        dismiss()
    }
}

struct EditNoteView: View {
    let note: Note
    let onSave: (Note) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var content: String
    @State private var tagInput = ""
    @State private var tags: [String]
    
    init(note: Note, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
        _tags = State(initialValue: note.tags)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Note Information") {
                    TextField("Title", text: $title)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                            .textInputAutocapitalization(.never)
                        
                        Button("Add") {
                            addTag()
                        }
                        .disabled(tagInput.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text("#\(tag)")
                                            .font(.subheadline)
                                        
                                        Button {
                                            removeTag(tag)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
    
    private func saveChanges() {
        var updatedNote = note
        updatedNote.title = title
        updatedNote.content = content
        updatedNote.tags = tags
        updatedNote.modifiedAt = Date()
        
        onSave(updatedNote)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddNoteView()
            .environmentObject(AppStateManager.shared)
    }
}
