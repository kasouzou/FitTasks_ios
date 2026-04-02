//
//  fittasksApp.swift
//  fittasks
//
//  Rebuilt as a native iOS SwiftUI application based on the Android reference implementation.
//

import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
@MainActor
struct FitTasksApp: App {
    @StateObject private var store = AppStore()

    init() {
#if canImport(GoogleMobileAds)
        // Start the SDK only when both IDs are available in the iOS target.
        if AdMobConfiguration.shared.hasRequiredIDs {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        }
#endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(store.preferredColorScheme)
                .tint(store.accentTint)
        }
    }
}
