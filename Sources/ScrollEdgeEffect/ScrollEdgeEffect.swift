import GaussianLinearGradient
import SwiftUI

/// A mask that fades scrollable content at selected edges.
///
/// Use this view directly with `.mask { ... }` when you need to control the
/// scroll geometry state yourself. On iOS 17, use `ScrollEdgeEffectScrollView`
/// when you can wrap the scroll view. On iOS 18 and later, prefer
/// `View.scrollEdgeEffect(edges:length:threshold:animation:)` for existing scroll views.
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
    @available(iOS 18.0, macOS 15.0, *)
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
  private let visibility: Visibility

  /// Creates an edge fade mask for a scrollable view.
  ///
  /// - Parameters:
  ///   - edges: The edges where fade ramps can appear.
  ///   - length: The length of each fade ramp.
  ///   - visibility: The current visibility state for each edge fade.
  public init(
    edges: Edge.Set = [.top, .bottom],
    length: CGFloat = 40,
    visibility: Visibility = .hidden
  ) {
    self.edges = edges
    self.length = length
    self.visibility = visibility
  }

  public var body: some View {
    VStack(spacing: 0) {
      if edges.contains(.top) {
        fadingEdge(shows: visibility.showsTop) {
          edgeGradient(for: .top)
        }
        .frame(height: fadeLength)
      }

      HStack(spacing: 0) {
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
      }

      if edges.contains(.bottom) {
        fadingEdge(shows: visibility.showsBottom) {
          edgeGradient(for: .bottom)
        }
        .frame(height: fadeLength)
      }
    }
  }

  private var fadeLength: CGFloat {
    max(length, 0)
  }

  private func edgeGradient(for edge: Edge) -> GaussianLinearGradient {
    switch edge {
    case .top:
      fadingGradient(
        startColor: .clear,
        endColor: .black,
        startPoint: .top,
        endPoint: .bottom
      )
    case .leading:
      fadingGradient(
        startColor: .clear,
        endColor: .black,
        startPoint: .leading,
        endPoint: .trailing
      )
    case .bottom:
      fadingGradient(
        startColor: .black,
        endColor: .clear,
        startPoint: .top,
        endPoint: .bottom
      )
    case .trailing:
      fadingGradient(
        startColor: .black,
        endColor: .clear,
        startPoint: .leading,
        endPoint: .trailing
      )
    }
  }

  /// Creates the edge mask ramp using a one-dimensional Gaussian-like falloff.
  private func fadingGradient(
    startColor: Color,
    endColor: Color,
    startPoint: UnitPoint,
    endPoint: UnitPoint
  ) -> GaussianLinearGradient {
    GaussianLinearGradient(
      startColor: startColor,
      endColor: endColor,
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
  /// This modifier relies on SwiftUI scroll geometry observation and is available on
  /// iOS 18 and later. For iOS 17, use `ScrollEdgeEffectScrollView` when you own the
  /// `ScrollView` creation.
  ///
  /// Apply this modifier directly to `ScrollView`, `List`, or another SwiftUI view that
  /// owns a scroll view. The modifier observes the scroll geometry and updates the mask
  /// when the content moves away from or reaches the selected edges.
  @available(iOS 18.0, macOS 15.0, *)
  func scrollEdgeEffect(
    edges: Edge.Set = [.top, .bottom],
    length: CGFloat = 40,
    threshold: CGFloat = 1,
    animation: Animation? = .spring
  ) -> some View {
    modifier(
      ScrollEdgeEffectModifier(
        edges: edges,
        length: length,
        threshold: threshold,
        animation: animation
      )
    )
  }
}

@available(iOS 18.0, macOS 15.0, *)
private struct ScrollEdgeEffectModifier: ViewModifier {

  let edges: Edge.Set
  let length: CGFloat
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
          visibility: visibility
        )
        .animation(animation, value: visibility)
      }
  }
}

public typealias EdgeEffectMask = ScrollEdgeEffect
