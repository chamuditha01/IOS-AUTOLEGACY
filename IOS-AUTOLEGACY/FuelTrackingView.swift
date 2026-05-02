import SwiftUI

struct FuelTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""
    @State private var selectedVehicleId: String = ""
    @State private var vehicles: [VehicleData] = []
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccess = false

    var body: some View {
        ZStack {
            AppTheme.Gradients.auth.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Fuel Track")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)

                // Content
                if isLoading {
                    VStack {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            // Amount Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Fuel Amount (Liters)")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))

                                TextField("Enter amount", text: $amount)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .padding(16)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .keyboardType(.decimalPad)
                            }

                            // Vehicle Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Select Vehicle")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))

                                if vehicles.isEmpty {
                                    Text("No vehicles available")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)
                                } else {
                                    Menu {
                                        ForEach(vehicles, id: \.id) { vehicle in
                                            Button(action: {
                                                selectedVehicleId = vehicle.id
                                            }) {
                                                Text("\(vehicle.make) \(vehicle.model)")
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            if let selected = vehicles.first(where: { $0.id == selectedVehicleId }) {
                                                Text("\(selected.make) \(selected.model)")
                                                    .foregroundColor(.black)
                                            } else {
                                                Text("Choose vehicle")
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }

                            Spacer(minLength: 20)

                            // Save Button
                            Button(action: { handleSave() }) {
                                if isSaving {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Save")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.4, green: 0.6, blue: 1.0))
                            .cornerRadius(12)
                            .disabled(isSaving || amount.isEmpty || selectedVehicleId.isEmpty)
                            .opacity((isSaving || amount.isEmpty || selectedVehicleId.isEmpty) ? 0.6 : 1.0)
                        }
                        .padding(20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Fuel expense saved successfully!")
        }
        .onAppear {
            loadVehicles()
        }
    }

    private func loadVehicles() {
        isLoading = true
        Task {
            do {
                guard let userId = SessionManager.shared.getUserId() else {
                    errorMessage = "User not found"
                    showError = true
                    isLoading = false
                    return
                }

                let vehiclesWithStats = try await fetchVehiclesForUser(userId: userId)
                DispatchQueue.main.async {
                    self.vehicles = vehiclesWithStats.map { $0.vehicle }
                    if !vehicles.isEmpty {
                        selectedVehicleId = vehicles[0].id
                    }
                    isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to load vehicles: \(error.localizedDescription)"
                    showError = true
                    isLoading = false
                }
            }
        }
    }

    private func handleSave() {
        guard !amount.isEmpty else {
            errorMessage = "Please enter amount"
            showError = true
            return
        }

        guard let amountValue = Float(amount), amountValue > 0 else {
            errorMessage = "Please enter a valid amount"
            showError = true
            return
        }

        guard !selectedVehicleId.isEmpty else {
            errorMessage = "Please select a vehicle"
            showError = true
            return
        }

        isSaving = true
        Task {
            do {
                guard let userId = SessionManager.shared.getUserId() else {
                    errorMessage = "User not found"
                    showError = true
                    isSaving = false
                    return
                }

                print("📱 Saving fuel expense - amount: \(amountValue), vehicleId: \(selectedVehicleId), userId: \(userId)")
                try await saveFuelExpense(amount: amountValue, vehicleId: selectedVehicleId, userId: userId)

                DispatchQueue.main.async {
                    isSaving = false
                    showSuccess = true
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                    showError = true
                    isSaving = false
                }
            }
        }
    }
}

#Preview {
    FuelTrackingView()
}
