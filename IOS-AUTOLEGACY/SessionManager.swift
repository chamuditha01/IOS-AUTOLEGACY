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
    private let userEmailKey = "autolegacy_user_email"
    private let isLoggedInKey = "autolegacy_is_logged_in"
    
    private init() {}
    
    // MARK: - Save Session Data
    
    func saveUserSession(userId: String, email: String) {
        UserDefaults.standard.set(userId, forKey: userIdKey)
        UserDefaults.standard.set(email, forKey: userEmailKey)
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        print("✅ Session saved for user: \(userId)")
    }
    
    // MARK: - Retrieve Session Data
    
    func getUserId() -> String? {
        return UserDefaults.standard.string(forKey: userIdKey)
    }
    
    func getUserEmail() -> String? {
        return UserDefaults.standard.string(forKey: userEmailKey)
    }
    
    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: isLoggedInKey)
    }
    
    // MARK: - Clear Session Data
    
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)
        UserDefaults.standard.removeObject(forKey: isLoggedInKey)
        print("✅ Session cleared")
    }
    
    // MARK: - Logout
    
    func logout() async throws {
        try await logoutUser()
        clearSession()
    }
}
