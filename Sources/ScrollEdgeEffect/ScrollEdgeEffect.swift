import SwiftUI

/// A mask that fades scrollable content at selected edges.
///
/// Use this view directly with `.mask { ... }` when you need to control the
/// scroll geometry state yourself. For the common case, prefer
/// `View.scrollEdgeEffect(edges:length:padding:threshold:animation:)`.
public struct ScrollEdgeEffect: View {

  /// The visible fade state for each edge of a `ScrollEdgeEffect`.
  public struct Visibility: Equatable, Sendable {

    /// Whether the top edge should fade from transparent to visible content.
    public var showsTop: Bool

    /// Whether the bottom edge should fade from visible content to transparent.
    public var showsBottom: Bool

    /// Whether the leading edge should fade from transparent to visible content.
    public var showsLeading: Bool

    /// Whether the trailing edge should fade from visible content to transparent.
    public var showsTrailing: Bool

    /// A visibility value that disables all edge fades.
    public static let hidden = Visibility()

    public init(
      showsTop: Bool = false,
      showsBottom: Bool = false,
      showsLeading: Bool = false,
      showsTrailing: Bool = false
    ) {
      self.showsTop = showsTop
      self.showsBottom = showsBottom
      self.showsLeading = showsLeading
      self.showsTrailing = showsTrailing
    }

    /// Creates edge visibility by comparing the visible scroll rect with the content bounds.
    ///
    /// - Parameters:
    ///   - geometry: The current scroll geometry from `onScrollGeometryChange`.
    ///   - edges: The edges whose visibility should be evaluated.
    ///   - threshold: The distance from an edge that still counts as being at that edge.
    public init(
      scrollGeometry geometry: ScrollGeometry,
      edges: Edge.Set = [.top, .bottom],
      threshold: CGFloat = 1
    ) {
      self.init(
        showsTop: edges.contains(.top)
          && geometry.visibleRect.minY > threshold,
        showsBottom: edges.contains(.bottom)
          && geometry.visibleRect.maxY < geometry.contentSize.height - threshold,
        showsLeading: edges.contains(.leading)
          && geometry.visibleRect.minX > threshold,
        showsTrailing: edges.contains(.trailing)
          && geometry.visibleRect.maxX < geometry.contentSize.width - threshold
      )
    }
  }

  private let edges: Edge.Set
  private let length: CGFloat
  private let padding: EdgeInsets
  private let visibility: Visibility

  /// Creates an edge fade mask for a scrollable view.
  ///
  /// - Parameters:
  ///   - edges: The edges where fade ramps can appear.
  ///   - length: The length of each fade ramp.
  ///   - padding: Fully visible insets before the fade ramps begin.
  ///   - visibility: The current visibility state for each edge fade.
  public init(
    edges: Edge.Set = [.top, .bottom],
    length: CGFloat = 40,
    padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
    visibility: Visibility = .hidden
  ) {
    self.edges = edges
    self.length = length
    self.padding = padding
    self.visibility = visibility
  }

  public var body: some View {
    VStack(spacing: 0) {
      visiblePadding(length: padding.top, edge: .top)

      if edges.contains(.top) {
        fadingEdge(shows: visibility.showsTop) {
          edgeGradient(for: .top)
        }
        .frame(height: fadeLength)
      }

      HStack(spacing: 0) {
        visiblePadding(length: padding.leading, edge: .leading)

        if edges.contains(.leading) {
          fadingEdge(shows: visibility.showsLeading) {
            edgeGradient(for: .leading)
          }
          .frame(width: fadeLength)
        }

        Rectangle()

        if edges.contains(.trailing) {
          fadingEdge(shows: visibility.showsTrailing) {
            edgeGradient(for: .trailing)
          }
          .frame(width: fadeLength)
        }

        visiblePadding(length: padding.trailing, edge: .trailing)
      }

      if edges.contains(.bottom) {
        fadingEdge(shows: visibility.showsBottom) {
          edgeGradient(for: .bottom)
        }
        .frame(height: fadeLength)
      }

      visiblePadding(length: padding.bottom, edge: .bottom)
    }
  }

