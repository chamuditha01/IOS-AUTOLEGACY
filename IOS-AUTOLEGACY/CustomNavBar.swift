import SwiftUI

struct CustomNavBar: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .semibold))
                        Text(tab.rawValue)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(selectedTab == tab ? AppTheme.Colors.phoneBlue : .black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(Color.black.opacity(0.08))
                                    .padding(4)
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.white.opacity(1))
        .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 50, style: .continuous)
                .stroke(Color.white.opacity(1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(1), radius: 50, x: 0, y: 20)
    }
}
