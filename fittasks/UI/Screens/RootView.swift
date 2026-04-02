import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppStore
    @State private var hasCompletedSplashDelay = false
    @State private var showsSplash = true

    private var canDismissSplash: Bool {
        hasCompletedSplashDelay && store.isLoaded
    }

    var body: some View {
        ZStack {
            SceneBackground()

            if store.isLoaded {
                NavigationStack(path: $store.navigationPath) {
                    Group {
                        if store.shouldShowLanguageSetup {
                            LanguageSelectionScreen()
                        } else {
                            TaskListScreen()
                        }
                    }
                    .navigationDestination(for: AppStore.Route.self) { route in
                        switch route {
                        case .taskEdit(let groupID):
                            TaskEditScreen(groupID: groupID)
                        case .timer(let groupID):
                            if let group = store.taskGroup(id: groupID) {
                                TimerScreen(groupID: groupID, initialGroup: group) {
                                    if !store.navigationPath.isEmpty {
                                        store.navigationPath.removeLast()
                                    }
                                }
                            }
                        case .settings:
                            SettingsScreen()
                        }
                    }
                }
            } else {
                ProgressView()
                    .controlSize(.large)
            }

            if showsSplash {
                SplashScreen()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            guard !hasCompletedSplashDelay else { return }
            // LaunchScreen 自体はアニメーションできないため、起動直後のオーバーレイで演出する。
            try? await Task.sleep(for: .seconds(1.25))
            hasCompletedSplashDelay = true
        }
        .onChange(of: canDismissSplash) { _, newValue in
            guard newValue, showsSplash else { return }
            withAnimation(.easeInOut(duration: 0.35)) {
                showsSplash = false
            }
        }
        .animation(.easeInOut(duration: 0.35), value: showsSplash)
    }
}
