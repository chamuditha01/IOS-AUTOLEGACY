import SwiftUI
import Supabase
import Vision

struct DocumentSubmissionView: View {
    @State private var expiryDate = Date()
    @State private var isLoading = false
    @State private var isRecognizingText = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showSuccess = false
    @State private var successMessage = ""
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    @State private var showDocumentSamples = false
    @State private var extractedOCRText = ""
    @State private var selectedDocumentImage: UIImage?
    @State private var selectedDocumentImageName: String?
    @State private var selectedVehicle: VehicleData?
    @State private var vehicles: [VehicleData] = []
    
    let documentType: String
    let documentImage: String
    let documentId: String?
    let existingVehicleId: String?
    let existingExpiryDate: String?
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
                    
                    Text("\(documentId != nil ? "Edit" : "Add") \(documentType.capitalized)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if documentId != nil {
                        Button(action: { showDeleteConfirm = true }) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(width: 40, height: 40)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
                        }
                    } else {
                        Spacer()
                            .frame(width: 40)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Document Upload + Preview
                        VStack(spacing: 16) {
                            Text("DOCUMENT IMAGE")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                                .tracking(1.2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Button(action: { showDocumentSamples = true }) {
                                HStack {
                                    Image(systemName: selectedDocumentImage == nil ? "doc.badge.plus" : "doc.text.image")
                                    Text(selectedDocumentImage == nil ? "Choose Document Image" : "Change Document Image")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white.opacity(0.75))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.14, green: 0.15, blue: 0.16))
                                    .frame(height: 220)
                                
                                if let image = selectedDocumentImage ?? DocumentImageManager.shared.loadDocumentImage(named: documentImage) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 220)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    AsyncImage(url: URL(string: documentImage)) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 220)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                    } placeholder: {
                                        VStack(spacing: 8) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            Text("Loading preview")
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                }
                            }
                            
                            if isRecognizingText {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    Text("Extracting expiry date from document...")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.75))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if !extractedOCRText.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("OCR TEXT")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text(extractedOCRText)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.75))
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .topLeading)
                                        .background(Color.white.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .lineLimit(5)
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
                                    Image(systemName: documentId != nil ? "pencil.circle.fill" : "checkmark.circle.fill")
                                }
                                
                                Text(isLoading ? "\(documentId != nil ? "Updating" : "Saving")..." : "\(documentId != nil ? "Update" : "Save") Document")
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
            Text(successMessage)
        }
        .alert("Delete Document", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                handleDelete()
            }
        } message: {
            Text("Are you sure you want to delete this document? This action cannot be undone.")
        }
        .sheet(isPresented: $showDocumentSamples) {
            DocumentAssetPicker { image, imageName in
                handleDocumentImageSelection(image: image, imageName: imageName)
            }
        }
        .task {
            await loadVehicles()
            if let vehicleId = existingVehicleId, let expiryStr = existingExpiryDate {
                // Load existing data for edit mode
                if let vehicle = vehicles.first(where: { $0.id == vehicleId }) {
                    selectedVehicle = vehicle
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                if let date = formatter.date(from: expiryStr) {
                    expiryDate = date
                }
            }
            if selectedDocumentImage == nil {
                loadInitialDocumentImage()
            }
        }
    }
    
    private func loadVehicles() async {
        do {
            guard let userId = SessionManager.shared.getUserId() else {
                await MainActor.run {
                    errorMessage = "User not found"
                    showError = true
                }
                return
            }
            
            let result = try await fetchVehiclesForUser(userId: userId)
            await MainActor.run {
                self.vehicles = result.map { $0.0 }
                if let existingVehicleId,
                   let matchedVehicle = self.vehicles.first(where: { $0.id == existingVehicleId }) {
                    self.selectedVehicle = matchedVehicle
                } else if !self.vehicles.isEmpty {
                    self.selectedVehicle = self.vehicles.first
                }
            }
        } catch {
            if error is CancellationError {
                print("ℹ️ Vehicle fetch cancelled (view was dismissed)")
            } else {
                print("❌ Failed to load vehicles: \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = "Failed to load vehicles"
                    showError = true
                }
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
                if let docId = documentId {
                    // Update mode
                    try await updateDocument(
                        id: docId,
                        vehicleId: vehicle.id,
                        doctype: documentType,
                        expirydate: expiryDateString,
                        filepath: resolveDocumentFilePath()
                    )
                } else {
                    // Create mode
                    try await saveDocument(
                        vehicleId: vehicle.id,
                        doctype: documentType,
                        expirydate: expiryDateString,
                        filepath: resolveDocumentFilePath()
                    )
                }

                let vehicleName = "\(vehicle.make ?? "Unknown") \(vehicle.model ?? "Vehicle")"
                let notificationTitle = documentId != nil ? "Document Updated" : "Document Added"
                let notificationBody = "Type: \(documentType.capitalized) | Vehicle: \(vehicleName) | Expiry: \(expiryDateString)"
                await NotificationManager.shared.scheduleDocumentNotification(
                    title: notificationTitle,
                    details: notificationBody
                )
                
                DispatchQueue.main.async {
                    isLoading = false
                    successMessage = documentId != nil ? "Document updated successfully!" : "Document saved successfully!"
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
    
    private func handleDelete() {
        guard let docId = documentId else { return }
        
        isDeleting = true
        
        Task {
            do {
                try await deleteDocument(id: docId)
                
                DispatchQueue.main.async {
                    isDeleting = false
                    successMessage = "Document deleted successfully!"
                    showSuccess = true
                }
            } catch {
                DispatchQueue.main.async {
                    isDeleting = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func loadInitialDocumentImage() {
        if let image = DocumentImageManager.shared.loadDocumentImage(named: documentImage) {
            selectedDocumentImage = image
            selectedDocumentImageName = documentImage
            recognizeExpiryFromImage(image)
        }
    }

    private func handleDocumentImageSelection(image: UIImage, imageName: String) {
        selectedDocumentImage = image
        selectedDocumentImageName = imageName
        recognizeExpiryFromImage(image)
    }

    private func resolveDocumentFilePath() -> String {
        selectedDocumentImageName ?? documentImage
    }

    private func recognizeExpiryFromImage(_ image: UIImage) {
        isRecognizingText = true
        extractedOCRText = ""

        Task {
            do {
                guard let cgImage = image.cgImage else {
                    throw NSError(domain: "DocumentOCR", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to read document image"])
                }

                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                let request = VNRecognizeTextRequest { request, error in
                    guard error == nil,
                          let observations = request.results as? [VNRecognizedTextObservation] else {
                        DispatchQueue.main.async {
                            isRecognizingText = false
                        }
                        return
                    }

                    let recognizedText = observations
                        .compactMap { $0.topCandidates(1).first?.string }
                        .joined(separator: " ")

                    DispatchQueue.main.async {
                        extractedOCRText = recognizedText

                        if let parsedExpiryDate = extractExpiryDate(from: recognizedText) {
                            expiryDate = parsedExpiryDate
                        }

                        isRecognizingText = false
                    }
                }

                request.recognitionLanguages = ["en-US"]
                request.usesLanguageCorrection = true

                try requestHandler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    isRecognizingText = false
                    errorMessage = "Failed to recognize document text: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }

    private func extractExpiryDate(from text: String) -> Date? {
        let normalizedText = normalizeOCRText(text)

        let labeledPatterns: [String] = [
            #"(?:expiry|exp(?:iry)?|expires?|valid(?:ity)?(?:\s+till|\s+until|\s+through|\s+up\s+to)?)\s*[:\-]?\s*([0-9]{1,2}[\/\-.][0-9]{1,2}[\/\-.][0-9]{2,4}|[0-9]{4}[\/\-.][0-9]{1,2}[\/\-.][0-9]{1,2}|[0-9]{1,2}\s+[A-Za-z]{3,9}\s+[0-9]{2,4}|[A-Za-z]{3,9}\s+[0-9]{1,2},?\s+[0-9]{2,4})"#
        ]

        for pattern in labeledPatterns {
            if let candidate = matchFirstCapture(in: normalizedText, pattern: pattern), let date = parseDocumentDate(candidate) {
                return date
            }
        }

        let genericPatterns: [String] = [
            #"([0-9]{1,2}[\/\-.][0-9]{1,2}[\/\-.][0-9]{2,4})"#,
            #"([0-9]{4}[\/\-.][0-9]{1,2}[\/\-.][0-9]{1,2})"#,
            #"([0-9]{1,2}\s+[A-Za-z]{3,9}\s+[0-9]{2,4})"#,
            #"([A-Za-z]{3,9}\s+[0-9]{1,2},?\s+[0-9]{2,4})"#
        ]

        for pattern in genericPatterns {
            if let candidate = matchFirstCapture(in: normalizedText, pattern: pattern), let date = parseDocumentDate(candidate) {
                return date
            }
        }

        return nil
    }

    private func parseDocumentDate(_ text: String) -> Date? {
        let cleaned = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "  ", with: " ")

        let formats = [
            "dd/MM/yyyy", "d/M/yyyy", "dd-MM-yyyy", "d-M-yyyy", "dd.MM.yyyy",
            "yyyy-MM-dd", "yyyy/MM/dd", "yyyy.MM.dd",
            "dd MMM yyyy", "d MMM yyyy", "dd MMMM yyyy", "d MMMM yyyy",
            "MMM dd yyyy", "MMMM dd yyyy"
        ]

        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            if let date = formatter.date(from: cleaned) {
                return date
            }
        }

        return nil
    }

    private func normalizeOCRText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
    }

    private func matchFirstCapture(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range),
              let captureRange = Range(match.range(at: 1), in: text) else {
            return nil
        }

        return String(text[captureRange])
    }
}

struct DocumentAssetPicker: View {
    @Environment(\.dismiss) var dismiss
    @State private var documentImages: [(name: String, image: UIImage)] = []
    let onImageSelected: (UIImage, String) -> Void

    var body: some View {
        ZStack {
            AppTheme.Gradients.auth.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("Select Document Image")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tap an image to OCR the expiry date automatically")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))

                        VStack(spacing: 12) {
                            ForEach(documentImages, id: \.name) { item in
                                Button(action: {
                                    onImageSelected(item.image, item.name)
                                    dismiss()
                                }) {
                                    HStack(spacing: 12) {
                                        Image(uiImage: item.image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 64, height: 64)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name.replacingOccurrences(of: "_", with: " ").capitalized)
                                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)

                                            Text("Tap to use this document image")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.6))
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.05))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            documentImages = DocumentImageManager.shared.getAvailableDocumentImages()
        }
    }
}

struct DocumentSubmissionView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentSubmissionView(
            documentType: "insurance",
            documentImage: "https://i.ibb.co/yjryBHR/Gemini-Generated-Image-b5g2ynb5g2ynb5g2.png",
            documentId: nil,
            existingVehicleId: nil,
            existingExpiryDate: nil,
            onSuccess: {}
        )
    }
}
