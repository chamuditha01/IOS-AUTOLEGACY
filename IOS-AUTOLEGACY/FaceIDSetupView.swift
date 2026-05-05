import SwiftUI

struct FaceIDSetupView: View {
    @Environment(\.dismiss) var dismiss
    
    let biometricType: BiometricAuthentication.BiometricType
    let isEnrolled: Bool
    
    var body: some View {
        ZStack {
            Color(red: 0.23, green: 0.29, blue: 0.38)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(biometricType == .faceID ? "Face ID Setup" : "Touch ID Setup")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Large Icon
                        VStack(spacing: 16) {
                            Image(systemName: biometricType == .faceID ? "face.smiling.fill" : "touchid")
                                .font(.system(size: 80, weight: .light))
                                .foregroundColor(Color(red: 0.62, green: 0.73, blue: 0.96))
                                .frame(height: 100)
                            
                            Text(biometricType == .faceID ? "Face ID" : "Touch ID")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Status Card
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: isEnrolled ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(isEnrolled ? Color(red: 0.16, green: 0.65, blue: 0.27) : Color(red: 0.96, green: 0.53, blue: 0.53))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(isEnrolled ? "Enrolled" : "Not Enrolled")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text(isEnrolled ? "Ready to use" : "Needs setup in Settings")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Instructions
                        VStack(spacing: 16) {
                            Text(isEnrolled ? "Your Device is Ready" : "Setup Required")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(spacing: 12) {
                                instructionStep(
                                    number: "1",
                                    title: "Open Settings",
                                    description: "Go to Settings > Face ID & Attention or Settings > Touch ID & Passcode"
                                )
                                
                                instructionStep(
                                    number: "2",
                                    title: isEnrolled ? "Already Set Up" : "Add Face/Touch",
                                    description: isEnrolled ? "Your biometric data is saved" : "Follow on-screen prompts to scan your face or fingerprint"
                                )
                                
                                instructionStep(
                                    number: "3",
                                    title: "Return to App",
                                    description: "Come back to AutoLegacy and enable Face Unlock in Accessibility"
                                )
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Benefits
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                VStack(spacing: 12) {
                                    benefitItem(icon: "bolt.fill", text: "Fast Login")
                                    benefitItem(icon: "lock.fill", text: "Secure")
                                }
                                
                                VStack(spacing: 12) {
                                    benefitItem(icon: "hand.raised.fill", text: "One Tap")
                                    benefitItem(icon: "checkmark.seal.fill", text: "Convenient")
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
                
                // Buttons
                VStack(spacing: 12) {
                    if !isEnrolled {
                        Button(action: openSettings) {
                            HStack(spacing: 8) {
                                Image(systemName: "gear")
                                Text("Open Settings")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.62, green: 0.73, blue: 0.96))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    
                    Button(action: { dismiss() }) {
                        Text(isEnrolled ? "Done" : "Done")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(20)
                .background(Color.black.opacity(0.2))
            }
        }
    }
    
    private func instructionStep(number: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(Color(red: 0.62, green: 0.73, blue: 0.96))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
    
    private func benefitItem(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.62, green: 0.73, blue: 0.96))
            
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

struct FaceIDSetupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FaceIDSetupView(biometricType: .faceID, isEnrolled: false)
                .previewDisplayName("Not Enrolled")
            
            FaceIDSetupView(biometricType: .faceID, isEnrolled: true)
                .previewDisplayName("Enrolled")
        }
    }
}
