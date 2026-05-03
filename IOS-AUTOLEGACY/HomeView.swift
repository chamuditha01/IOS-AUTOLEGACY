import SwiftUI

struct HomeView: View {
    @State private var selectedVehicleIndex = 0
    @State private var vehicles: [Vehicle] = []
    @State private var isLoading = true
    @State private var showAlertView = false
    @State private var showFuelTracking = false
    @State private var showExpenseTracking = false

    private let serviceItems: [ServiceItem] = [
        .init(title: "Expenses", icon: "dollarsign.circle.fill"),
        .init(title: "Fuel", icon: "fuelpump.fill"),
        .init(title: "Service", icon: "wrench.and.screwdriver.fill")
    ]

    var body: some View {
        ZStack {
            AppTheme.Gradients.auth
                .ignoresSafeArea()

            if isLoading {
                VStack {
                    ProgressView()
                        .tint(AppTheme.Colors.whiteSurface)
                        .scaleEffect(1.5)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        topBar

                        if vehicles.isEmpty {
                            emptyState
                        } else {
                            vehicleCarousel
                        }

                        serviceReminder

                        Text("Services")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.Colors.whiteSurface)
                            .padding(.top, 4)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(serviceItems) { item in
                                    servicePill(item)
                                }
                            }
                            .padding(.trailing, 6)
                        }
                        .frame(height: 104)

                        securityAlerts
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 120)
                }
            }
        }
        .sheet(isPresented: $showFuelTracking) {
            FuelTrackingView()
        }
        .sheet(isPresented: $showExpenseTracking) {
            ExpenseSubmissionView()
        }
        .onAppear {
            fetchVehicles()
        }
    }

    private func fetchVehicles() {
        isLoading = true
        
        Task {
            do {
                guard let userId = SessionManager.shared.getUserId() else {
                    print("❌ No user ID found")
                    isLoading = false
                    return
                }
                
                print("📱 Fetching vehicles for user: \(userId)")
                let vehiclesWithStats = try await fetchVehiclesForUser(userId: userId)
                
                DispatchQueue.main.async {
                    vehicles = vehiclesWithStats.map { vehicleData, stats in
                        let oilValue = stats?.Oil ?? "N/A"
                        let tiresValue = stats?.Tires ?? "N/A"
                        let batteryValue = stats?.Battery ?? "N/A"
                        
                        // Determine status based on stats
                        let status = determineStatus(oil: oilValue, tires: tiresValue, battery: batteryValue)
                        
                        return Vehicle(
                            name: vehicleData.make,
                            model: vehicleData.model,
                            vin: vehicleData.id,
                            status: status.name,
                            statusColor: status.color,
                            bodyColor: Color.blue.opacity(0.9),
                            metrics: [
                                .init(title: "OIL LIFE", value: oilValue, icon: "steeringwheel"),
                                .init(title: "TYRES", value: tiresValue, icon: "exclamationmark.tirepressure"),
                                .init(title: "BATTERY", value: batteryValue, icon: "battery.75")
                            ]
                        )
                    }
                    isLoading = false
                }
            } catch {
                print("❌ Error fetching vehicles: \(error)")
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }

    private func determineStatus(oil: String, tires: String, battery: String) -> (name: String, color: Color) {
        // Parse values and determine overall status
        let oilPercent = Int(oil.replacingOccurrences(of: "%", with: "")) ?? 50
        let tiresPercent = Int(tires.replacingOccurrences(of: "%", with: "")) ?? 50
        let batteryPercent = Int(battery.replacingOccurrences(of: "%", with: "")) ?? 50
        
        let minValue = min(oilPercent, tiresPercent, batteryPercent)
        
        if minValue < 50 {
            return ("CRITICAL", Color.red.opacity(0.95))
        } else if minValue < 70 {
            return ("NEEDS CHECK", Color.orange.opacity(0.95))
        } else {
            return ("EXCELLENT", Color(red: 0.66, green: 1.0, blue: 0.68))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "car.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.Colors.whiteSurface.opacity(0.5))
            
            Text("No Vehicles Found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.whiteSurface)
            
            Text("Add a vehicle to get started")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.Colors.whiteSurface.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    private var topBar: some View {
        HStack {
            Text("AutoLegacy")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.Colors.whiteSurface)

            Spacer()

            Button(action: {
                        // 2. Set this to true when tapped
                        showAlertView = true
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.whiteSurface)
                            .frame(width: 42, height: 42)
                    }
                    // 3. Attach the sheet modifier
                    .sheet(isPresented: $showAlertView) {
                        AlertsView()
                    }
        }
        .padding(.top, 4)
    }

    private var vehicleCarousel: some View {
        VStack(spacing: 15) {
            TabView(selection: $selectedVehicleIndex) {
                ForEach(Array(vehicles.enumerated()), id: \.offset) { index, vehicle in
                    vehicleCard(vehicle)
                        .padding(.horizontal, 10) // Small gap between cards
                        .tag(index)
                }
            }
            .frame(height: 400) // Slightly taller to accommodate better spacing
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Custom Pagination Dots
            HStack(spacing: 8) {
                ForEach(vehicles.indices, id: \.self) { index in
                    Circle()
                        .fill(index == selectedVehicleIndex ? AppTheme.Colors.whiteSurface : AppTheme.Colors.whiteSurface.opacity(0.2))
                        .frame(width: index == selectedVehicleIndex ? 10 : 6, height: 6)
                        .scaleEffect(index == selectedVehicleIndex ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedVehicleIndex)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func vehicleCard(_ vehicle: Vehicle) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header Row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vehicle.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(vehicle.model)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                statusBadge(vehicle)
            }

            // VIN Number with a "Tag" look
            Text(vehicle.vin)
                .font(.system(.caption, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white.opacity(0.5))
                .cornerRadius(6)

            // Hero Image Section
            carHeroImage(bodyColor: vehicle.bodyColor)
                .frame(maxWidth: .infinity)
                .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 10)

            // Bottom Metrics
            HStack(spacing: 12) {
                ForEach(vehicle.metrics) { metric in
                    metricTile(title: metric.title, value: metric.value, icon: metric.icon)
                        .frame(maxWidth: .infinity) // Ensures tiles are equal width
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(
                    colors: [Color(white: 0.15), Color(white: 0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    private func statusBadge(_ vehicle: Vehicle) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 10, weight: .semibold))
            Text(vehicle.status)
                .font(.system(size: 10, weight: .bold, design: .rounded))
        }
        .foregroundColor(vehicle.statusColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(vehicle.statusColor.opacity(0.18))
        .clipShape(Capsule())
    }

    private func carHeroImage(bodyColor: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.20, green: 0.20, blue: 0.22), Color(red: 0.10, green: 0.10, blue: 0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 128)

            LinearGradient(
                colors: [bodyColor.opacity(0.55), bodyColor.opacity(0.18), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .frame(height: 128)

            Image(systemName: "car.side.fill")
                .font(.system(size: 74, weight: .light))
                .foregroundColor(bodyColor)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 8)
                .offset(y: 8)
        }
    }

    private func metricTile(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.76, green: 0.84, blue: 1.0))

            Text(title)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.Colors.whiteSurface.opacity(0.65))

            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.whiteSurface)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var serviceReminder: some View {
        HStack(spacing: 10) {
            Image(systemName: "triangle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(red: 0.65, green: 0.82, blue: 1.0))

            Text("Your Next service is on 70000km")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.72, green: 0.83, blue: 1.0))

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.18))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.28), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func servicePill(_ item: ServiceItem) -> some View {
        Button(action: {
            if item.title == "Fuel" {
                showFuelTracking = true
            } else if item.title == "Expenses" {
                showExpenseTracking = true
            }
        }) {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: item.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.whiteSurface.opacity(0.75))

                Spacer()

                Text(item.title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.Colors.whiteSurface.opacity(0.9))
            }
            .padding(14)
            .frame(width: 108, height: 92, alignment: .leading)
            .background(Color.white.opacity(0.10))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var securityAlerts: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Security & Alerts")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.whiteSurface)

            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.45, green: 0.04, blue: 0.06))

                VStack(alignment: .leading, spacing: 2) {
                    Text("DOCUMENT ALERT")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.45, green: 0.04, blue: 0.06))
                    Text("Insurance Expiring in 2 days")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.45, green: 0.04, blue: 0.06))
                }

                Spacer()
            }
            .padding(14)
            .background(Color(red: 1.0, green: 0.71, blue: 0.67))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(20)
        .background(Color.black.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct ServiceItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

private struct Vehicle: Identifiable {
    let id = UUID()
    let name: String
    let model: String
    let vin: String
    let status: String
    let statusColor: Color
    let bodyColor: Color
    let metrics: [VehicleMetric]
}

private struct VehicleMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
}

#Preview {
    MainTabView()
}
