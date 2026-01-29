//
//  ItemDetailView.swift
//  StateRecoveryApp
//
//  Created by Noman belim on 29/01/26.
//
 
import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @EnvironmentObject var appState: AppStateManager
    @State private var isEditing = false
    @State private var editedItem: Item
    @State private var scrollOffset: CGFloat = 0
    
    private var screenId: String {
        "ItemDetailView-\(item.id)"
    }
    
    init(item: Item) {
        self.item = item
        _editedItem = State(initialValue: item)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(item.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                var updatedItem = item
                                updatedItem.isFavorite.toggle()
                                appState.updateItem(updatedItem)
                            } label: {
                                Image(systemName: item.isFavorite ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundColor(item.isFavorite ? .yellow : .gray)
                            }
                        }
                        
                        Text(item.category)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        
                        Text("Created: \(item.createdAt.formatted(date: .long, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .id("header")
                    
                    // Description section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Description")
                            .font(.headline)
                        
                        Text(item.description)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .id("description")
                    
                    // Additional details
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                        
                        DetailRow(title: "ID", value: item.id)
                        DetailRow(title: "Status", value: item.isFavorite ? "Favorite" : "Regular")
                        DetailRow(title: "Category", value: item.category)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .id("details")
                    
                    // Related content placeholder
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Related Items")
                            .font(.headline)
                        
                        ForEach(relatedItems, id: \.id) { relatedItem in
                            NavigationLink(value: NavigationDestination.itemDetail(itemId: relatedItem.id)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(relatedItem.title)
                                            .font(.subheadline)
                                            .foregroundColor(.primary)
                                        Text(relatedItem.category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
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
                    
                    // Long content to demonstrate scroll restoration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Additional Information")
                            .font(.headline)
                        
                        ForEach(1...10, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Section \(index)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("This is additional content for section \(index). In a real app, this would contain meaningful information about the item. The purpose here is to demonstrate scroll position restoration when navigating away and back.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .id("section-\(index)")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                EditItemView(item: editedItem) { updatedItem in
                    appState.updateItem(updatedItem)
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
    
    private var relatedItems: [Item] {
        appState.items.filter { $0.category == item.category && $0.id != item.id }.prefix(3).map { $0 }
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
        // Save current scroll state
        let position = ScrollPosition(offset: scrollOffset, itemId: "section-5")
        appState.saveScrollPosition(position, for: screenId)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(item: Item.sampleData[0])
            .environmentObject(AppStateManager.shared)
    }
}
