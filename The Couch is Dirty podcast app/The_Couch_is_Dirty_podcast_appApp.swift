//
//  The_Couch_is_Dirty_podcast_appApp.swift
//  The Couch is Dirty podcast app
//
//  Created by Anthony Jones on 7/25/26.
//

import SwiftUI
import SwiftData

@main
struct The_Couch_is_Dirty_podcast_appApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
