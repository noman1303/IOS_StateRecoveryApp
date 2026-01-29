//
//  AddItemView.swift
//  StateRecoveryApp
//
//  Created by Noman belim on 29/01/26.
 

import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var category = "Development"
    @State private var isFavorite = false
    
    let categories = ["Development", "Design", "Education", "Business", "Personal"]
    
    var body: some View {
        Form {
            Section("Basic Information") {
                TextField("Title", text: $title)
                
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(3...6)
                
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                
                Toggle("Mark as Favorite", isOn: $isFavorite)
            }
            
            Section {
                Button("Add Item") {
                    saveItem()
                }
                .disabled(title.isEmpty)
            }
        }
        .navigationTitle("New Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    private func saveItem() {
        let newItem = Item(
            title: title,
            description: description,
            category: category,
            isFavorite: isFavorite,
            createdAt: Date()
        )
        
        appState.addItem(newItem)
        dismiss()
    }
}

struct EditItemView: View {
    let item: Item
    let onSave: (Item) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var category: String
    @State private var isFavorite: Bool
    
    let categories = ["Development", "Design", "Education", "Business", "Personal"]
    
    init(item: Item, onSave: @escaping (Item) -> Void) {
        self.item = item
        self.onSave = onSave
        
        _title = State(initialValue: item.title)
        _description = State(initialValue: item.description)
        _category = State(initialValue: item.category)
        _isFavorite = State(initialValue: item.isFavorite)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    Toggle("Mark as Favorite", isOn: $isFavorite)
                }
                
                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("Edit Item")
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
    
    private func saveChanges() {
        var updatedItem = item
        updatedItem.title = title
        updatedItem.description = description
        updatedItem.category = category
        updatedItem.isFavorite = isFavorite
        
        onSave(updatedItem)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddItemView()
            .environmentObject(AppStateManager.shared)
    }
}
