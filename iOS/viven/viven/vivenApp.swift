//
//  vivenApp.swift
//  viven
//
//  Created by Shreeyans Vichare on 30/04/26.
//

import SwiftUI

@main
struct VIVENApp: App {
    private let llmService: any LLMServiceProtocol = MockLLMService()
    private let haptics = HapticService()

    var body: some Scene {
        WindowGroup {
            ContentView(llmService: llmService, haptics: haptics)
                .preferredColorScheme(.dark)
        }
    }
}
