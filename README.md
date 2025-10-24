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

No external dependencies - pure SwiftUI/UIKit.

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
   git clone https://github.com/wikimedia/wikipedia-ios.git
   cd wikipedia-ios
   ./scripts/setup
   # Open Wikipedia.xcodeproj and run on simulator
   ```

**Note:** Building from source requires Xcode 16.0+ (same as this project). See the [Wikipedia iOS repository](https://github.com/wikimedia/wikipedia-ios) for details.

