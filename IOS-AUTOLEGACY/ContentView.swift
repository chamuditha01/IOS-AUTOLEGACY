//
//  ContentView.swift
//  IOS-AUTOLEGACY
//
//  Created by Dileesha on 2026-04-05.
//

import SwiftUI

struct ContentView: View {
    @State private var showLandingPage = true
    @State private var showGetStartedPage = false
    
    var body: some View {
        ZStack {
            if showLandingPage && !showGetStartedPage {
                LandingPageView {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showLandingPage = false
                            showGetStartedPage = true
                        }
                    }
                }
            } else if showGetStartedPage {
                GetStartedPageView()
            }
        }
    }
}

#Preview {
    ContentView()
}
