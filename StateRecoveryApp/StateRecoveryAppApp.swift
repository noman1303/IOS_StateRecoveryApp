//
//  StateRecoveryAppApp.swift
//  StateRecoveryApp
//
//  Created by Noman belim on 29/01/26.
//

import SwiftUI

@main
struct StateRecoveryAppApp: App {
    @StateObject private var appState = AppStateManager.shared
  
      var body: some Scene {
           WindowGroup {
              ContentView()
                  .environmentObject(appState)
                  .onAppear {
                      appState.restoreState()
                  }
                .onDisappear {
                      appState.saveState()
                  }
          }
      }
  }
