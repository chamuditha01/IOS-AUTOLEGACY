//
//  ContentView.swift
//  IOS-AUTOLEGACY
//
//  Created by Dileesha on 2026-04-05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Checking connection...")
            .task {
                await checkConnection()
            }
    }
}
#Preview {
    ContentView()
}
