//
//  AppStateManager.swift
//  Manages app state persistence and restoration
//

import SwiftUI
import Combine

class AppStateManager: ObservableObject {
    static let shared = AppStateManager()
    
    // Navigation state
    @Published var navigationPath: [NavigationDestination] = []
    
    // Data state
    @Published var items: [Item] = []
    @Published var notes: [Note] = []
    
    // Scroll positions
    @Published var scrollPositions: [String: ScrollPosition] = [:]
    
    // User defaults keys
    private let navigationKey = "app.navigation.path"
    private let itemsKey = "app.data.items"
    private let notesKey = "app.data.notes"
    private let scrollKey = "app.scroll.positions"
    
    private init() {
        // Initialize with some default data if needed
        if items.isEmpty {
            items = Item.sampleData
        }
        if notes.isEmpty {
            notes = Note.sampleData
        }
    }
    
    // MARK: - State Persistence
    
    func saveState() {
        saveNavigationState()
        saveDataState()
        saveScrollPositions()
        print("✅ State saved successfully")
    }
    
    func restoreState() {
        restoreNavigationState()
        restoreDataState()
        restoreScrollPositions()
        print("✅ State restored successfully")
    }
    
    // MARK: - Navigation State
    
    private func saveNavigationState() {
        if let encoded = try? JSONEncoder().encode(navigationPath) {
            UserDefaults.standard.set(encoded, forKey: navigationKey)
        }
    }
    
    private func restoreNavigationState() {
        if let data = UserDefaults.standard.data(forKey: navigationKey),
           let decoded = try? JSONDecoder().decode([NavigationDestination].self, from: data) {
            navigationPath = decoded
        }
    }
    
    // MARK: - Data State
    
    private func saveDataState() {
        // Save items
        if let itemsEncoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(itemsEncoded, forKey: itemsKey)
        }
        
        // Save notes
        if let notesEncoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(notesEncoded, forKey: notesKey)
        }
    }
    
    private func restoreDataState() {
        // Restore items
        if let itemsData = UserDefaults.standard.data(forKey: itemsKey),
           let decodedItems = try? JSONDecoder().decode([Item].self, from: itemsData) {
            items = decodedItems
        }
        
        // Restore notes
        if let notesData = UserDefaults.standard.data(forKey: notesKey),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: notesData) {
            notes = decodedNotes
        }
    }
    
    // MARK: - Scroll Positions
    
    func saveScrollPosition(_ position: ScrollPosition, for screenId: String) {
        scrollPositions[screenId] = position
        saveScrollPositions()
    }
    
    func getScrollPosition(for screenId: String) -> ScrollPosition? {
        return scrollPositions[screenId]
    }
    
    private func saveScrollPositions() {
        if let encoded = try? JSONEncoder().encode(scrollPositions) {
            UserDefaults.standard.set(encoded, forKey: scrollKey)
        }
    }
    
    private func restoreScrollPositions() {
        if let data = UserDefaults.standard.data(forKey: scrollKey),
           let decoded = try? JSONDecoder().decode([String: ScrollPosition].self, from: data) {
            scrollPositions = decoded
        }
    }
    
    // MARK: - Data Operations
    
    func addItem(_ item: Item) {
        items.append(item)
        saveDataState()
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveDataState()
        }
    }
    
    func deleteItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
        saveDataState()
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveDataState()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveDataState()
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveDataState()
    }
    
    // MARK: - Reset
    
    func resetAllState() {
        navigationPath.removeAll()
        scrollPositions.removeAll()
        items = Item.sampleData
        notes = Note.sampleData
        
        UserDefaults.standard.removeObject(forKey: navigationKey)
        UserDefaults.standard.removeObject(forKey: scrollKey)
        UserDefaults.standard.removeObject(forKey: itemsKey)
        UserDefaults.standard.removeObject(forKey: notesKey)
        
        print("🔄 All state reset")
    }
}

// MARK: - Models

enum NavigationDestination: Codable, Hashable {
    case itemDetail(itemId: String)
    case noteDetail(noteId: String)
    case settings
    case addItem
    case addNote
}

struct ScrollPosition: Codable {
    var offset: CGFloat
    var itemId: String?
    
    init(offset: CGFloat = 0, itemId: String? = nil) {
        self.offset = offset
        self.itemId = itemId
    }
}

struct Item: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var category: String
    var isFavorite: Bool
    var createdAt: Date
    
    static var sampleData: [Item] {
        [
            Item(title: "SwiftUI Tutorial", description: "Learn the basics of SwiftUI development", category: "Education", isFavorite: true, createdAt: Date()),
            Item(title: "State Management", description: "Understanding state in SwiftUI applications", category: "Education", isFavorite: false, createdAt: Date()),
            Item(title: "Navigation Patterns", description: "Best practices for navigation in iOS apps", category: "Development", isFavorite: true, createdAt: Date()),
            Item(title: "Data Persistence", description: "Saving and loading app data effectively", category: "Development", isFavorite: false, createdAt: Date()),
            Item(title: "UI/UX Design", description: "Creating beautiful user interfaces", category: "Design", isFavorite: true, createdAt: Date()),
            Item(title: "Performance Tips", description: "Optimizing your SwiftUI applications", category: "Development", isFavorite: false, createdAt: Date()),
            Item(title: "Testing Strategies", description: "How to test SwiftUI views and logic", category: "Development", isFavorite: false, createdAt: Date()),
            Item(title: "Animation Guide", description: "Creating smooth animations in SwiftUI", category: "Design", isFavorite: true, createdAt: Date()),
            Item(title: "Accessibility", description: "Making apps accessible to everyone", category: "Design", isFavorite: false, createdAt: Date()),
            Item(title: "Swift Concurrency", description: "Modern async/await patterns", category: "Development", isFavorite: true, createdAt: Date()),
        ]
    }
}

struct Note: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var content: String
    var tags: [String]
    var createdAt: Date
    var modifiedAt: Date
    
    static var sampleData: [Note] {
        [
            Note(title: "Project Ideas", content: "1. Weather app with state recovery\n2. Todo list with persistence\n3. Recipe manager", tags: ["ideas", "projects"], createdAt: Date(), modifiedAt: Date()),
            Note(title: "Meeting Notes", content: "Discussed app architecture and state management strategies. Need to implement proper error handling.", tags: ["work", "meetings"], createdAt: Date(), modifiedAt: Date()),
            Note(title: "Learning Resources", content: "SwiftUI documentation, WWDC videos, online tutorials and courses", tags: ["learning", "resources"], createdAt: Date(), modifiedAt: Date()),
            Note(title: "Bug Fixes", content: "- Fix scroll position restoration\n- Update navigation stack\n- Improve data persistence", tags: ["bugs", "development"], createdAt: Date(), modifiedAt: Date()),
            Note(title: "Feature Requests", content: "Users want dark mode, widget support, and cloud sync", tags: ["features", "feedback"], createdAt: Date(), modifiedAt: Date()),
        ]
    }
}
