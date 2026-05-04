import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    var onLogout: (() -> Void)? = nil
    
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
                    VehicleProfileView()
                case .setting:
                    SettingsView(onLogout: onLogout)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Nav Bar overlay
            VStack {
                Spacer()
                CustomNavBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, -20)
            }
        }
    }
}

#Preview {
    MainTabView()
}
