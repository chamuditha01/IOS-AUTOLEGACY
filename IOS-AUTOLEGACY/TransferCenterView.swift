import SwiftUI
import AVFoundation
import LocalAuthentication
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Supabase
import PostgREST
import CryptoKit

struct TransferCenterView: View {
    @State private var mode: TransferMode = .seller
    @State private var ownedVehicles: [VehicleData] = []
    @State private var selectedVehicleId: String = ""
    @State private var generatedTransfer: TransferSession?
    @State private var generatedQRCode: UIImage?
    @State private var scannedTransfer: TransferScanPayload?
    @State private var scannedVehicle: VehicleData?
    @State private var isLoading = true
    @State private var isProcessing = false
    @State private var showScanner = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAdvanced = false
    @State private var customGenerateInput: String = UserDefaults.standard.string(forKey: "transfer_generate_functions") ?? ""
    @State private var customConfirmInput: String = UserDefaults.standard.string(forKey: "transfer_confirm_functions") ?? ""
    
    // QR Image Upload for Buyers (select from app Assets)
    @State private var uploadedQRImage: UIImage?
    @State private var qrImageFilename: String?
    
    // Seller: buyer phone input to bind with token
    @State private var buyerPhoneInput: String = ""
    
    // Buyer: manual token input
    @State private var buyerTokenInput: String = ""

