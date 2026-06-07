# SwiftUI Scroll Edge Effect

A lightweight SwiftUI package for fading scrollable content at its edges.

Use it with `ScrollView`, `List`, or any SwiftUI view that owns a scroll view.

## Requirements

- iOS 18.0+
- macOS 15.0+
- Swift 6.0+

## Installation

Add the package with Swift Package Manager:

```swift
dependencies: [
  .package(url: "https://github.com/FluidGroup/swiftui-scroll-edge-effect.git", from: "0.1.0")
]
```

Then add `ScrollEdgeEffect` to your target dependencies.

## Usage

### List

```swift
import ScrollEdgeEffect
import SwiftUI

struct ContentView: View {
  var body: some View {
    List(0..<100, id: \.self) { index in
      Text("Item \(index)")
    }
    .scrollEdgeEffect(
      edges: [.top, .bottom],
      length: 40,
      padding: EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
    )
  }
}
```

### ScrollView

```swift
ScrollEdgeEffectScrollView(.vertical, edges: [.top, .bottom]) {
  LazyVStack {
    ForEach(items) { item in
      ItemRow(item: item)
    }
  }
}
```

### Manual mask

Use `ScrollEdgeEffect` directly when you want to own the scroll geometry state.

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
