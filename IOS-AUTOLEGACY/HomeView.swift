import SwiftUI

struct HomeView: View {
    @State private var selectedVehicleIndex = 0

    private let serviceItems: [ServiceItem] = [
        .init(title: "Expenses", icon: "dollarsign.circle.fill"),
        .init(title: "Fuel", icon: "fuelpump.fill"),
        .init(title: "Service", icon: "wrench.and.screwdriver.fill")
    ]

    private let vehicles: [Vehicle] = [
        .init(name: "2026 Ford", model: "Mustang GT", vin: "WBA53AK06NSXXXX", status: "EXCELLENT", statusColor: Color(red: 0.66, green: 1.0, blue: 0.68), bodyColor: Color.yellow.opacity(0.95), metrics: [
            .init(title: "OIL LIFE", value: "92%", icon: "steeringwheel"),
            .init(title: "TYRES", value: "70%", icon: "exclamationmark.tirepressure"),
            .init(title: "BATTERY", value: "80%", icon: "battery.75")
        ]),
        .init(name: "2025 BMW", model: "M4 Competition", vin: "WBX98QJ24ZZXXXX", status: "NEEDS CHECK", statusColor: Color.orange.opacity(0.95), bodyColor: Color.blue.opacity(0.9), metrics: [
            .init(title: "OIL LIFE", value: "78%", icon: "steeringwheel"),
            .init(title: "TYRES", value: "61%", icon: "exclamationmark.tirepressure"),
            .init(title: "BATTERY", value: "88%", icon: "battery.75")
        ]),
        .init(name: "2024 Audi", model: "RS5 Sportback", vin: "WAU12PL77AXXXXX", status: "GOOD", statusColor: Color.green.opacity(0.95), bodyColor: Color.red.opacity(0.85), metrics: [
            .init(title: "OIL LIFE", value: "85%", icon: "steeringwheel"),
            .init(title: "TYRES", value: "74%", icon: "exclamationmark.tirepressure"),
            .init(title: "BATTERY", value: "90%", icon: "battery.75")
        ])
    ]

    var body: some View {
        ZStack {
            AppTheme.Gradients.auth
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    topBar

                    vehicleCarousel

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

    private var topBar: some View {
        HStack {
            Text("AutoLegacy")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.Colors.whiteSurface)

            Spacer()

            Image(systemName: "bell")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.whiteSurface)
                .frame(width: 42, height: 42)
        }
        .padding(.top, 4)
    }

    private var vehicleCarousel: some View {
        VStack(alignment: .leading, spacing: 10) {
            TabView(selection: $selectedVehicleIndex) {
                ForEach(Array(vehicles.enumerated()), id: \.offset) { index, vehicle in
                    vehicleCard(vehicle)
                        .tag(index)
                        .padding(.vertical, 2)
                }
            }
            .frame(height: 360)
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 6) {
                ForEach(vehicles.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == selectedVehicleIndex ? AppTheme.Colors.whiteSurface : AppTheme.Colors.whiteSurface.opacity(0.35))
                        .frame(width: index == selectedVehicleIndex ? 18 : 7, height: 7)
                        .animation(.easeInOut(duration: 0.2), value: selectedVehicleIndex)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 2)
        }
    }

    private func vehicleCard(_ vehicle: Vehicle) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(vehicle.name)
                    Text(vehicle.model)
                }
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.Colors.whiteSurface)

                Spacer()

                statusBadge(vehicle)
            }

            Text(vehicle.vin)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.Colors.whiteSurface.opacity(0.75))

            carHeroImage(bodyColor: vehicle.bodyColor)

            HStack(spacing: 10) {
                ForEach(vehicle.metrics) { metric in
                    metricTile(title: metric.title, value: metric.value, icon: metric.icon)
                }
            }
        }
        .padding(18)
        .background(Color.black.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
    HomeView()
}
