//
//  SessionManager.swift
//  IOS-AUTOLEGACY
//
//  Created by Dileesha on 2026-05-02.
//

import Foundation

class SessionManager {
    static let shared = SessionManager()
    
    private let userIdKey = "autolegacy_user_id"
    private let userNameKey = "autolegacy_user_name"
    private let userMobileKey = "autolegacy_user_mobile"
    private let isLoggedInKey = "autolegacy_is_logged_in"
    
    private init() {}
    
    // MARK: - Save Session Data
    
    func saveUserSession(userId: Int, name: String, mobile: String) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
        UserDefaults.standard.set(name, forKey: userNameKey)
        UserDefaults.standard.set(mobile, forKey: userMobileKey)
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        print("✅ Session saved for user: \(userId)")
    }
    
    // MARK: - Retrieve Session Data
    
    func getUserId() -> Int? {
        let id = UserDefaults.standard.integer(forKey: userIdKey)
        return id > 0 ? id : nil
    }
    
    func getUserName() -> String? {
        return UserDefaults.standard.string(forKey: userNameKey)
    }
    
    func getUserMobile() -> String? {
        return UserDefaults.standard.string(forKey: userMobileKey)
    }
    
    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: isLoggedInKey)
    }
    
    // MARK: - Clear Session Data
    
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: userMobileKey)
        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
        print("✅ Session cleared")
    }
    
    // MARK: - Logout
    
    func logout() async throws {
        try await logoutUser()
        clearSession()
    }
}
