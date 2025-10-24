# Places

A SwiftUI iOS app that displays locations and integrates with Wikipedia for location-based information.

## Architecture

**MVVM + Repository Pattern** with protocol-based dependency injection:

```
┌─────────────────────────────────────────────────────────────────┐
│  Views (SwiftUI)                                                │
│  ├─ ContentView                                                 │
│  ├─ LocationsListView / CustomLocationView                      │
│  └─ Components (LocationRow, ErrorBannerView, etc.)             │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  ViewModels
│  └─ PlacesViewModel (Business Logic, State Management)          │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────────┐
│  Repositories (Data Layer)                                      │
│  └─ LocationRepository (Network + Cache Coordination)           │
└─────────────┬──────────────────────────┬────────────────────────┘
              │                          │
              ↓                          ↓
    ┌──────────────────┐      ┌──────────────────┐
    │  Services        │      │  Cache           │
    │  ├─ Location     │      │  └─ CacheManager │
    │  ├─ Network      │      │     (File-based) │
    │  ├─ Connectivity │      └──────────────────┘
    │  ├─ Wikipedia    │
    │  └─ Logging      │
    └──────────────────┘

```

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 5.9+
- Wikipedia app (optional, for full functionality)

## Installation

1. Clone the repository
2. Open `Places.xcodeproj` in Xcode
3. Build and run (`⌘R`)

No external dependencies

## Design Decisions

### Repository Pattern
The `LocationRepository` sits between the ViewModel and services layer, handling the coordination of network calls, cache fallbacks, and error states. This keeps the ViewModel focused on UI state management while the Repository orchestrates data fetching logic (network → cache → error).

This adds an extra abstraction layer which could be considered unnecessary for a simple app, but it significantly improves testability and maintains clear separation of concerns.


### Caching Strategy
File-based cache using JSON stored in the Documents directory. When network requests fail, the app falls back to cached data. Corrupted cache files are automatically deleted to prevent crashes.

Alternative approaches like CoreData or UserDefaults were considered, but for a single JSON file, direct file I/O is simpler with zero external dependencies. The approach doesn't scale well to large datasets, but it's appropriate for this use case.

### LocationValidator
A dedicated validator class for coordinate validation might seem excessive for just latitude/longitude checks. However, since both the ViewModel and WikipediaService require the same validation logic, extracting it avoids duplication and makes the logic independently testable.

In a production scenario with only this single use case, inline validation would likely be sufficient. The separate class demonstrates the pattern for when validation logic is shared across components.

### Protocol-Based Dependencies
All services use protocol abstractions with an `AppDependencies` composition root for dependency injection. This makes testing straightforward by allowing mock implementations to be swapped in easily.

The notable exception is `LoggingService.shared`, which uses a singleton pattern. Since logging is cross-cutting and doesn't affect business logic or test outcomes, a singleton provides better ergonomics without compromising testability. The protocol-based approach adds boilerplate, but the testing benefits outweigh the additional code.

### Error Handling
Rather than exposing technical errors like "URLError.notConnectedToInternet", the `UserFacingError` model transforms system errors into user-friendly messages with contextual actions (e.g., retry buttons).

When network calls fail but cached data exists, the app displays the cached content with a warning banner rather than blocking the user entirely. This graceful degradation improves user experience at the cost of additional error mapping logic.

## Testing

Run tests in Xcode (`⌘U`)

## API

Fetches locations from:
```
https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json
```

Expected format:
```json
{
  "locations": [
    { "name": "Amsterdam", "lat": 52.3676, "long": 4.9041 }
  ]
}
```

## Wikipedia Integration

Opens Wikipedia app using:
```
wikipedia://places?location=<lat>,<long>
```

If Wikipedia is not installed, displays a sheet with App Store link.

### Installing Wikipedia App for Testing

To test the full Wikipedia integration functionality:

**Build from source**
   ```bash
   git clone https://github.com/isonka/wikipedia-ios.git
   cd wikipedia-ios
   ./scripts/setup
   # Open Wikipedia.xcodeproj and run on simulator
   ```

**Note:** Building from source requires Xcode 16.0+ (same as this project). See the [Wikipedia iOS repository](https://github.com/wikimedia/wikipedia-ios) for details.

