//
//  AdaptiveGrid.swift
//  FocusUp
//

import SwiftUI

struct AdaptiveGrid<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let data: Data
  let id: KeyPath<Data.Element, ID>
  var compactColumns: Int = 1
  var regularColumns: Int = 2
  var spacing: CGFloat = AppSpacing.md
  @ViewBuilder var content: (Data.Element) -> Content

  private var columnCount: Int {
    horizontalSizeClass == .regular ? regularColumns : compactColumns
  }

  private var columns: [GridItem] {
    Array(repeating: GridItem(.flexible(), spacing: spacing), count: max(columnCount, 1))
  }

  var body: some View {
    LazyVGrid(columns: columns, spacing: spacing) {
      ForEach(data, id: id) { element in
        content(element)
      }
    }
  }
}
