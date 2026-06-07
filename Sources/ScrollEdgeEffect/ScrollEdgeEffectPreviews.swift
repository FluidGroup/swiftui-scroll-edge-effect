import SwiftUI

#if DEBUG
private struct ScrollEdgeEffectListPreview: View {

  var body: some View {
    List(0..<80, id: \.self) { index in
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text("List Item \(index)")
            .font(.body.weight(.medium))
          Text("Scroll to see the edge mask appear and disappear.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Spacer()

        Text(index.formatted())
          .font(.caption.monospacedDigit())
          .foregroundStyle(.secondary)
      }
      .padding(.vertical, 4)
    }
    .scrollEdgeEffect(
      edges: [.top, .bottom],
      length: 48
    )
  }
}

private struct ScrollEdgeEffectScrollViewPreview: View {

  private let columns = [
    GridItem(.adaptive(minimum: 96), spacing: 12),
  ]

  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 12) {
        ForEach(0..<80, id: \.self) { index in
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.accentColor.opacity(0.14))
            .overlay {
              Text(index.formatted())
                .font(.title2.monospacedDigit().weight(.semibold))
                .foregroundStyle(Color.accentColor)
            }
            .frame(height: 96)
        }
      }
      .padding(16)
    }
    .scrollEdgeEffect(
      edges: [.top, .bottom],
      length: 48
    )
  }
}

#Preview("List") {
  ScrollEdgeEffectListPreview()
}

#Preview("ScrollView") {
  ScrollEdgeEffectScrollViewPreview()
}
#endif
