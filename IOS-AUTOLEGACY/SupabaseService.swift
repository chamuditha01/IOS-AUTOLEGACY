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
        print("📱 Checking if mobile \(mobile) already exists...")
        
        // Try querying with mobile as string first
        var existingUsers: [User] = try await supabase
            .from("users")
            .select("*")
            .eq("mobile", value: mobile)
            .execute()
            .value
        
        print("📱 Found \(existingUsers.count) users with mobile as string")
        
        // If not found as string, try converting to number since mobile column is numeric
        if existingUsers.isEmpty, let mobileNumber = Int(mobile) {
            print("📱 Trying to query with mobile as number: \(mobileNumber)")
            existingUsers = try await supabase
                .from("users")
                .select("*")
                .eq("mobile", value: mobileNumber)
                .execute()
                .value
            print("📱 Found \(existingUsers.count) users with mobile as number")
        }
        
        guard existingUsers.isEmpty else {
            print("❌ Mobile number already registered")
            throw NSError(domain: "Auth", code: -3, userInfo: [NSLocalizedDescriptionKey: "Mobile number already registered"])
        }
        
        // Insert new user
        print("📱 Inserting new user with mobile: \(mobile)")
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

// MARK: - Vehicle Management

struct VehicleData: Decodable {
    let id: String
    let make: String
    let model: String
    let currentmileage: Float?
    let ownerIdValue: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case make
        case model
        case currentmileage
        case owner_id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        make = try container.decode(String.self, forKey: .make)
        model = try container.decode(String.self, forKey: .model)
        currentmileage = try? container.decode(Float.self, forKey: .currentmileage)
        
        // Handle owner_id - could be string or number
        var ownerIdStr: String? = nil
        
        // Try to decode as String first
        if let ownerId = try? container.decode(String.self, forKey: .owner_id) {
            ownerIdStr = ownerId
        }
        // If that fails, try as Int and convert to String
        else if let ownerId = try? container.decode(Int.self, forKey: .owner_id) {
            ownerIdStr = String(ownerId)
        }
        
        self.ownerIdValue = ownerIdStr
    }
    
    var getOwnerId: String? {
        return ownerIdValue
    }
}

struct VehicleStatData: Decodable {
    let idValue: String?
    let Oil: String?
    let Tires: String?
    let Battery: String?
    let vehicleid: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case Oil
        case Tires
        case Battery
        case vehicleid
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        Oil = try? container.decode(String.self, forKey: .Oil)
        Tires = try? container.decode(String.self, forKey: .Tires)
        Battery = try? container.decode(String.self, forKey: .Battery)
        vehicleid = try container.decode(String.self, forKey: .vehicleid)
        
        // Handle id - could be string or number (int8)
        var idStr: String? = nil
        
        // Try to decode as String first
        if let id = try? container.decode(String.self, forKey: .id) {
            idStr = id
        }
        // If that fails, try as Int and convert to String
        else if let id = try? container.decode(Int.self, forKey: .id) {
            idStr = String(id)
        }
        
        self.idValue = idStr
    }
    
    var getId: String? {
        return idValue
    }
}

func fetchVehiclesForUser(userId: Int) async throws -> [(vehicle: VehicleData, stats: VehicleStatData?)] {
    do {
        print("📱 Fetching vehicles for user ID: \(userId)...")
        
        // Fetch all vehicles for the user - owner_id is numeric in database
        let vehicles: [VehicleData] = try await supabase
            .from("vehicle")
            .select("*")
            .eq("owner_id", value: userId)
            .execute()
            .value
        
        print("✅ Found \(vehicles.count) vehicles")
        
        // For each vehicle, fetch its stats
        var vehiclesWithStats: [(vehicle: VehicleData, stats: VehicleStatData?)] = []
        
        for vehicle in vehicles {
            print("📱 Fetching stats for vehicle: \(vehicle.id)")
            let stats: [VehicleStatData] = try await supabase
                .from("vehiclestat")
                .select("*")
                .eq("vehicleid", value: vehicle.id)
                .execute()
                .value
            
            vehiclesWithStats.append((vehicle: vehicle, stats: stats.first))
            print("✅ Vehicle \(vehicle.id): oil=\(stats.first?.Oil ?? "N/A"), tires=\(stats.first?.Tires ?? "N/A"), battery=\(stats.first?.Battery ?? "N/A")")
        }
        
        print("✅ Fetched \(vehiclesWithStats.count) vehicles with stats")
        return vehiclesWithStats
    } catch {
        print("❌ Failed to fetch vehicles: \(error)")
        throw error
    }
}
