# Places

A SwiftUI iOS app that displays locations and integrates with Wikipedia for location-based information.

## Architecture

**MVVM + Repository Pattern** with protocol-based dependency injection:

```
Views → ViewModels → Repositories → Services
  ↓          ↓            ↓            ↓
SwiftUI  Business     Data Layer   Network
         Logic        + Cache      + APIs
```

## Requirements

- iOS 17.0+
- Xcode 14.0+
- Swift 5.7+
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

