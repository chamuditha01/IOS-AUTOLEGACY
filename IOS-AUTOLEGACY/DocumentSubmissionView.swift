import SwiftUI
import Supabase

struct DocumentSubmissionView: View {
    @State private var expiryDate = Date()
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showSuccess = false
    @State private var selectedVehicle: VehicleData?
    @State private var vehicles: [VehicleData] = []
    
    let documentType: String
    let documentImage: String
    let onSuccess: () -> Void
    @Environment(\.dismiss) var dismiss
    
    let documentInfo: [String: (icon: String, image: String)] = [
        "insurance": (icon: "lock.shield.fill", image: "https://i.ibb.co/yjryBHR/Gemini-Generated-Image-b5g2ynb5g2ynb5g2.png"),
        "driving license": (icon: "card.fill", image: "https://i.ibb.co/rRT6JHBF/Gemini-Generated-Image-k2z2dek2z2dek2z2.png"),
        "vehicle license": (icon: "paperclip", image: "https://i.ibb.co/ntR8943/Gemini-Generated-Image-i4oj76i4oj76i4oj.png")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.23, green: 0.29, blue: 0.38)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Add \(documentType.capitalized)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Document Preview
                        VStack(spacing: 16) {
                            Text("DOCUMENT PREVIEW")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1.2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.14, green: 0.15, blue: 0.16))
                                    .frame(height: 200)
                                
                                AsyncImage(url: URL(string: documentImage)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } placeholder: {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Vehicle Selection
                        VStack(spacing: 12) {
                            Text("SELECT VEHICLE")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1.2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Menu {
                                ForEach(vehicles, id: \.id) { vehicle in
                                    Button(action: { selectedVehicle = vehicle }) {
                                        HStack {
                                            Text("\(vehicle.make ?? "Unknown") \(vehicle.model ?? "")")
                                            if selectedVehicle?.id == vehicle.id {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedVehicle?.make ?? "Select Vehicle")
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Expiry Date Picker
                        VStack(spacing: 12) {
                            Text("EXPIRY DATE")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1.2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.white.opacity(0.6))
                                
                                DatePicker("", selection: $expiryDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .environment(\.locale, Locale(identifier: "en_GB"))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button(action: handleSave) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .frame(width: 20, height: 20)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                
                                Text(isLoading ? "Saving..." : "Save Document")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.62, green: 0.73, blue: 0.96))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .opacity(isLoading || selectedVehicle == nil ? 0.6 : 1)
                        }
                        .disabled(isLoading || selectedVehicle == nil)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") {
                showSuccess = false
                onSuccess()
                dismiss()
            }
        } message: {
            Text("Document saved successfully!")
        }
        .task {
            await loadVehicles()
        }
    }
    
    private func loadVehicles() async {
        do {
            guard let userId = SessionManager.shared.getUserId() else {
                errorMessage = "User not found"
                showError = true
                return
            }
            
            let result = try await fetchVehiclesForUser(userId: userId)
            DispatchQueue.main.async {
                self.vehicles = result.map { $0.0 }
                if !self.vehicles.isEmpty {
                    self.selectedVehicle = self.vehicles.first
                }
            }
        } catch {
            if error is CancellationError {
                print("ℹ️ Vehicle fetch cancelled (view was dismissed)")
            } else {
                print("❌ Failed to load vehicles: \(error.localizedDescription)")
                errorMessage = "Failed to load vehicles"
                showError = true
            }
        }
    }
    
    private func handleSave() {
        guard let vehicle = selectedVehicle else {
            errorMessage = "Please select a vehicle"
            showError = true
            return
        }
        
        isLoading = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let expiryDateString = formatter.string(from: expiryDate)
        
        Task {
            do {
                try await saveDocument(
                    vehicleId: vehicle.id,
                    doctype: documentType,
                    expirydate: expiryDateString,
                    filepath: documentImage
                )
                
                DispatchQueue.main.async {
                    isLoading = false
                    showSuccess = true
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct DocumentSubmissionView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentSubmissionView(
            documentType: "insurance",
            documentImage: "https://i.ibb.co/yjryBHR/Gemini-Generated-Image-b5g2ynb5g2ynb5g2.png",
            onSuccess: {}
        )
    }
}