    private var selectedVehicle: VehicleData? {
        ownedVehicles.first { $0.id == selectedVehicleId }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                header
                modePicker

                if mode == .seller {
                    sellerPanel
                } else {
                    buyerPanel
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .background(transferBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadOwnedVehicles()
        }
        .sheet(isPresented: $showScanner) {
            QRScannerSheet { scannedString in
                handleScannedValue(scannedString)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showAdvanced) {
            NavigationStack {
                Form {
                    Section(header: Text("Custom Edge Function Names (comma separated)")) {
                        TextField("Generate candidates", text: $customGenerateInput)
                        TextField("Confirm candidates", text: $customConfirmInput)
                    }
                    Section {
                        Button("Save") {
                            UserDefaults.standard.set(customGenerateInput, forKey: "transfer_generate_functions")
                            UserDefaults.standard.set(customConfirmInput, forKey: "transfer_confirm_functions")
                            showAdvanced = false
                        }
                        .foregroundColor(.blue)
                        Button("Reset to defaults", role: .destructive) {
                            UserDefaults.standard.removeObject(forKey: "transfer_generate_functions")
                            UserDefaults.standard.removeObject(forKey: "transfer_confirm_functions")
                            customGenerateInput = ""
                            customConfirmInput = ""
                        }
                    }
                }
                .navigationTitle("Transfer Advanced")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { showAdvanced = false } } }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Transfer Center")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Secure vehicle handover with Face ID, QR codes, and live Supabase data.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                InfoChip(title: "Owned Vehicles", value: "\(ownedVehicles.count)")
                InfoChip(title: "Mode", value: mode.title)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var modePicker: some View {
        Picker("Transfer Mode", selection: $mode) {
            ForEach(TransferMode.allCases) { item in
                Text(item.title).tag(item)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 2)
    }

    private var sellerPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Seller Transfer Generation", subtitle: "Select a vehicle you own, authenticate, and generate a 5-minute QR token.")

            panelCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Vehicle")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)

                    if ownedVehicles.isEmpty {
                        emptyState(text: "No vehicles found for your account")
                    } else {
                        Menu {
                            ForEach(ownedVehicles, id: \.id) { vehicle in
                                Button("\(vehicle.make) \(vehicle.model)") {
                                    selectedVehicleId = vehicle.id
                                    generatedTransfer = nil
                                    generatedQRCode = nil
                                }
                            }
                        } label: {
                            selectionRow(title: selectedVehicle.map { "\($0.make) \($0.model)" } ?? "Select a vehicle")
                        }
                    }

                    // Buyer phone input to bind the token to a specific buyer
                    TextField("Buyer phone (e.g. +94123456789)", text: $buyerPhoneInput)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)

                    Button(action: {
                        Task {
                            await initiateTransfer()
                        }
                    }) {
                        primaryButtonLabel(
                            title: isProcessing ? "Processing..." : "Initiate Transfer",
                            systemImage: "shield.lefthalf.filled"
                        )
                    }
                    .disabled(isProcessing || selectedVehicle == nil || ownedVehicles.isEmpty)
                    .opacity((selectedVehicle == nil || ownedVehicles.isEmpty) ? 0.55 : 1)

                    if let generatedTransfer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Generated QR")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)

                            if let generatedQRCode {
                                Image(uiImage: generatedQRCode)
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 220)
                                    .padding(16)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                // Fixed: Removed the backslashes from the fallback string
                                Text("Expiry: \(formattedDate(from: generatedTransfer.expiresAt) ?? "5 minutes from now")")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.85))
                                
                                Text(generatedTransfer.uri)
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.65))
                                    .lineLimit(3)
                            }

                            Button(action: {
                                UIPasteboard.general.string = generatedTransfer.token
                                alertTitle = "Token Copied"
                                alertMessage = "Transfer token copied to clipboard."
                                showAlert = true
                            }) {
                                primaryButtonLabel(title: "Copy Token", systemImage: "doc.on.doc.fill")
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
    }

    private var buyerPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Buyer Transfer Acceptance", subtitle: "Scan a transfer QR, upload QR image, confirm the vehicle, then finalize ownership transfer.")

            panelCard {
                VStack(alignment: .leading, spacing: 12) {
                    // Scan QR Button
                    Button(action: {
                        showScanner = true
                    }) {
                        primaryButtonLabel(title: "Scan QR", systemImage: "qrcode.viewfinder")
                    }
                    
                    Divider().overlay(Color.white.opacity(0.2))
                    
                    // Select QR image from app Assets (qr_image_1 ... qr_image_5)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("QR Assets")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 10)], spacing: 10) {
                            ForEach(1...5, id: \.self) { i in
                                let name = "qr_image_\(i)"
                                Button(action: {
                                    if let image = UIImage(named: name) {
                                        uploadedQRImage = image
                                        qrImageFilename = name
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Image(name)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 72, height: 72)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                        Text(name)
                                            .font(.system(size: 11, weight: .medium, design: .rounded))
                                            .foregroundStyle(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(8)
                                    .background(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Text("Use assets named qr_image_1 to qr_image_5 in Assets.xcassets.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.68))
                    }

                    Divider().overlay(Color.white.opacity(0.2))

                    // Buyer can also transfer from token directly
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Transfer From Token")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        TextField("Enter transfer token", text: $buyerTokenInput)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Button(action: {
                            Task {
                                await confirmTransferFromToken()
                            }
                        }) {
                            primaryButtonLabel(title: isProcessing ? "Confirming..." : "Confirm Using Token", systemImage: "key.fill")
                        }
                        .disabled(isProcessing || buyerTokenInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(buyerTokenInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
                    }

                    Divider().overlay(Color.white.opacity(0.2))

                    if let scannedTransfer {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Scanned Transfer")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)

                            detailRow(title: "Vehicle ID", value: scannedTransfer.vehicleId)
                            detailRow(title: "Token", value: scannedTransfer.token)

                            if let scannedVehicle {
                                Divider().overlay(Color.white.opacity(0.15))
                                detailRow(title: "Make", value: scannedVehicle.make)
                                detailRow(title: "Model", value: scannedVehicle.model)
                            }

                            Button(action: {
                                Task {
                                    await confirmTransfer()
                                }
                            }) {
                                primaryButtonLabel(title: isProcessing ? "Confirming..." : "Confirm Transfer", systemImage: "checkmark.seal.fill")
                            }
                            .disabled(isProcessing || scannedVehicle == nil)
                            .opacity(scannedVehicle == nil ? 0.55 : 1)
                        }
                        .padding(.top, 6)
                    } else if let uploadedImage = uploadedQRImage, let filename = qrImageFilename {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Uploaded QR Image")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)

                            Image(uiImage: uploadedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 6) {
                                Text("File: \(filename)")
                                    .font(.system(size: 12, weight: .regular, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.7))

                                HStack(spacing: 10) {
                                    Button(action: {
                                        uploadedQRImage = nil
                                        qrImageFilename = nil
                                    }) {
                                        Label("Clear", systemImage: "xmark.circle.fill")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        .padding(.top, 6)
                    } else {
                        emptyState(text: "No QR scanned or uploaded yet")
                    }
                }
            }
        }
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func panelCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.28))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func selectionRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
            Spacer()
        }
    }

    private func primaryButtonLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(.black)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func emptyState(text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.75))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
    }

    private var transferBackground: some View {
        LinearGradient(
            colors: [Color(red: 0.08, green: 0.10, blue: 0.14), Color(red: 0.14, green: 0.18, blue: 0.26), Color(red: 0.21, green: 0.26, blue: 0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func loadOwnedVehicles() async {
        guard let userId = SessionManager.shared.getUserId() else {
            await MainActor.run {
                isLoading = false
                alertTitle = "Session Missing"
                alertMessage = "Please log in again to access Transfer Center."
                showAlert = true
            }
            return
        }

        do {
            let fetched = try await fetchVehiclesForUser(userId: userId)
            await MainActor.run {
                ownedVehicles = fetched.map { $0.vehicle }
                if selectedVehicleId.isEmpty {
                    selectedVehicleId = ownedVehicles.first?.id ?? ""
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                alertTitle = "Unable to Load Vehicles"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    private func initiateTransfer() async {
        guard let userId = SessionManager.shared.getUserId(), let vehicle = selectedVehicle else {
            alertTitle = "Select a Vehicle"
            alertMessage = "Choose one of your owned vehicles first."
            showAlert = true
            return
        }

        isProcessing = true

        do {
            try await BiometricAuthentication.shared.authenticate(reason: "Authenticate to generate a secure transfer QR for \(vehicle.make) \(vehicle.model)")

            let buyerPhone = buyerPhoneInput.trimmingCharacters(in: .whitespacesAndNewlines)
            let response = try await TransferBackendService.shared.generateTransferToken(sellerId: userId, vehicleId: vehicle.id, buyerPhone: buyerPhone.isEmpty ? nil : buyerPhone)
            let token = response.token
            let transferURI = "autolegal://transfer?token=\(token.urlEncoded)&vid=\(vehicle.id.urlEncoded)"
            let qr = TransferQRCodeRenderer.shared.makeQRCode(from: transferURI)

            await MainActor.run {
                // Changed response.expiresAtDate to response.expiresAt
                generatedTransfer = TransferSession(token: token, vehicleId: vehicle.id, uri: transferURI, expiresAt: response.expiresAt)
                generatedQRCode = qr
                alertTitle = "Transfer Ready"
                alertMessage = "Share the QR code within 5 minutes."
                showAlert = true
                isProcessing = false
            }        } catch BiometricAuthentication.AuthenticationError.cancelledByUser {
            await MainActor.run {
                isProcessing = false
            }
        } catch {
            await MainActor.run {
                isProcessing = false
                alertTitle = "Transfer Failed"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    private func handleScannedValue(_ value: String) {
        guard let payload = TransferScanPayload(uriString: value) else {
            alertTitle = "Invalid QR"
            alertMessage = "The scanned code is not a valid AutoLegacy transfer link."
            showAlert = true
            return
        }

        scannedTransfer = payload
        scannedVehicle = nil

        Task {
            await fetchVehicleForScan(vehicleId: payload.vehicleId)
        }
    }

    private func fetchVehicleForScan(vehicleId: String) async {
        do {
            let vehicle: VehicleData = try await supabase
                .from("vehicle")
                .select("*")
                .eq("id", value: vehicleId)
                .single()
                .execute()
                .value

            await MainActor.run {
                scannedVehicle = vehicle
            }
        } catch {
            await MainActor.run {
                alertTitle = "Vehicle Lookup Failed"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    private func confirmTransfer() async {
        guard let userId = SessionManager.shared.getUserId(), let payload = scannedTransfer else {
            alertTitle = "Transfer Missing"
            alertMessage = "Scan a valid transfer QR first."
            showAlert = true
            return
        }

        isProcessing = true

        do {
            let buyerPhone = SessionManager.shared.getUserMobile()
            let response = try await TransferBackendService.shared.confirmTransfer(token: payload.token, vehicleId: payload.vehicleId, buyerId: userId, buyerPhone: buyerPhone)

            await MainActor.run {
                alertTitle = "Transfer Complete"
                alertMessage = response.message ?? "Ownership updated successfully."
                showAlert = true
                scannedTransfer = nil
                scannedVehicle = nil
                generatedTransfer = nil
                generatedQRCode = nil
                isProcessing = false
            }

            await loadOwnedVehicles()
        } catch {
            await MainActor.run {
                isProcessing = false
                alertTitle = "Transfer Failed"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    private func confirmTransferFromToken() async {
        let token = buyerTokenInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty, let userId = SessionManager.shared.getUserId() else {
            alertTitle = "Token Missing"
            alertMessage = "Enter a transfer token and make sure you're logged in."
            showAlert = true
            return
        }

        isProcessing = true

        do {
            let buyerPhone = SessionManager.shared.getUserMobile()
            let response = try await TransferBackendService.shared.confirmTransfer(token: token, buyerId: userId, buyerPhone: buyerPhone)

            await MainActor.run {
                alertTitle = "Transfer Complete"
                alertMessage = response.message ?? "Ownership transferred successfully."
                showAlert = true
                buyerTokenInput = ""
                uploadedQRImage = nil
                qrImageFilename = nil
                isProcessing = false
            }

            await loadOwnedVehicles()
        } catch {
            await MainActor.run {
                isProcessing = false
                alertTitle = "Transfer Failed"
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
    }

    private func formattedDate(from date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    
}

private enum TransferMode: String, CaseIterable, Identifiable {
    case seller
    case buyer

    var id: String { rawValue }

    var title: String {
        switch self {
        case .seller:
            return "Seller"
        case .buyer:
            return "Buyer"
        }
    }
}

private struct TransferSession {
    let token: String
    let vehicleId: String
    let uri: String
    let expiresAt: Date?
}

private struct TransferScanPayload {
    let token: String
    let vehicleId: String

    init?(uriString: String) {
        guard let url = URL(string: uriString),
              url.scheme?.lowercased() == "autolegal",
              url.host?.lowercased() == "transfer",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        let items = components.queryItems ?? []
        guard let token = items.first(where: { $0.name == "token" })?.value,
              let vehicleId = items.first(where: { $0.name == "vid" })?.value,
              !token.isEmpty,
              !vehicleId.isEmpty else {
            return nil
        }

        self.token = token
        self.vehicleId = vehicleId
    }
}

private struct TransferTokenRequest: Encodable {
    let sellerId: Int
    let vehicleId: String
    let buyerPhone: String?

    enum CodingKeys: String, CodingKey {
        case sellerId = "seller_id"
        case vehicleId = "vehicle_id"
        case buyerPhone = "buyer_phone"
    }
}

private struct ConfirmTransferRequest: Encodable {
    let token: String
    let vehicleId: String
    let buyerId: Int
    let buyerPhone: String?

    enum CodingKeys: String, CodingKey {
        case token
        case vehicleId = "vehicle_id"
        case buyerId = "buyer_id"
        case buyerPhone = "buyer_phone"
    }
}

private struct ConfirmTransferByTokenRequest: Encodable {
    let token: String
    let buyerId: Int
    let buyerPhone: String?

    enum CodingKeys: String, CodingKey {
        case token
        case buyerId = "buyer_id"
        case buyerPhone = "buyer_phone"
    }
}

private struct TransferTokenResponse: Decodable {
    let token: String
    let expiresAt: Date?

    enum CodingKeys: String, CodingKey {
        case token
        case expiresAt = "expires_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)

        if let rawExpiry = try? container.decode(String.self, forKey: .expiresAt) {
            expiresAt = TransferDateParser.shared.parse(rawExpiry)
        } else {
            expiresAt = nil
        }
    }
}

private struct TransferConfirmationResponse: Decodable {
    let message: String?
}

private final class TransferBackendService {
    static let shared = TransferBackendService()

    private let baseURL = URL(string: "https://ilzdfeewtdehthtpowng.supabase.co/functions/v1")!
    private let apiKey = "sb_publishable_kRtXgeYk13wdFQYqZX84-w_nekOxehA"

    private init() {}

    func generateTransferToken(sellerId: Int, vehicleId: String, buyerPhone: String?) async throws -> TransferTokenResponse {
        let defaultCandidates = ["transfer-generate", "transfer_generate", "generate-transfer", "transfer-generate-v1", "transfer"]
        let custom = (UserDefaults.standard.string(forKey: "transfer_generate_functions") ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { String($0) }
        let candidates = custom + defaultCandidates
        do {
            return try await invokeWithCandidates(functionCandidates: candidates, body: TransferTokenRequest(sellerId: sellerId, vehicleId: vehicleId, buyerPhone: buyerPhone))
        } catch {
            print("Falling back to DirectDBTransferService")
            return try await DirectDBTransferService.shared.generateTransferToken(sellerId: sellerId, vehicleId: vehicleId, buyerPhone: buyerPhone)
        }
    }

    func confirmTransfer(token: String, vehicleId: String, buyerId: Int, buyerPhone: String? = nil) async throws -> TransferConfirmationResponse {
        let defaultCandidates = ["transfer-confirm", "transfer_confirm", "confirm-transfer", "transfer-confirm-v1", "transfer"]
        let custom = (UserDefaults.standard.string(forKey: "transfer_confirm_functions") ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { String($0) }
        let candidates = custom + defaultCandidates
        do {
            return try await invokeWithCandidates(functionCandidates: candidates, body: ConfirmTransferRequest(token: token, vehicleId: vehicleId, buyerId: buyerId, buyerPhone: buyerPhone))
        } catch {
            print("Falling back to DirectDBTransferService")
            return try await DirectDBTransferService.shared.confirmTransfer(token: token, vehicleId: vehicleId, buyerId: buyerId)
        }
    }

    func confirmTransfer(token: String, buyerId: Int, buyerPhone: String? = nil) async throws -> TransferConfirmationResponse {
        let defaultCandidates = ["transfer-confirm", "transfer_confirm", "confirm-transfer", "transfer-confirm-v1", "transfer"]
        let custom = (UserDefaults.standard.string(forKey: "transfer_confirm_functions") ?? "")
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { String($0) }
        let candidates = custom + defaultCandidates
        do {
            return try await invokeWithCandidates(functionCandidates: candidates, body: ConfirmTransferByTokenRequest(token: token, buyerId: buyerId, buyerPhone: buyerPhone))
        } catch {
            print("Falling back to DirectDBTransferService")
            return try await DirectDBTransferService.shared.confirmTransfer(token: token, buyerId: buyerId, buyerPhone: buyerPhone)
        }
    }

    private func invokeWithCandidates<Response: Decodable, Body: Encodable>(functionCandidates: [String], body: Body) async throws -> Response {
        var lastError: Error? = nil
        for fname in functionCandidates {
            do {
                return try await invoke(function: fname, body: body)
            } catch {
                // Keep trying other candidate names but remember the last error for reporting
                lastError = error
                print("⚠️ Edge function '\(fname)' failed: \(error)")
            }
        }

        if let last = lastError {
            throw last
        }
        throw TransferError.edgeFunctionFailed("No function candidates provided")
    }

    private func invoke<Response: Decodable, Body: Encodable>(function: String, body: Body) async throws -> Response {
        var request = URLRequest(url: baseURL.appendingPathComponent(function))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TransferError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unexpected function failure"
            // If Supabase returns a JSON body explaining not_found, surface that clearly
            throw TransferError.edgeFunctionFailed("HTTP \(httpResponse.statusCode): \(message)")
        }

        return try JSONDecoder().decode(Response.self, from: data)
    }
}

private final class TransferDateParser {
    static let shared = TransferDateParser()
    private let isoFormatter = ISO8601DateFormatter()

    func parse(_ raw: String) -> Date? {
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: raw) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        return isoFormatter.date(from: raw)
    }
}

private enum TransferError: LocalizedError {
    case invalidResponse
    case edgeFunctionFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from transfer service."
        case .edgeFunctionFailed(let message):
            return message
        }
    }
}

private final class TransferQRCodeRenderer {
    static let shared = TransferQRCodeRenderer()
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    func makeQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }
        let scaleX = 10.0
        let scaleY = 10.0
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

private struct QRScannerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onScan: (String) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            ScannerRepresentable { value in
                onScan(value)
                dismiss()
            }
            .ignoresSafeArea()

            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)

                VStack(spacing: 6) {
                    Text("Scan Transfer QR")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Point the camera at the AutoLegacy transfer code.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.top, 12)

                Spacer()

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 250, height: 250)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("Keep the QR inside the frame")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.45))
                                .clipShape(Capsule())
                            Spacer()
                        }
                    )

                Spacer()
            }
        }
    }
}

private struct ScannerRepresentable: UIViewControllerRepresentable {
    let onScan: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        ScannerViewController(onScan: onScan)
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) { }
}

private final class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private let session = AVCaptureSession()
    private let onScan: (String) -> Void
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var didCapture = false

    init(onScan: @escaping (String) -> Void) {
        self.onScan = onScan
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSession()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !session.isRunning {
            session.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning {
            session.stopRunning()
        }
    }

    private func configureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(input) else {
            return
        }

        session.addInput(input)

        let metadataOutput = AVCaptureMetadataOutput()
        guard session.canAddOutput(metadataOutput) else { return }
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !didCapture,
              let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let value = metadataObject.stringValue else {
            return
        }

        didCapture = true
        session.stopRunning()
        onScan(value)
    }
}

private struct InfoChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.65))
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct TransferTokenRow: Codable {
    let id: String
    let vehicle_id: String
    let seller_id: Int
    let token_hash: String
    let expires_at: String
    let is_used: Bool
    let buyer_phone: String?
}

private final class DirectDBTransferService {
    static let shared = DirectDBTransferService()
    private init() {}

    private func sha256Hex(_ s: String) -> String {
        let data = Data(s.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func normalizedTokenCandidates(from raw: String) -> [String] {
        var token = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))

        if let components = URLComponents(string: token),
           components.scheme != nil,
           let queryToken = components.queryItems?.first(where: { $0.name.lowercased() == "token" })?.value,
           !queryToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            token = queryToken.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let decoded = token.removingPercentEncoding?.trimmingCharacters(in: .whitespacesAndNewlines)
        var values: [String] = [token]
        if let decoded, !decoded.isEmpty, decoded != token {
            values.append(decoded)
        }

        var unique: [String] = []
        for item in values where !item.isEmpty {
            if !unique.contains(item) {
                unique.append(item)
            }
        }
        return unique
    }

    private func resolveTokenRow(token rawToken: String, vehicleId: String?) async throws -> TransferTokenRow? {
        let candidates = normalizedTokenCandidates(from: rawToken)

        for candidate in candidates {
            let hash = sha256Hex(candidate)
            var query = supabase
                .from("transfer_tokens")
                .select("*")
                .eq("token_hash", value: hash)
                .eq("is_used", value: false)

            if let vehicleId {
                query = query.eq("vehicle_id", value: vehicleId)
            }

            let rows: [TransferTokenRow] = try await query.execute().value
            if let row = rows.first {
                return row
            }

            if candidate.count == 64,
               candidate.range(of: "^[A-Fa-f0-9]{64}$", options: .regularExpression) != nil {
                var hashQuery = supabase
                    .from("transfer_tokens")
                    .select("*")
                    .eq("token_hash", value: candidate.lowercased())
                    .eq("is_used", value: false)

                if let vehicleId {
                    hashQuery = hashQuery.eq("vehicle_id", value: vehicleId)
                }

                let hashRows: [TransferTokenRow] = try await hashQuery.execute().value
                if let row = hashRows.first {
                    return row
                }
            }
        }

        return nil
    }

    func generateTransferToken(sellerId: Int, vehicleId: String, buyerPhone: String?) async throws -> TransferTokenResponse {
        let token = UUID().uuidString
        let hash = sha256Hex(token)
        let expires = Date().addingTimeInterval(5 * 60)
        let iso = ISO8601DateFormatter().string(from: expires)

        let payload = TransferTokenRow(
            id: UUID().uuidString,
            vehicle_id: vehicleId,
            seller_id: sellerId,
            token_hash: hash,
            expires_at: iso,
            is_used: false,
            buyer_phone: buyerPhone
        )

        _ = try await supabase
            .from("transfer_tokens")
            .insert([payload])
            .execute()

        let responseJSON = """
        {"token":"\(token)","expires_at":"\(iso)"}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let resp = try decoder.decode(TransferTokenResponse.self, from: responseJSON)
        return resp
    }

    func confirmTransfer(token: String, vehicleId: String, buyerId: Int, buyerPhone: String? = nil) async throws -> TransferConfirmationResponse {
        guard let row = try await resolveTokenRow(token: token, vehicleId: vehicleId) else {
            throw TransferError.edgeFunctionFailed("Token not found or already used")
        }

        let iso = ISO8601DateFormatter()
        if let exp = iso.date(from: row.expires_at), exp < Date() {
            throw TransferError.edgeFunctionFailed("Token expired")
        }

        // Verify buyer phone if the token was bound to a phone number
        if let boundPhone = row.buyer_phone, !boundPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let buyerMobile = buyerPhone ?? SessionManager.shared.getUserMobile()
            if buyerMobile == nil || buyerMobile != boundPhone {
                throw TransferError.edgeFunctionFailed("Buyer phone does not match token recipient")
            }
        }

        _ = try await supabase
            .from("vehicle")
            .update(["owner_id": buyerId])
            .eq("id", value: vehicleId)
            .execute()

        _ = try await supabase
            .from("transfer_tokens")
            .update(["is_used": true])
            .eq("id", value: row.id)
            .execute()

        let responseJSON = """
        {"message":"Ownership transferred successfully"}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let resp = try decoder.decode(TransferConfirmationResponse.self, from: responseJSON)
        return resp
    }

    func confirmTransfer(token: String, buyerId: Int, buyerPhone: String? = nil) async throws -> TransferConfirmationResponse {
        guard let row = try await resolveTokenRow(token: token, vehicleId: nil) else {
            throw TransferError.edgeFunctionFailed("Token not found or already used")
        }

        let iso = ISO8601DateFormatter()
        if let exp = iso.date(from: row.expires_at), exp < Date() {
            throw TransferError.edgeFunctionFailed("Token expired")
        }

        if let boundPhone = row.buyer_phone, !boundPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let buyerMobile = buyerPhone ?? SessionManager.shared.getUserMobile()
            if buyerMobile == nil || buyerMobile != boundPhone {
                throw TransferError.edgeFunctionFailed("Buyer phone does not match token recipient")
            }
        }

        _ = try await supabase
            .from("vehicle")
            .update(["owner_id": buyerId])
            .eq("id", value: row.vehicle_id)
            .execute()

        _ = try await supabase
            .from("transfer_tokens")
            .update(["is_used": true])
            .eq("id", value: row.id)
            .execute()

        let responseJSON = """
        {"message":"Ownership transferred successfully"}
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let resp = try decoder.decode(TransferConfirmationResponse.self, from: responseJSON)
        return resp
    }
}

private extension String {
    var urlEncoded: String {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}

#Preview {
    NavigationStack {
        TransferCenterView()
    }
}
