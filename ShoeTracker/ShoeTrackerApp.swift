//
//  ShoeTrackerApp.swift
//  ShoeTracker
//
//  Created by Matthew Johanson on 10/03/2025.
//

import SwiftUI
import SwiftData
import Photos

@main
struct ShoeTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TryOn.self)
    }
}
