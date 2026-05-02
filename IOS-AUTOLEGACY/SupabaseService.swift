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
    let name: String?
    let mobileValue: String?
    let password: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case mobile
        case phone
        case password
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
        password = try? container.decode(String.self, forKey: .password)
        
        // Handle mobile - could be string or number
        var mobileStr: String? = nil
        
        // Try to decode as String first
        if let mobile = try? container.decode(String.self, forKey: .mobile) {
            mobileStr = mobile
        }
        // If that fails, try as Int and convert to String
        else if let mobile = try? container.decode(Int.self, forKey: .mobile) {
            mobileStr = String(mobile)
        }
        // Try phone column as String
        else if let phone = try? container.decode(String.self, forKey: .phone) {
            mobileStr = phone
        }
        // Try phone column as Int and convert to String
        else if let phone = try? container.decode(Int.self, forKey: .phone) {
            mobileStr = String(phone)
        }
        
        self.mobileValue = mobileStr
    }
    
    // Get mobile
    var getMobile: String? {
        return mobileValue
    }
    
    // Get name - default to empty if not found
    var getName: String {
        return name ?? "User"
    }
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
            // Try with 'phone' column if 'mobile' didn't work
            let usersPhone: [User] = try await supabase
                .from("users")
                .select("*")
                .eq("phone", value: mobile)
                .execute()
                .value
            
            guard let phoneUser = usersPhone.first else {
                throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
            
            guard phoneUser.password == password else {
                throw NSError(domain: "Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid password"])
            }
            
            guard let userMobile = phoneUser.getMobile else {
                throw NSError(domain: "Auth", code: -4, userInfo: [NSLocalizedDescriptionKey: "Mobile number not found"])
            }
            
            print("✅ Login successful for user: \(phoneUser.id)")
            return (id: phoneUser.id, name: phoneUser.getName, mobile: userMobile)
        }
        
        // Verify password
        guard user.password == password else {
            throw NSError(domain: "Auth", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid password"])
        }
        
        guard let userMobile = user.getMobile else {
            throw NSError(domain: "Auth", code: -4, userInfo: [NSLocalizedDescriptionKey: "Mobile number not found"])
        }
        
        print("✅ Login successful for user: \(user.id)")
        return (id: user.id, name: user.getName, mobile: userMobile)
    } catch {
        print("❌ Login failed: \(error)")
        throw error
    }
}

func signUpWithMobileAndPassword(name: String, mobile: String, password: String) async throws -> (id: Int, name: String, mobile: String) {
    do {
        // Check if mobile already exists in 'mobile' column
        let existingUsers: [User] = try await supabase
            .from("users")
            .select("*")
            .eq("mobile", value: mobile)
            .execute()
            .value
        
        // Also check 'phone' column as fallback
        let existingPhoneUsers: [User] = try await supabase
            .from("users")
            .select("*")
            .eq("phone", value: mobile)
            .execute()
            .value
        
        guard existingUsers.isEmpty && existingPhoneUsers.isEmpty else {
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
        
        guard let userMobile = newUser.getMobile else {
            throw NSError(domain: "Auth", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve mobile number"])
        }
        
        print("✅ Signup successful for user: \(newUser.id)")
        return (id: newUser.id, name: newUser.getName, mobile: userMobile)
    } catch {
        print("❌ Signup failed: \(error)")
        throw error
    }
}

func logoutUser() async throws {
    // Since we're using custom mobile+password auth (not Supabase auth),
    // we just need to clear the session which is handled by SessionManager
    print("✅ User logged out successfully")
}

func getCurrentUser() async throws -> Int? {
    // Return nil - session is managed by SessionManager
    return SessionManager.shared.getUserId()
}
