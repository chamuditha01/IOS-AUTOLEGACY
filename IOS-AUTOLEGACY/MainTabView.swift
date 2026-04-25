import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        ZStack {
            // Main Content Area
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .vault:
                    DigitalVaultView()
                case .map:
                    Text("Map") // Placeholder for map
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.Gradients.auth.ignoresSafeArea())
                case .profile:
                    Text("Profile") // Placeholder for profile
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.Gradients.auth.ignoresSafeArea())
                case .setting:
                    Text("Setting") // Placeholder for settings
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(AppTheme.Gradients.auth.ignoresSafeArea())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Nav Bar overlay
            VStack {
                Spacer()
                CustomNavBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }
        }
    }
}

#Preview {
    MainTabView()
}
