import SwiftUI

/// A `ScrollView` wrapper that applies edge fades when more content is available to scroll.
///
/// Use this view on iOS 17 when you own the `ScrollView` construction. It measures the
/// wrapped scroll content in the scroll view coordinate space and drives `ScrollEdgeEffect`
/// from that geometry. On iOS 18 and later, `View.scrollEdgeEffect(...)` can be used when
/// the scroll view already exists elsewhere in the view hierarchy.
public struct ScrollEdgeEffectScrollView<Content: View>: View {

  private let axes: Axis.Set
  private let edges: Edge.Set
  private let length: CGFloat
  private let threshold: CGFloat
  private let showsIndicators: Bool
  private let animation: Animation?
  private let content: Content

  @State private var scrollFrame: CGRect = .zero
  @State private var containerSize: CGSize = .zero

  /// Creates a scroll view that fades selected edges as content scrolls out of view.
  ///
  /// - Parameters:
  ///   - axes: The scrollable axes passed through to `ScrollView`.
  ///   - edges: The edges where fade ramps can appear.
  ///   - length: The length of each fade ramp.
  ///   - threshold: The distance from an edge that still counts as being at that edge.
  ///   - showsIndicators: Whether the wrapped `ScrollView` shows scroll indicators.
  ///   - animation: The animation applied when edge visibility changes.
  ///   - content: The scrollable content.
  public init(
    _ axes: Axis.Set = .vertical,
    edges: Edge.Set = [.top, .bottom],
    length: CGFloat = 40,
    threshold: CGFloat = 1,
    showsIndicators: Bool = true,
    animation: Animation? = .spring,
    @ViewBuilder content: () -> Content
  ) {
    self.axes = axes
    self.edges = edges
    self.length = length
    self.threshold = threshold
    self.showsIndicators = showsIndicators
    self.animation = animation
    self.content = content()
  }

  public var body: some View {
    ScrollView(axes, showsIndicators: showsIndicators) {
      content
        .onGeometryChange(for: CGRect.self) { proxy in
          proxy.frame(in: .scrollView)
        } action: { frame in
          scrollFrame = frame
        }
    }
    .onGeometryChange(for: CGSize.self, of: \.size) { size in
      containerSize = size
    }
    .mask {
      ScrollEdgeEffect(
        edges: edges,
        length: length,
        visibility: visibility
      )
      .animation(animation, value: visibility)
    }
  }

  private var visibility: ScrollEdgeEffect.Visibility {
    ScrollEdgeEffect.Visibility(
      showsTop: edges.contains(.top)
        && containerSize.height > 0
        && scrollFrame.minY < -threshold,
      showsBottom: edges.contains(.bottom)
        && containerSize.height > 0
        && scrollFrame.maxY > containerSize.height + threshold,
      showsLeading: edges.contains(.leading)
        && containerSize.width > 0
        && scrollFrame.minX < -threshold,
      showsTrailing: edges.contains(.trailing)
        && containerSize.width > 0
        && scrollFrame.maxX > containerSize.width + threshold
    )
  }
}
