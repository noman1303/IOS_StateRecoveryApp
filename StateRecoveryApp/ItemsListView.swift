//
//  ItemsListView.swift
//  StateRecoveryApp
//
//  Created by Noman belim on 29/01/26.
//
 
import SwiftUI

struct ItemsListView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var scrollOffset: CGFloat = 0
    @State private var scrollViewID = UUID()
    
    private let screenId = "ItemsListView"
    
    var filteredItems: [Item] {
        var items = appState.items
        
        if !searchText.isEmpty {
            items = items.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        return items.sorted { $0.createdAt > $1.createdAt }
    }
    
    var categories: [String] {
        Array(Set(appState.items.map { $0.category })).sorted()
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            List {
                // Category filter
                if !categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(categories, id: \.self) { category in
                                FilterChip(
                                    title: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                // Items list
                ForEach(filteredItems) { item in
                    NavigationLink(value: NavigationDestination.itemDetail(itemId: item.id)) {
                        ItemRowView(item: item)
                    }
                    .id(item.id)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Items")
            .searchable(text: $searchText, prompt: "Search items...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appState.navigationPath.append(.addItem)
                    } label: {
                        Image(systemName: "plus")
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
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = filteredItems[index]
            appState.deleteItem(item)
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
        // In a real implementation, you would track the actual scroll offset
        // For this demo, we'll save the first visible item
        if let firstItem = filteredItems.first {
            let position = ScrollPosition(offset: 0, itemId: firstItem.id)
            appState.saveScrollPosition(position, for: screenId)
        }
    }
}

struct ItemRowView: View {
    let item: Item
    @EnvironmentObject var appState: AppStateManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.title)
                    .font(.headline)
                
                Spacer()
                
                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(item.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                
                Spacer()
                
                Text(item.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                appState.deleteItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                var updatedItem = item
                updatedItem.isFavorite.toggle()
                appState.updateItem(updatedItem)
            } label: {
                Label("Favorite", systemImage: item.isFavorite ? "star.slash" : "star.fill")
            }
            .tint(.yellow)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    NavigationStack {
        ItemsListView()
            .environmentObject(AppStateManager.shared)
    }
}
