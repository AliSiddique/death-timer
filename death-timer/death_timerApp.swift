//
//  death_timerApp.swift
//  death-timer
//
//  Created by Ali Siddique on 11/12/24.
//

import SwiftUI
import SwiftData
import SuperwallKit
@main
struct death_timerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserData.self, BucketListItem.self, QuizResponse.self,Reflection.self,PhotoMemory.self,LifeLesson.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    init(){
        Superwall.configure(apiKey: "pk_6f6b842555f0097aba34422ade7932cdbf77cfeace53399f")
    }
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    var body: some Scene {
        WindowGroup {
           if isOnboarding {
               OnboardingView()
                   .preferredColorScheme(.dark)

           } else {
               WellbeingDashboardView()
                   .preferredColorScheme(.dark)

           }
        }
        .modelContainer(sharedModelContainer)
    }
}
