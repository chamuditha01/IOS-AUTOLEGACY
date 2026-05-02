import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutAlert = false
    var onLogout: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.23, green: 0.29, blue: 0.38).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                        Button(action: {
                            // If we want this to act as a back button returning to home tabs, 
                            // we would handle that in MainTabView, but for now we put a dismiss action
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("Settings")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Invisible spacer for balance
                        Spacer().frame(width: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            NavigationLink(destination: AccessibilityView().navigationBarBackButtonHidden(true)) {
                                SettingsRowView(title: "Accessibility", subtitle: "Customize your experience")
                            }
                            
                            NavigationLink(destination: HelpAndSupportView().navigationBarBackButtonHidden(true)) {
                                SettingsRowView(title: "Help & Support", subtitle: "Get assistance")
                            }
                            
                            NavigationLink(destination: TermsAndConditionsView().navigationBarBackButtonHidden(true)) {
                                SettingsRowView(title: "Terms & conditions", subtitle: "Legal information")
                            }
                            
                            NavigationLink(destination: AboutUsView().navigationBarBackButtonHidden(true)) {
                                SettingsRowView(title: "About", subtitle: "Version 1.0.0")
                            }
                            
                            Spacer(minLength: 20)
                            
                            // Logout Button
                            Button(action: {
                                showLogoutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("Logout")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .padding(20)
                                .background(Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // padding for custom nav bar layer
                    }
                }
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    handleLogout()
                }
            } message: {
                Text("Are you sure you want to logout? You'll need to login again to access your account.")
            }
        }
    }
    
    private func handleLogout() {
        SessionManager.shared.clearSession()
        onLogout?()
    }
}

struct SettingsRowView: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.7))
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    SettingsView()
}
    SettingsView()
}