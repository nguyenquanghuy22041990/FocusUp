//
//  StatisticsView.swift
//  FocusUp
//

import SwiftUI

struct StatisticsView: View {
  @Environment(\.appContainer) private var container
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @State private var viewModel: StatisticsViewModel?

  var body: some View {
    @Bindable var tabCoordinator = container.coordinator.tabCoordinators.statistics

    FeatureNavigationShell(coordinator: tabCoordinator) {
      statisticsRoot
    } destination: { route in
      PlaceholderDetailView(
        title: route.title,
        subtitle: "Detailed analytics views will expand here.",
        systemImage: "chart.bar.fill"
      )
    }
  }

  @ViewBuilder
  private var statisticsRoot: some View {
    ResponsiveContainer(wide: horizontalSizeClass == .regular) {
      Group {
        if let viewModel {
          if viewModel.loadingState == .loading && viewModel.summary == .empty {
            ProgressView("Loading statistics…")
              .frame(maxWidth: .infinity, minHeight: 200)
          } else {
            StatisticsContentView(viewModel: viewModel)
          }
        } else {
          ProgressView()
        }
      }
    }
    .navigationTitle("Statistics")
    .navigationBarTitleDisplayMode(.large)
    .refreshable {
      await viewModel?.refresh()
    }
    .onAppear(perform: ensureViewModel)
    .task {
      await viewModel?.load()
    }
  }

  private func ensureViewModel() {
    guard viewModel == nil else { return }
    viewModel = StatisticsViewModel(statisticsRepository: container.statisticsRepository)
  }
}

#if DEBUG
#Preview("Populated") {
  StatisticsContentView(
    viewModel: {
      let vm = StatisticsViewModel(statisticsRepository: PreviewStatisticsRepository())
      vm.configureForPreview(summary: StatisticsPreviewData.populated)
      return vm
    }()
  )
  .padding()
  .background(AppColors.background)
}

#Preview("Empty") {
  StatisticsContentView(
    viewModel: {
      let vm = StatisticsViewModel(statisticsRepository: PreviewStatisticsRepository())
      vm.configureForPreview(summary: .empty)
      return vm
    }()
  )
  .padding()
  .background(AppColors.background)
}

#Preview("iPad") {
  StatisticsContentView(
    viewModel: {
      let vm = StatisticsViewModel(statisticsRepository: PreviewStatisticsRepository())
      vm.configureForPreview(summary: StatisticsPreviewData.populated)
      return vm
    }()
  )
  .environment(\.horizontalSizeClass, .regular)
  .padding()
  .background(AppColors.background)
}

#Preview("Large type") {
  StatisticsContentView(
    viewModel: {
      let vm = StatisticsViewModel(statisticsRepository: PreviewStatisticsRepository())
      vm.configureForPreview(summary: StatisticsPreviewData.populated)
      return vm
    }()
  )
  .environment(\.dynamicTypeSize, .accessibility3)
  .padding()
  .background(AppColors.background)
}

#Preview("Dark") {
  StatisticsContentView(
    viewModel: {
      let vm = StatisticsViewModel(statisticsRepository: PreviewStatisticsRepository())
      vm.configureForPreview(summary: StatisticsPreviewData.populated)
      return vm
    }()
  )
  .preferredColorScheme(.dark)
  .padding()
  .background(AppColors.background)
}
#endif

#Preview {
  StatisticsView()
    .appContainer(.preview)
}
