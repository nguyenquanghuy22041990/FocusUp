//
//  TaskListView.swift
//  FocusUp
//

import SwiftUI

struct TaskListView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Bindable var viewModel: TaskListViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: AdaptiveSpacing.sectionSpacing(horizontalSizeClass: horizontalSizeClass)) {
      TaskListFilterBar(selected: viewModel.selectedFilter) { route in
        viewModel.selectFilter(route)
        _Concurrency.Task { await viewModel.load() }
      }

      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .task {
      await viewModel.load()
    }
    .refreshable {
      await viewModel.load()
    }
    .onChange(of: viewModel.selectedFilter) { _, _ in
      _Concurrency.Task { await viewModel.load() }
    }
  }

  @ViewBuilder
  private var content: some View {
    switch viewModel.state {
    case .loading:
      loadingView
    case .empty:
      TaskListEmptyStateView(filter: viewModel.selectedFilter)
    case .populated(let rows):
      populatedView(rows)
    case .error(let message):
      errorView(message)
    }
  }

  private var loadingView: some View {
    AppCard {
      HStack(spacing: AppSpacing.md) {
        ProgressView()
        Text("Loading tasks…")
          .appFont(.body)
          .foregroundStyle(AppColors.secondaryText)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .accessibilityLabel("Loading tasks")
  }

  private func populatedView(_ rows: [TaskRowModel]) -> some View {
    AdaptiveGrid(data: rows, id: \.id, compactColumns: 1, regularColumns: 2) { row in
      NavigationLink(value: TasksRoute.detail(row.id)) {
        TaskListRowView(row: row)
      }
      .buttonStyle(.plain)
    }
  }

  private func errorView(_ message: String) -> some View {
    AppCard {
      VStack(alignment: .leading, spacing: AppSpacing.sm) {
        Label("Couldn't load tasks", systemImage: "exclamationmark.triangle")
          .appFont(.headline)
          .foregroundStyle(AppColors.error)
          .accessibilityAddTraits(.isHeader)

        Text(message)
          .appFont(.body)
          .appMultilineText()
          .foregroundStyle(AppColors.secondaryText)

        SecondaryButton(title: "Try Again") {
          _Concurrency.Task { await viewModel.load() }
        }
      }
    }
    .accessibilityElement(children: .contain)
  }
}
