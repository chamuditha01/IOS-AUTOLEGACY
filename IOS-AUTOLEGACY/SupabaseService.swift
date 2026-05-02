//
//  SupabaseService.swift
//  IOS-AUTOLEGACY
//
//  Created by Dileesha on 2026-04-23.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://ilzdfeewtdehthtpowng.supabase.co")!,
    supabaseKey: "sb_publishable_kRtXgeYk13wdFQYqZX84-w_nekOxehA"
)

func checkConnection() async {
    do {
        // 1. Define a type that Supabase can decode (even if it's just a dummy)
        // If your 'todos' table has an 'id' column, this will work.
        struct TodoCheck: Decodable {
            let id: Int
        }
        
        // 2. Fetch the data
        let _: [TodoCheck] = try await supabase
            .from("todos")
            .select("id") // Only select the ID to save bandwidth
            .limit(1)
            .execute()
            .value
        
        print("✅ Successfully connected to Supabase!")
        
    } catch {
        // 3. Catch the error
        print("❌ Connection failed: \(error)")
    }
}

// MARK: - Authentication Functions

func loginWithEmail(email: String, password: String) async throws -> String {
    do {
        let session = try await supabase.auth.signIn(email: email, password: password)
        let userId = session.user.id.uuidString
        print("✅ Login successful for user: \(userId)")
        return userId
    } catch {
        print("❌ Login failed: \(error)")
        throw error
    }
}

func signUpWithEmail(email: String, password: String) async throws -> String {
    do {
        let session = try await supabase.auth.signUp(email: email, password: password)
        let userId = session.user?.id.uuidString ?? ""
        print("✅ Signup successful for user: \(userId)")
        return userId
    } catch {
        print("❌ Signup failed: \(error)")
        throw error
    }
}

func logoutUser() async throws {
    do {
        try await supabase.auth.signOut()
        print("✅ User logged out successfully")
    } catch {
        print("❌ Logout failed: \(error)")
        throw error
    }
}

func getCurrentUser() async throws -> String? {
    do {
        let session = try await supabase.auth.session
        return session.user.id.uuidString
    } catch {
        print("❌ Failed to get current user: \(error)")
        return nil
    }
}
