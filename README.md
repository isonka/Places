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
I added a `LocationRepository` to sit between the ViewModel and the raw services. The ViewModel was getting messy trying to coordinate network calls, cache fallbacks, and error handling all at once. Now the Repository handles that orchestration, and the ViewModel can focus on UI state.

Yes, it's an extra layer. For a simple app like this, you could argue it's overkill. But it makes testing much easier and keeps responsibilities clear.

### Caching Strategy
Simple file-based cache using JSON in the Documents directory. When the network fails, we fall back to cached data. If a cache file gets corrupted somehow, we just delete it and move on.

I considered using CoreData or UserDefaults, but honestly? For a single JSON file, writing to disk is simpler and has zero dependencies. It won't scale to thousands of records, but for this use case it's perfect.

### LocationValidator
A dedicated class just to validate latitude/longitude might seem like overkill for two simple checks. And you'd be right to think that. But since both the ViewModel and WikipediaService need the same validation logic, I didn't want to duplicate it. Plus it made testing that logic much cleaner.

In a real project with just this one use case, I'd probably inline it. Here I wanted to show the pattern.

### Protocol-Based Dependencies
Everything's behind a protocol with an `AppDependencies` container to wire it up. Makes testing straightforward since you can swap in mocks easily.

The one exception: `LoggingService.shared` is a singleton. I know, I know. But logging is cross-cutting and doesn't affect business logic, so I kept it simple. Everything else is properly injected.

More boilerplate? Sure. But when you're writing tests, you'll be glad it's there.

### Error Handling
Instead of showing users raw error messages like "URLError.notConnectedToInternet", I built a `UserFacingError` model that translates technical errors into plain English with actionable retry buttons.

When the network fails but we have cached data, we show it with a warning banner instead of just failing. The user can still see something useful while offline.

Is it extra work to map errors? Yes. Is it worth it for the UX? Absolutely.

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

