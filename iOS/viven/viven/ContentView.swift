//
//  ContentView.swift
//  viven
//
//  Created by Shreeyans Vichare on 30/04/26.
//

import SwiftUI

struct ContentView: View {
    private let llmService: any LLMServiceProtocol
    private let haptics: HapticService

    init(llmService: any LLMServiceProtocol, haptics: HapticService) {
        self.llmService = llmService
        self.haptics = haptics
    }

    var body: some View {
        MainTabView(llmService: llmService, haptics: haptics)
    }
}

#Preview {
    ContentView(llmService: MockLLMService(), haptics: HapticService())
}
