import SwiftUI
import Charts

struct VehicleProfileView: View {
    @State private var vehiclesWithStats: [(vehicle: VehicleData, stats: VehicleStatData?)] = []
    @State private var selectedVehicleId: String = ""
    @State private var documents: [ProfileDocument] = []
    @State private var expenses: [ProfileExpense] = []
    @State private var fuelEntries: [ProfileFuel] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var selectedVehicleData: VehicleData? {
        vehiclesWithStats.first(where: { $0.vehicle.id == selectedVehicleId })?.vehicle
    }

    private var selectedVehicleStat: VehicleStatData? {
        vehiclesWithStats.first(where: { $0.vehicle.id == selectedVehicleId })?.stats
    }

    private var totalExpense: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    private var totalFuelCost: Double {
        fuelEntries.reduce(0) { $0 + Double($1.amount) }
    }

    private var expiringDocumentsCount: Int {
        let calendar = Calendar.current
        return documents.filter {
            guard let date = $0.expiryDate else { return false }
            guard let days = calendar.dateComponents([.day], from: Date(), to: date).day else { return false }
            return days <= 30
        }.count
    }

    private var monthlyExpenseData: [MonthlyExpensePoint] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        let grouped = Dictionary(grouping: expenses) { expense in
            let components = Calendar.current.dateComponents([.year, .month], from: expense.createdAtDate ?? Date())
            return DateComponents(year: components.year, month: components.month)
        }

