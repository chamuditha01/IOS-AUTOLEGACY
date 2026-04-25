import SwiftUI

struct AboutUsView: View {
    @Environment(\.dismiss) var dismiss
    
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
                    
                    Text("About Us")
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
                        
                        // Top Logo Card
                        VStack(spacing: 20) {
                            // Logo Approximation
                            ZStack {
                                Path { path in
                                    path.move(to: CGPoint(x: 10, y: 40))
                                    path.addQuadCurve(to: CGPoint(x: 180, y: 40), control: CGPoint(x: 95, y: -20))
                                    path.move(to: CGPoint(x: 105, y: 15))
                                    path.addQuadCurve(to: CGPoint(x: 180, y: 40), control: CGPoint(x: 150, y: 20))
                                }
                                .stroke(Color.orange, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .frame(width: 190, height: 50)
                            }
                            .padding(.top, 20)
                            
                            Text("AutoLegacy")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("Version 1.0.0")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color.blue)
                                
                                Spacer()
                                
                                Text("Build 2026.03.12")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 20)
                            .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                        // Middle Info Card
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About AutoLegacy")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("AutoLegacy is a high-utility IOS application designed to eliminate the uncertainty of vehicle maintenance through data-driven analysis and secure record-keeping. The app solves the problem of \"missing history\" in the used car market by creating a verifiable digital \"passport\" for vehicles.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                        // Bottom Info Card
                        HStack {
                            Text("App Name")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Spacer()
                            
                            Text("AutoLegacy")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120) // padding for custom nav bar
                }
            }
        }
    }
}

#Preview {
    AboutUsView()
}