import SwiftUI

struct DigitalVaultView: View {
    var body: some View {
        ZStack {
            Color(red: 0.23, green: 0.29, blue: 0.38)
                .ignoresSafeArea()
            
            VStack {
                // Custom Header
                HStack {
                    Button(action: {
                        // Back action if needed, though usually tab handles it or we don't need back if it's a top level tab
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Digital Vault")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Insurance Card
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("INSURANCE")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                    .tracking(1.5)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("ACTIVE")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(Color(red: 0.16, green: 0.65, blue: 0.27))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.16, green: 0.65, blue: 0.27).opacity(0.2))
                                .clipShape(Capsule())
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Image placeholder
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.2))
                                    .frame(height: 180)
                                
                                Text("INSURANCE")
                                    .font(.system(size: 24, weight: .black, design: .serif))
                                    .italic()
                                    .foregroundColor(.black.opacity(0.4))
                                    .rotationEffect(.degrees(-15))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("STATUS")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text("Valid until 2025")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(red: 0.32, green: 0.77, blue: 0.38))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("342")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(red: 0.62, green: 0.73, blue: 0.96))
                                    Text("DAYS LEFT")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                        }
                        .background(Color(red: 0.14, green: 0.15, blue: 0.16))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                        // Registration Card
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("REGISTRATION")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                    .tracking(1.5)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("EXPIRING SOON")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(Color(red: 0.96, green: 0.53, blue: 0.53))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.96, green: 0.53, blue: 0.53).opacity(0.2))
                                .clipShape(Capsule())
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Image placeholder
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(ColorInterpolation().gradient()) // Placeholder
                                    .frame(height: 180)
                                
                                Circle()
                                    .strokeBorder(Color.gray, lineWidth: 4)
                                    .background(Circle().fill(Color(white: 0.25)))
                                    .frame(width: 80, height: 80)
                                    .offset(y: 40)
                                    .mask(Rectangle().padding(.bottom, 40))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            Spacer()
                                .frame(height: 30) // To give space since image cuts off
                        }
                        .background(Color(red: 0.14, green: 0.15, blue: 0.16))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120) // padding for custom nav bar
                }
            }
        }
    }
}

// Helper gradient for placeholder
struct ColorInterpolation {
    func gradient() -> LinearGradient {
        LinearGradient(
            colors: [Color(white: 0.4), Color(white: 0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    DigitalVaultView()
}