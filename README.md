# Places

A SwiftUI-based iOS application that displays a list of locations and integrates with the Wikipedia app to provide location-based information.

## Features

- **Location List**: Fetches and displays locations from a remote API
- **Wikipedia Integration**: Tap any location to open it in the Wikipedia app
- **Custom Location**: Enter custom coordinates to search Wikipedia
- **Offline Handling**: Graceful handling of network connectivity issues
- **Input Validation**: Real-time validation of latitude and longitude inputs
- **Accessibility**: Full accessibility support with labels and hints

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern:

- **Models**: `Location`, `LocationsResponse` - Data structures
- **ViewModels**: `PlacesViewModel` - Business logic and state management
- **Views**: `ContentView` - SwiftUI user interface
- **Services**: 
  - `LocationService` - Handles API calls for locations
  - `NetworkManager` - Generic networking layer
  - `ConnectivityService` - Monitors network connectivity
- **Coordinators**: `WikipediaCoordinator` - Manages Wikipedia app integration

## Technical Highlights

### Swift Concurrency
- Uses `async/await` for network requests
- `@MainActor` for UI updates
- Structured concurrency throughout the app

### Accessibility
- Comprehensive accessibility labels and hints
- Keyboard-friendly input fields
- Screen reader optimized navigation

### Error Handling
- Custom `NetworkError` enum with user-friendly messages
- Input validation with real-time feedback
- Graceful degradation when Wikipedia app is not installed

### Testing
- Unit tests for networking layer
- Mock services for reliable testing
- Tests cover success, failure, and edge cases

## API

The app fetches location data from:
```
https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json
```

Expected JSON format:
```json
{
  "locations": [
    {
      "name": "Amsterdam",
      "lat": 52.3676,
      "long": 4.9041
    }
  ]
}
```

## Wikipedia Integration

The app opens the Wikipedia app using the custom URL scheme:
```
wikipedia://places?location=<latitude>,<longitude>
```

If the Wikipedia app is not installed, users will see an alert with instructions to install it.

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Wikipedia app (for full functionality)

## Installation

1. Clone the repository
2. Open `Places.xcodeproj` in Xcode
3. Build and run the project

## Usage

1. Launch the app to see the list of locations
2. Tap any location to open it in Wikipedia
3. Use the "Custom Location" section to enter coordinates manually
4. Enter valid latitude (-90 to 90) and longitude (-180 to 180) values
5. Tap "Open Wikipedia for Custom Location" to search

## Testing

Run tests using Xcode's test navigator or:
```bash
xcodebuild test -scheme Places -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Project Structure

```
Places/
├── Models/
│   └── Location.swift
├── ViewModels/
│   └── PlacesViewModel.swift
├── Views/
│   └── ContentView.swift
├── Networking/
│   ├── NetworkManager.swift
│   ├── LocationService.swift
│   └── ConnectivityService.swift
├── Coordinators/
│   └── WikipediaCoordinator.swift
└── PlacesApp.swift

PlacesTests/
├── LocationTests.swift
└── NetworkTests.swift
```
