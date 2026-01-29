# State Recovery App - SwiftUI iOS Project

A comprehensive SwiftUI application demonstrating complete app state recovery, including screen stack restoration, data persistence, and scroll position recovery.

## 🎯 Features

### 1. **Screen Stack Restoration** ✅
- Automatically saves and restores the entire navigation path
- Preserves deep navigation hierarchies
- Restores to exact screen when app relaunches
- Works across tabs and nested navigation

### 2. **Data Restoration** ✅
- Automatic persistence of all app data
- Items and notes saved to UserDefaults
- Real-time data synchronization
- State preserved across app launches

### 3. **Scroll Position Recovery** ✅
- Remembers scroll position for each screen
- Smooth restoration when returning to screens
- Works independently for different views
- Uses ScrollViewReader for precise positioning

## 📱 App Structure

```
StateRecoveryApp/
├── StateRecoveryApp.swift          # Main app entry point
├── AppStateManager.swift           # Centralized state management
├── ContentView.swift               # Tab-based navigation container
├── ItemsListView.swift            # Items list with scroll recovery
├── ItemDetailView.swift           # Item details with scroll position
├── AddItemView.swift              # Add/Edit item forms
├── NotesListView.swift            # Notes list with scroll recovery
├── NoteDetailView.swift           # Note details with scroll position
├── AddNoteView.swift              # Add/Edit note forms
└── SettingsView.swift             # Settings and state management
```

## 🏗️ Architecture

### AppStateManager (Singleton)
The heart of state management:
- **Navigation State**: Tracks navigation path using `NavigationDestination` enum
- **Data State**: Manages Items and Notes collections
- **Scroll Positions**: Dictionary of scroll positions keyed by screen ID
- **Persistence**: Automatic save/load using UserDefaults with Codable

### State Recovery Flow

```
App Launch → AppStateManager.restoreState()
           ↓
    Restore Navigation Path
           ↓
    Restore Data (Items/Notes)
           ↓
    Restore Scroll Positions
           ↓
    UI Updates Automatically
```

### Data Models

#### NavigationDestination (Enum)
```swift
enum NavigationDestination: Codable, Hashable {
    case itemDetail(itemId: String)
    case noteDetail(noteId: String)
    case settings
    case addItem
    case addNote
}
```

#### Item
```swift
struct Item: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var category: String
    var isFavorite: Bool
    var createdAt: Date
}
```

#### Note
```swift
struct Note: Identifiable, Codable {
    var id: String
    var title: String
    var content: String
    var tags: [String]
    var createdAt: Date
    var modifiedAt: Date
}
```

#### ScrollPosition
```swift
struct ScrollPosition: Codable {
    var offset: CGFloat
    var itemId: String?
}
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- SwiftUI

### Installation

1. Create a new Xcode project:
   - Open Xcode
   - Create new project → iOS → App
   - Name: "StateRecoveryApp"
   - Interface: SwiftUI
   - Language: Swift

2. Add all Swift files to your project:
   - Copy all `.swift` files to your project
   - Ensure they're added to the target

3. Build and run:
   - Select your target device/simulator
   - Press Cmd+R to build and run

## 💡 How It Works

### Screen Stack Restoration

The app uses SwiftUI's `NavigationStack` with a path binding:

```swift
NavigationStack(path: $appState.navigationPath) {
    ItemsListView()
        .navigationDestination(for: NavigationDestination.self) { destination in
            destinationView(for: destination)
        }
}
```

When you navigate between screens, the path is automatically updated and saved. On app relaunch, the path is restored, recreating the exact navigation hierarchy.

### Data Persistence

All data operations trigger automatic saves:

```swift
func addItem(_ item: Item) {
    items.append(item)
    saveDataState()  // Automatic save
}
```

Data is encoded using `JSONEncoder` and stored in UserDefaults:

```swift
private func saveDataState() {
    if let itemsEncoded = try? JSONEncoder().encode(items) {
        UserDefaults.standard.set(itemsEncoded, forKey: itemsKey)
    }
}
```

### Scroll Position Recovery

Each screen saves its scroll position when disappearing:

```swift
.onDisappear {
    saveScrollPosition()
}

private func saveScrollPosition() {
    let position = ScrollPosition(offset: 0, itemId: firstVisibleItemId)
    appState.saveScrollPosition(position, for: screenId)
}
```

And restores it when appearing:

```swift
.onAppear {
    restoreScrollPosition(proxy: proxy)
}

private func restoreScrollPosition(proxy: ScrollViewProxy) {
    if let savedPosition = appState.getScrollPosition(for: screenId),
       let itemId = savedPosition.itemId {
        proxy.scrollTo(itemId, anchor: .top)
    }
}
```

## 🧪 Testing the Features

### Test Screen Stack Restoration:
1. Open the app
2. Navigate: Items → Item Detail → Related Item
3. Close the app (swipe up from app switcher)
4. Reopen the app
5. ✅ You should be on the same screen

### Test Data Restoration:
1. Add a new item or note
2. Edit existing items
3. Close the app
4. Reopen the app
5. ✅ All changes are preserved

### Test Scroll Position Recovery:
1. Open Items list
2. Scroll down to item #5
3. Tap on an item
4. Go back to list
5. ✅ List scrolls back to item #5

## 🎨 UI Features

- **Tab Navigation**: Three tabs (Items, Notes, Settings)
- **Search**: Full-text search in Items and Notes
- **Filters**: Category filters and tag filters
- **Swipe Actions**: Delete and favorite actions
- **Pull to Refresh**: Coming soon
- **Dark Mode**: Fully supported

## 🔧 Customization

### Adding New Data Types

1. Create your model conforming to `Codable` and `Identifiable`
2. Add property to `AppStateManager`
3. Add save/restore methods
4. Create corresponding views

### Adding New Navigation Destinations

1. Add case to `NavigationDestination` enum
2. Add handling in `destinationView(for:)` method
3. Create the destination view

### Customizing Persistence

You can replace UserDefaults with:
- Core Data
- File system storage
- CloudKit
- Third-party solutions (Realm, etc.)

## 📊 State Management Best Practices

1. **Centralized State**: Use a single source of truth (`AppStateManager`)
2. **Automatic Saves**: Trigger saves on every data mutation
3. **Graceful Degradation**: Handle missing data elegantly
4. **Performance**: Use lazy loading for large datasets
5. **Testing**: Mock `AppStateManager` for unit tests

## 🐛 Troubleshooting

### Navigation not restoring?
- Check that navigation path is being saved correctly
- Verify all destination types are Codable
- Ensure navigation path binding is connected

### Data not persisting?
- Verify models conform to Codable
- Check UserDefaults keys are correct
- Ensure save methods are being called

### Scroll position not working?
- Confirm ScrollViewReader is wrapping content
- Check that item IDs are stable and unique
- Verify timing of scroll restoration (use delay)
 
