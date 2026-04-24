import SwiftUI

enum AppTab: String, CaseIterable {
    case home = "Home"
    case vault = "Vault"
    case map = "Map"
    case profile = "Profile"
    case setting = "Setting"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .vault: return "calendar.badge.clock" // Or anything matching the image
        case .map: return "map.fill"
        case .profile: return "person.fill"
        case .setting: return "gearshape.fill"
        }
    }
}
