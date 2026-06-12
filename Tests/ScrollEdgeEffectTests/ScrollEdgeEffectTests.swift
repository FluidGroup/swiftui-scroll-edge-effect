import SwiftUI
import Testing
@testable import ScrollEdgeEffect

@Test
@available(iOS 18.0, macOS 15.0, *)
func visibilityShowsScrollableEdgesWhenVisibleRectIsInsideContent() {
  let visibility = ScrollEdgeEffect.Visibility(
    scrollGeometry: ScrollGeometry(
      contentOffset: CGPoint(x: 20, y: 30),
      contentSize: CGSize(width: 300, height: 600),
      contentInsets: EdgeInsets(),
      containerSize: CGSize(width: 100, height: 200)
    ),
    edges: [.top, .bottom, .leading, .trailing]
  )

  #expect(visibility.showsTop)
  #expect(visibility.showsBottom)
  #expect(visibility.showsLeading)
  #expect(visibility.showsTrailing)
}

@Test
@available(iOS 18.0, macOS 15.0, *)
func visibilityHidesEdgesWhenVisibleRectTouchesContentBounds() {
  let visibility = ScrollEdgeEffect.Visibility(
    scrollGeometry: ScrollGeometry(
      contentOffset: CGPoint(x: 0, y: 0),
      contentSize: CGSize(width: 100, height: 200),
      contentInsets: EdgeInsets(),
      containerSize: CGSize(width: 100, height: 200)
    ),
    edges: [.top, .bottom, .leading, .trailing]
  )

  #expect(!visibility.showsTop)
  #expect(!visibility.showsBottom)
  #expect(!visibility.showsLeading)
  #expect(!visibility.showsTrailing)
}

@Test
func visibilityCanBeCreatedFromExplicitEdgeFlagsOnIOS17() {
  let visibility = ScrollEdgeEffect.Visibility(
    showsTop: true,
    showsBottom: false,
    showsLeading: true,
    showsTrailing: false
  )

  #expect(visibility.showsTop)
  #expect(!visibility.showsBottom)
  #expect(visibility.showsLeading)
  #expect(!visibility.showsTrailing)
}
