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

struct User: Decodable {
    let id: Int
    let name: String
    let mobile: String
    let password: String
}

func loginWithMobileAndPassword(mobile: String, password: String) async throws -> (id: Int, name: String, mobile: String) {
    do {
        let users: [User] = try await supabase
            .from("users")
            .select("*")
            .eq("mobile", value: mobile)
            .execute()
            .value
        
        guard let user = users.first else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        // Verify password (simple comparison - in production, use bcrypt/hashed comparison)
        guard user.password == password else {
            throw NSError(domain: "Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid password"])
        }
        
        print("✅ Login successful for user: \(user.id)")
        return (id: user.id, name: user.name, mobile: user.mobile)
    } catch {
        print("❌ Login failed: \(error)")
        throw error
    }
}

func signUpWithMobileAndPassword(name: String, mobile: String, password: String) async throws -> (id: Int, name: String, mobile: String) {
    do {
<<<<<<< HEAD
        let session = try await supabase.auth.signUp(email: email, password: password)
        let userId = session.user.id.uuidString ?? ""
        print("✅ Signup successful for user: \(userId)")
        return userId
=======
        // Check if mobile already exists
        let existingUsers: [User] = try await supabase
            .from("users")
            .select("*")
            .eq("mobile", value: mobile)
            .execute()
            .value
        
        guard existingUsers.isEmpty else {
            throw NSError(domain: "Auth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Mobile number already registered"])
        }
        
        // Insert new user
        let newUser: User = try await supabase
            .from("users")
            .insert([
                ["name": name, "mobile": mobile, "password": password]
            ])
            .select()
            .single()
            .execute()
            .value
        
        print("✅ Signup successful for user: \(newUser.id)")
        return (id: newUser.id, name: newUser.name, mobile: newUser.mobile)
>>>>>>> dev
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