  private var fadeLength: CGFloat {
    max(length, 0)
  }

  @ViewBuilder
  private func visiblePadding(length: CGFloat, edge: Edge) -> some View {
    if length > 0 {
      switch edge {
      case .top, .bottom:
        Rectangle()
          .frame(height: length)
      case .leading, .trailing:
        Rectangle()
          .frame(width: length)
      }
    }
  }

  private func edgeGradient(for edge: Edge) -> LinearGradient {
    switch edge {
    case .top:
      fadingGradient(
        transparentAtStart: true,
        startPoint: .top,
        endPoint: .bottom
      )
    case .leading:
      fadingGradient(
        transparentAtStart: true,
        startPoint: .leading,
        endPoint: .trailing
      )
    case .bottom:
      fadingGradient(
        transparentAtStart: false,
        startPoint: .top,
        endPoint: .bottom
      )
    case .trailing:
      fadingGradient(
        transparentAtStart: false,
        startPoint: .leading,
        endPoint: .trailing
      )
    }
  }

  /// Creates the edge mask ramp, including a short intermediate stop that softens the fade.
  private func fadingGradient(
    transparentAtStart: Bool,
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> LinearGradient {
    let rampLocation = fadeLength > 0 ? min(max(5 / fadeLength, 0), 1) : 1
    let stops: [Gradient.Stop]

    if transparentAtStart {
      stops = [
        Gradient.Stop(color: .clear, location: 0),
        Gradient.Stop(color: .black.opacity(0.4), location: rampLocation),
        Gradient.Stop(color: .black, location: 1),
      ]
    } else {
      stops = [
        Gradient.Stop(color: .black, location: 0),
        Gradient.Stop(color: .black.opacity(0.4), location: 1 - rampLocation),
        Gradient.Stop(color: .clear, location: 1),
      ]
    }

    return LinearGradient(
      stops: stops,
      startPoint: startPoint,
      endPoint: endPoint
    )
  }

  private func fadingEdge<G: View>(
    shows: Bool,
    @ViewBuilder gradient: () -> G
  ) -> some View {
    ZStack {
      gradient()
      Color.black.opacity(shows ? 0 : 1)
    }
  }
}

public extension View {

  /// Applies a scroll edge fade mask to the first scrollable view in this view hierarchy.
  ///
  /// Apply this modifier directly to `ScrollView`, `List`, or another SwiftUI view that
  /// owns a scroll view. The modifier observes the scroll geometry and updates the mask
  /// when the content moves away from or reaches the selected edges.
  func scrollEdgeEffect(
    edges: Edge.Set = [.top, .bottom],
    length: CGFloat = 40,
    padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
    threshold: CGFloat = 1,
    animation: Animation? = .spring
  ) -> some View {
    modifier(
      ScrollEdgeEffectModifier(
        edges: edges,
        length: length,
        padding: padding,
        threshold: threshold,
        animation: animation
      )
    )
  }
}

private struct ScrollEdgeEffectModifier: ViewModifier {

  let edges: Edge.Set
  let length: CGFloat
  let padding: EdgeInsets
  let threshold: CGFloat
  let animation: Animation?

  @State private var visibility = ScrollEdgeEffect.Visibility.hidden

  func body(content: Content) -> some View {
    content
      .onScrollGeometryChange(for: ScrollEdgeEffect.Visibility.self) { geometry in
        ScrollEdgeEffect.Visibility(
          scrollGeometry: geometry,
          edges: edges,
          threshold: threshold
        )
      } action: { _, visibility in
        self.visibility = visibility
      }
      .mask {
        ScrollEdgeEffect(
          edges: edges,
          length: length,
          padding: padding,
          visibility: visibility
        )
        .animation(animation, value: visibility)
      }
  }
}

public typealias EdgeEffectMask = ScrollEdgeEffect
