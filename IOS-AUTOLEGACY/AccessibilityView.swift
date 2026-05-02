import SwiftUI

struct AccessibilityView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var textSize: Double = 50
    @State private var highContrast: Bool = true
    @State private var voiceGuidance: Bool = false
    @State private var largerTouchTargets: Bool = false
    @State private var faceUnlock: Bool = false
    @State private var showFaceIDSetup = false
    
    var body: some View {
        ZStack {
            Color(red: 0.23, green: 0.29, blue: 0.38)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
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
                    
                    Text("Accessibility")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        // Text Size Slider Row
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Text Size")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Adjust text size for readability")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            HStack {
                                Text("A")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                                
                                Slider(value: $textSize, in: 0...100)
                                    .tint(.white)
                                
                                Text("A")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        
                        // Toggles
                        AccessibilityToggleRow(title: "High Contrast", subtitle: "Increase Visibility", isOn: $highContrast)
                        AccessibilityToggleRow(title: "Voice Guidance", subtitle: "Enable audio instructions", isOn: $voiceGuidance)
                        AccessibilityToggleRow(title: "Larger Touch Targets", subtitle: "Easier button", isOn: $largerTouchTargets)
                        
                        VStack {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Image(systemName: BiometricAuthentication.shared.getBiometricType() == .faceID ? "face.smiling" : "touchid")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(red: 0.62, green: 0.73, blue: 0.96))
                                        
                                        Text("Face Unlock")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                    Text("Unlock app using \(BiometricAuthentication.shared.getBiometricType() == .faceID ? "face" : "touch")")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                
                                if BiometricAuthentication.shared.isBiometricAvailable() {
                                    Toggle("", isOn: $faceUnlock)
                                        .labelsHidden()
                                        .onChange(of: faceUnlock) { newValue in
                                            SessionManager.shared.enableFaceUnlock(newValue)
                                            if newValue {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                    showFaceIDSetup = true
                                                }
                                            }
                                        }
                                } else {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.slash")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text("Not Available")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                        
                        // Language Selector
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Language")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("English")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Text("English")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // padding for custom nav bar
                }
            }
        }
        .onAppear {
            faceUnlock = SessionManager.shared.isFaceUnlockEnabled()
        }
        .sheet(isPresented: $showFaceIDSetup) {
            FaceIDSetupView(
                biometricType: BiometricAuthentication.shared.getBiometricType(),
                isEnrolled: BiometricAuthentication.shared.isBiometricAvailable()
            )
        }
    }
}

struct AccessibilityToggleRow: View {
    var title: String
    var subtitle: String
    @Binding var isOn: Bool
    
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
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                // You can style the tint based on AppTheme if needed
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
    AccessibilityView()
}