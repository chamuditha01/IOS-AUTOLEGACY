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
    private let userPasswordKey = "autolegacy_user_password"
    
    private init() {}
    
    // MARK: - Save Session Data
    
    func saveUserSession(userId: Int, name: String, mobile: String, password: String? = nil) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
        UserDefaults.standard.set(name, forKey: userNameKey)
        UserDefaults.standard.set(mobile, forKey: userMobileKey)
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        
        // Store password if provided (for Face ID auto-login)
        if let password = password {
            savePassword(password)
        }
        
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
    
    func getUserPassword() -> String? {
        return UserDefaults.standard.string(forKey: userPasswordKey)
    }
    
    private func savePassword(_ password: String) {
        UserDefaults.standard.set(password, forKey: userPasswordKey)
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
        UserDefaults.standard.removeObject(forKey: userPasswordKey)
        print("✅ Session cleared")
    }
    
    // MARK: - Logout
    
    func logout() async throws {
        try await logoutUser()
        clearSession()
    }
    
    // MARK: - Face Unlock Preferences
    
    private let faceUnlockEnabledKey = "autolegacy_face_unlock_enabled"
    
    func enableFaceUnlock(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: faceUnlockEnabledKey)
        print("👤 Face unlock \(enabled ? "enabled" : "disabled")")
    }
    
    func isFaceUnlockEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: faceUnlockEnabledKey)
    }
}