        return grouped
            .compactMap { key, values in
                guard let year = key.year, let month = key.month,
                      let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: 1)) else {
                    return nil
                }

                return MonthlyExpensePoint(
                    monthLabel: formatter.string(from: date),
                    total: values.reduce(0) { $0 + $1.amount }
                )
            }
            .sorted { $0.monthLabel < $1.monthLabel }
    }

    private var expensesByReason: [ReasonExpensePoint] {
        let grouped = Dictionary(grouping: expenses) { expense in
            let normalized = expense.reason?.trimmingCharacters(in: .whitespacesAndNewlines)
            return (normalized?.isEmpty == false ? normalized! : "Other")
        }

        return grouped
            .map { ReasonExpensePoint(reason: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Gradients.auth.ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 34))
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await loadAllData() }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.12))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(20)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            ownerSection
                            vehicleSelectorSection
                            vehicleOverviewSection
                            statsSection
                            documentsSection
                            expensesSection
                            fuelSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 120)
                    }
                    .refreshable {
                        await loadAllData()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await loadAllData()
        }
    }

    private var ownerSection: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Owner Details")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                profileRow(title: "Name", value: SessionManager.shared.getUserName() ?? "Unknown")
                profileRow(title: "Mobile", value: SessionManager.shared.getUserMobile() ?? "Unknown")
                profileRow(title: "User ID", value: SessionManager.shared.getUserId().map(String.init) ?? "Unknown")
            }
        }
    }

    private var vehicleSelectorSection: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Vehicle")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Menu {
                    ForEach(vehiclesWithStats.map { $0.vehicle }, id: \.id) { vehicle in
                        Button("\(vehicle.make) \(vehicle.model)") {
                            selectedVehicleId = vehicle.id
                            Task { await loadVehicleRelatedData() }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedVehicleData.map { "\($0.make) \($0.model)" } ?? "Select Vehicle")
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white.opacity(0.65))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private var vehicleOverviewSection: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Vehicle Overview")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                profileRow(title: "Make", value: selectedVehicleData?.make ?? "-")
                profileRow(title: "Model", value: selectedVehicleData?.model ?? "-")
                profileRow(title: "Mileage", value: selectedVehicleData?.currentmileage.map { String(format: "%.0f km", $0) } ?? "-")
                profileRow(title: "Vehicle ID", value: selectedVehicleData?.id ?? "-")
            }
        }
    }

    private var statsSection: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Part Details & Vehicle Stats")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 10) {
                    statPill(title: "Oil", value: selectedVehicleStat?.Oil ?? "N/A", icon: "drop.fill")
                    statPill(title: "Tyres", value: selectedVehicleStat?.Tires ?? "N/A", icon: "circle.grid.2x2.fill")
                    statPill(title: "Battery", value: selectedVehicleStat?.Battery ?? "N/A", icon: "battery.100")
                }
            }
        }
    }

    private var documentsSection: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Document Expiry")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Text("Expiring <= 30d: \(expiringDocumentsCount)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange)
                }

                if documents.isEmpty {
                    emptyText("No documents for selected vehicle")
                } else {
                    ForEach(documents.prefix(4), id: \.id) { doc in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(doc.doctype.capitalized)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(doc.expirydate)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            Text(documentStatus(for: doc))
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(statusColor(for: doc).opacity(0.2))
                                .foregroundColor(statusColor(for: doc))
                                .clipShape(Capsule())
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    private var expensesSection: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Expenses")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                HStack {
                    summaryChip(title: "Total", value: String(format: "Rs %.2f", totalExpense))
                    summaryChip(title: "Entries", value: "\(expenses.count)")
                }

                if expenses.isEmpty {
                    emptyText("No expense records for selected vehicle")
                } else {
                    if #available(iOS 16.0, *) {
                        Chart(monthlyExpenseData) {
                            BarMark(
                                x: .value("Month", $0.monthLabel),
                                y: .value("Amount", $0.total)
                            )
                            .foregroundStyle(Color(red: 0.62, green: 0.73, blue: 0.96))
                            .cornerRadius(5)
                        }
                        .frame(height: 180)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }

                        Chart(expensesByReason) {
                            SectorMark(
                                angle: .value("Amount", $0.total),
                                innerRadius: .ratio(0.58)
                            )
                            .foregroundStyle(by: .value("Reason", $0.reason))
                        }
                        .frame(height: 190)
                    } else {
                        emptyText("Charts require iOS 16+.")
                    }

                    VStack(spacing: 8) {
                        ForEach(expensesByReason.prefix(4), id: \.reason) { item in
                            HStack {
                                Text(item.reason)
                                    .foregroundColor(.white.opacity(0.85))
                                Spacer()
                                Text(String(format: "Rs %.2f", item.total))
                                    .foregroundColor(.white)
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .font(.system(size: 12))
                        }
                    }
                }
            }
        }
    }

    private var fuelSection: some View {
        infoCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Fuel Details")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                HStack {
                    summaryChip(title: "Fuel Cost", value: String(format: "Rs %.2f", totalFuelCost))
                    summaryChip(title: "Fuel Entries", value: "\(fuelEntries.count)")
                }

                if fuelEntries.isEmpty {
                    emptyText("No fuel records for selected vehicle")
                } else {
                    ForEach(fuelEntries.prefix(5), id: \.id) { entry in
                        HStack {
                            Text(String(format: "Rs %.2f", Double(entry.amount)))
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Text(formattedDate(from: entry.created_at))
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.65))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }

    private func loadAllData() async {
        isLoading = true
        errorMessage = nil

        do {
            guard let userId = SessionManager.shared.getUserId() else {
                errorMessage = "User session not found"
                isLoading = false
                return
            }

            let fetched = try await fetchVehiclesForUser(userId: userId)

            await MainActor.run {
                vehiclesWithStats = fetched
                if selectedVehicleId.isEmpty {
                    selectedVehicleId = fetched.first?.vehicle.id ?? ""
                }
            }

            await loadVehicleRelatedData()

            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load profile data: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    private func loadVehicleRelatedData() async {
        guard let userId = SessionManager.shared.getUserId(), !selectedVehicleId.isEmpty else { return }

        do {
            async let docTask: [ProfileDocument] = supabase
                .from("document")
                .select("*")
                .eq("vehicleid", value: selectedVehicleId)
                .execute()
                .value

            async let expenseTask: [ProfileExpense] = supabase
                .from("expenses")
                .select("*")
                .eq("owner_id", value: userId)
                .eq("vehicle_id", value: selectedVehicleId)
                .execute()
                .value

            async let fuelTask: [ProfileFuel] = supabase
                .from("fuel")
                .select("*")
                .eq("ownerid", value: userId)
                .eq("vehicleid", value: selectedVehicleId)
                .execute()
                .value

            let (fetchedDocs, fetchedExpenses, fetchedFuel) = try await (docTask, expenseTask, fuelTask)

            await MainActor.run {
                documents = fetchedDocs.sorted { $0.expirydate < $1.expirydate }
                expenses = fetchedExpenses.sorted { ($0.createdAtDate ?? .distantPast) > ($1.createdAtDate ?? .distantPast) }
                fuelEntries = fetchedFuel.sorted { ($0.createdAtDate ?? .distantPast) > ($1.createdAtDate ?? .distantPast) }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed loading vehicle details: \(error.localizedDescription)"
            }
        }
    }

    private func profileRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(Color.white.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func statPill(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.85))
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.65))
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func summaryChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white.opacity(0.65))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
    }

    private func documentStatus(for document: ProfileDocument) -> String {
        guard let date = document.expiryDate else { return "UNKNOWN" }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0 { return "EXPIRED" }
        if days <= 30 { return "EXPIRING" }
        return "ACTIVE"
    }

    private func statusColor(for document: ProfileDocument) -> Color {
        switch documentStatus(for: document) {
        case "EXPIRED": return .red
        case "EXPIRING": return .orange
        default: return .green
        }
    }

    private func formattedDate(from raw: String?) -> String {
        guard let raw else { return "-" }

        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: raw) {
            let display = DateFormatter()
            display.dateFormat = "yyyy-MM-dd"
            return display.string(from: date)
        }

        if raw.count >= 10 {
            return String(raw.prefix(10))
        }

        return raw
    }
}

private struct ProfileDocument: Decodable {
    let id: String
    let vehicleid: String
    let doctype: String
    let expirydate: String

    var expiryDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: expirydate)
    }
}

private struct ProfileExpense: Decodable {
    let id: Int?
    let amount: Double
    let reason: String?
    let created_at: String?

    var createdAtDate: Date? {
        guard let created_at else { return nil }
        return ISO8601DateFormatter().date(from: created_at)
    }
}

private struct ProfileFuel: Decodable {
    let id: Int
    let amount: Float
    let created_at: String?

    var createdAtDate: Date? {
        guard let created_at else { return nil }
        return ISO8601DateFormatter().date(from: created_at)
    }
}

private struct MonthlyExpensePoint: Identifiable {
    let id = UUID()
    let monthLabel: String
    let total: Double
}

private struct ReasonExpensePoint {
    let reason: String
    let total: Double
}

#Preview {
    VehicleProfileView()
}
