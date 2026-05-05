import SwiftUI

struct HelpAndSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var expandedFAQIndex: Int? = nil
    
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
                    
                    Text("Help & Support")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // Contact Support Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.Layout.getStartedPrimaryButtonColor)
                                
                                Text("Need Help?")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            Text("We're here to help! Contact our support team for any questions or issues.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                                .lineSpacing(3)
                            
                            VStack(spacing: 10) {
                                ContactOptionView(icon: "envelope.fill", label: "Email", value: "support@autolegacy.com")
                                ContactOptionView(icon: "phone.fill", label: "Phone", value: "+9491 567 8939")
                                ContactOptionView(icon: "globe", label: "Website", value: "www.autolegacy.com")
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                        // FAQs Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Layout.getStartedPrimaryButtonColor)
                                
                                Text("Frequently Asked Questions")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 10) {
                                FAQItemView(
                                    question: "How do I add a vehicle?",
                                    answer: "Go to the Digital Vault tab, tap the '+' button, and enter your vehicle details. Your vehicle will be securely stored and linked to your profile.",
                                    isExpanded: expandedFAQIndex == 0,
                                    onTap: { expandedFAQIndex = expandedFAQIndex == 0 ? nil : 0 }
                                )
                                
                                FAQItemView(
                                    question: "How secure is my data?",
                                    answer: "AutoLegacy uses end-to-end encryption and secure Supabase authentication. All vehicle records and personal information are encrypted and protected according to industry standards.",
                                    isExpanded: expandedFAQIndex == 1,
                                    onTap: { expandedFAQIndex = expandedFAQIndex == 1 ? nil : 1 }
                                )
                                
                                FAQItemView(
                                    question: "Can I share my vehicle history?",
                                    answer: "Yes! You can share your vehicle's digital history with potential buyers or mechanics through a secure link. Navigate to your vehicle in the Digital Vault and tap the Share button.",
                                    isExpanded: expandedFAQIndex == 2,
                                    onTap: { expandedFAQIndex = expandedFAQIndex == 2 ? nil : 2 }
                                )
                                
                                FAQItemView(
                                    question: "What information should I store?",
                                    answer: "Store maintenance records, service receipts, inspection reports, accident history, insurance documents, and any other relevant vehicle documentation for a complete history.",
                                    isExpanded: expandedFAQIndex == 3,
                                    onTap: { expandedFAQIndex = expandedFAQIndex == 3 ? nil : 3 }
                                )
                                
                                FAQItemView(
                                    question: "Is there a cost to use AutoLegacy?",
                                    answer: "AutoLegacy offers a free tier with essential features. Premium features may be available in future updates. You'll always be notified of any changes.",
                                    isExpanded: expandedFAQIndex == 4,
                                    onTap: { expandedFAQIndex = expandedFAQIndex == 4 ? nil : 4 }
                                )
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                        // Troubleshooting Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppTheme.Layout.getStartedPrimaryButtonColor)
                                
                                Text("Troubleshooting")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            TroubleshootingItemView(
                                issue: "Login Issues",
                                solution: "Check your internet connection and verify your email/password. If you forgot your password, use the 'Forgot Password' option on the login screen."
                            )
                            
                            TroubleshootingItemView(
                                issue: "App Crashes",
                                solution: "Try updating to the latest version of AutoLegacy. Clear the app cache in Settings > Apps > AutoLegacy > Storage. Force close and restart the app."
                            )
                            
                            TroubleshootingItemView(
                                issue: "Sync Not Working",
                                solution: "Ensure you have a stable internet connection. Go to Settings > AutoLegacy Permissions and enable all required permissions. Try logging out and back in."
                            )
                            
                            TroubleshootingItemView(
                                issue: "Document Upload Fails",
                                solution: "Check file size (max 10MB) and format. Supported formats: PDF, JPG, PNG. Ensure sufficient storage space on your device."
                            )
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                        // Footer Info
                        VStack(alignment: .center, spacing: 12) {
                            Text("Still need help?")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Visit our support portal or check out our community forums for more resources and community support.")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .lineSpacing(2)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
        }
    }
}

// MARK: - Helper Views

struct ContactOptionView: View {
    var icon: String
    var label: String
    var value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Layout.getStartedPrimaryButtonColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct FAQItemView: View {
    var question: String
    var answer: String
    var isExpanded: Bool
    var onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(question)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.Layout.getStartedPrimaryButtonColor)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(12)
            }
            
            if isExpanded {
                Divider()
                    .background(Color.white.opacity(0.2))
                
                Text(answer)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(2)
                    .padding(12)
            }
        }
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct TroubleshootingItemView: View {
    var issue: String
    var solution: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Layout.getStartedPrimaryButtonColor)
                
                Text(issue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(solution)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .lineSpacing(2)
                .padding(.leading, 22)
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    HelpAndSupportView()
}
