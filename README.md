# SwiftUI Scroll Edge Effect

A lightweight SwiftUI package for fading scrollable content at its edges.

Use it with `ScrollView`, `List`, or any SwiftUI view that owns a scroll view.

## Requirements

- iOS 17.0+
- macOS 14.0+
- Swift 6.0+

## Installation

Add the package with Swift Package Manager:

```swift
dependencies: [
  .package(url: "https://github.com/FluidGroup/swiftui-scroll-edge-effect.git", from: "0.2.0")
]
```

Then add `ScrollEdgeEffect` to your target dependencies.

## Usage

### iOS 17 ScrollView wrapper

On iOS 17, wrap the scroll view with `ScrollEdgeEffectScrollView`.

```swift
import ScrollEdgeEffect
import SwiftUI

struct ContentView: View {
  var body: some View {
    ScrollEdgeEffectScrollView(.vertical, edges: [.top, .bottom]) {
      LazyVStack {
        ForEach(items) { item in
          ItemRow(item: item)
        }
      }
    }
  }
}
```

`EdgeFadingScrollView` is also available as a shorter alias.

### iOS 18 modifier

On iOS 18 and later, use the modifier when the scroll view already exists.

```swift
import ScrollEdgeEffect
import SwiftUI

struct ContentView: View {
  var body: some View {
    ScrollView {
      LazyVStack {
        ForEach(items) { item in
          ItemRow(item: item)
        }
      }
    }
    .scrollEdgeEffect(
      edges: [.top, .bottom],
      length: 40
    )
  }
}
```

### Manual mask

Use `ScrollEdgeEffect` directly when you want to own the scroll geometry state.
The `ScrollGeometry` convenience initializer requires iOS 18 or later.

```swift
@State private var visibility = ScrollEdgeEffect.Visibility.hidden

List(0..<100, id: \.self) { index in
  Text("Item \(index)")
}
.onScrollGeometryChange(for: ScrollEdgeEffect.Visibility.self) { geometry in
  ScrollEdgeEffect.Visibility(scrollGeometry: geometry, edges: [.top, .bottom])
} action: { _, visibility in
  self.visibility = visibility
}
.mask {
  ScrollEdgeEffect(
    edges: [.top, .bottom],
    length: 40,
    visibility: visibility
  )
}
```

## License

MIT license.
