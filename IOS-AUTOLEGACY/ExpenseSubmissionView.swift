import SwiftUI
import PhotosUI
import Vision
import VisionKit

struct ExpenseSubmissionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""
    @State private var reason = ""
    @State private var extractedText = ""
    @State private var selectedVehicleId: String = ""
    @State private var vehicles: [VehicleData] = []
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccess = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isRecognizingText = false
    @State private var showPhotoOptions = false
    @State private var showSampleImages = false
    @State private var cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    
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

                    Text("Expense Track")
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
                            // Bill Image Upload Section
                            VStack(alignment: .center, spacing: 16) {
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 180)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                    
                                    Button(action: { selectedImage = nil }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "xmark.circle.fill")
                                            Text("Change Image")
                                        }
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Color.red.opacity(0.6))
                                        .cornerRadius(8)
                                    }
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.white.opacity(0.7))
                                        
                                        Text("Upload Bill Image")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text("Take a photo or upload from gallery")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 160)
                                    .background(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color.white.opacity(0.2),
                                                style: StrokeStyle(lineWidth: 1.5, dash: [5])
                                            )
                                    )                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .onTapGesture {
                                        showPhotoOptions = true
                                    }
                                }
                            }
                            .padding(.horizontal, 20)

                            // Extracted Text Display
                            if !extractedText.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Extracted Text")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Spacer()
                                        
                                        if isRecognizingText {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    
                                    Text(extractedText)
                                        .font(.system(size: 13, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .topLeading)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(8)
                                        .lineLimit(6)
                                }
                                .padding(.horizontal, 20)
                            }

                            // Amount Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Amount (₹)")
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
                            .padding(.horizontal, 20)

                            // Reason/Category Input
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Reason/Category")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.8))

                                VStack(alignment: .leading, spacing: 0) {
                                    TextField("Enter reason", text: $reason)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                        .padding(16)
                                        .background(Color.white)
                                }
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)

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
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)

                            // Save Button
                            Button(action: submitExpense) {
                                if isSaving {
                                    HStack(spacing: 12) {
                                        ProgressView()
                                            .tint(.white)
                                        Text("Saving...")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color(red: 0.62, green: 0.73, blue: 0.96))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                } else {
                                    Text("Save Expense")
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(Color(red: 0.62, green: 0.73, blue: 0.96))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                            .disabled(isSaving || amount.isEmpty || selectedVehicleId.isEmpty)
                            .opacity((isSaving || amount.isEmpty || selectedVehicleId.isEmpty) ? 0.6 : 1.0)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }

            // Error Alert
            if showError {
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Error")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                        }
                        
                        Text(errorMessage ?? "An error occurred")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button(action: { showError = false }) {
                            Text("Dismiss")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding(16)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(12)
                    .padding(20)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, onImageSelected: recognizeTextFromImage)
        }
        .sheet(isPresented: $showSampleImages) {
            BundleBillImagePicker(selectedImage: $selectedImage, onImageSelected: recognizeTextFromImage)
        }
        .actionSheet(isPresented: $showPhotoOptions) {
            ActionSheet(
                title: Text("Select Photo Source"),
                buttons: [
                    .default(Text("Camera")) {
                        if cameraAvailable {
                            showImagePicker = true
                        }
                    },
                    .default(Text("Photo Library")) {
                        showImagePicker = true
                    },
                    .default(Text("Project Images")) {
                        showSampleImages = true
                    },
                    .cancel()
                ]
            )
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
                    vehicles = vehiclesWithStats.map { vehicleData, _ in vehicleData }
                    if !vehicles.isEmpty {
                        selectedVehicleId = vehicles.first?.id ?? ""
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

    private func recognizeTextFromImage(image: UIImage) {
        isRecognizingText = true
        extractedText = ""
        
        Task {
            do {
                guard let cgImage = image.cgImage else {
                    throw NSError(domain: "ImageError", code: -1, userInfo: nil)
                }
                
                let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                let request = VNRecognizeTextRequest { request, error in
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        DispatchQueue.main.async {
                            isRecognizingText = false
                        }
                        return
                    }
                    
                    let recognizedText = observations
                        .compactMap { $0.topCandidates(1).first?.string }
                        .joined(separator: " ")
                    
                    DispatchQueue.main.async {
                        extractedText = recognizedText

                        if let parsedAmount = extractAmount(from: recognizedText), amount.isEmpty {
                            amount = parsedAmount
                        }

                        if let parsedReason = extractReason(from: recognizedText), reason.isEmpty {
                            reason = parsedReason
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
                    errorMessage = "Failed to recognize text: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }

    private func extractAmount(from text: String) -> String? {
        let normalizedText = normalizeOCRText(text)

        let labeledPatterns: [String] = [
            #"final\s+bill\s+amount(?:\s*[:\-]?)\s*(?:rs\.?|₹|inr)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)"#,
            #"grand\s+total(?:\s*[:\-]?)\s*(?:rs\.?|₹|inr)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)"#,
            #"total(?:\s*[:\-]?)\s*(?:rs\.?|₹|inr)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)"#,
            #"amount\s+due(?:\s*[:\-]?)\s*(?:rs\.?|₹|inr)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)"#
        ]

        for pattern in labeledPatterns {
            if let amount = matchFirstCapture(in: normalizedText, pattern: pattern) {
                return amount
            }
        }

        let allAmounts = extractAllAmounts(from: normalizedText)
        if let highestAmount = allAmounts.max(by: { $0.numericValue < $1.numericValue }) {
            return highestAmount.raw
        }

        return nil
    }

    private func extractReason(from text: String) -> String? {
        let normalizedText = normalizeOCRText(text)
        let lowerText = normalizedText.lowercased()

        if lowerText.contains("accident") && lowerText.contains("repair") {
            return "Accident Repair"
        }

        if lowerText.contains("repair") {
            if lowerText.contains("painting") {
                return "Repair & Painting"
            }
            return "Repair"
        }

        if lowerText.contains("service") {
            return "Service"
        }

        if lowerText.contains("maintenance") {
            return "Maintenance"
        }

        if lowerText.contains("fuel") || lowerText.contains("petrol") || lowerText.contains("diesel") {
            return "Fuel"
        }

        if lowerText.contains("painting") {
            return "Painting"
        }

        let lines = normalizedText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let ignoredKeywords = ["invoice", "bill", "receipt", "date", "total", "subtotal", "amount", "tax", "balance", "final"]

        if let line = lines.first(where: { line in
            let lower = line.lowercased()
            return lower.count > 3 && !ignoredKeywords.contains(where: { lower.contains($0) })
        }) {
            return cleanReasonText(line)
        }

        return nil
    }

    private func normalizeOCRText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "*=", with: " ")
            .replacingOccurrences(of: "/=", with: "")
            .replacingOccurrences(of: "Rs.", with: "Rs ", options: .caseInsensitive)
            .replacingOccurrences(of: "RS.", with: "Rs ", options: .caseInsensitive)
            .replacingOccurrences(of: "Rs:", with: "Rs ", options: .caseInsensitive)
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
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractAllAmounts(from text: String) -> [ParsedAmount] {
        let pattern = #"(?:rs\.?|₹|inr)?\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }

        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, options: [], range: range).compactMap { match in
            guard let captureRange = Range(match.range(at: 1), in: text) else { return nil }
            let raw = String(text[captureRange])
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let numericValue = Double(raw) else { return nil }
            return ParsedAmount(raw: raw, numericValue: numericValue)
        }
    }

    private func cleanReasonText(_ text: String) -> String {
        let cleaned = text
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "&", with: " & ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return cleaned
            .split(separator: " ")
            .prefix(5)
            .joined(separator: " ")
    }

    private struct ParsedAmount {
        let raw: String
        let numericValue: Double
    }

    private func submitExpense() {
        guard !amount.isEmpty, !selectedVehicleId.isEmpty else {
            errorMessage = "Please fill all required fields"
            showError = true
            return
        }
        
        isSaving = true
        
        Task {
            do {
                guard let userId = SessionManager.shared.getUserId() else {
                    throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
                }
                
                // Generate a temporary expense ID for the image filename
                let expenseId = UUID().uuidString
                var savedImagePath: String? = nil
                
                // Save image locally if available
                if let image = selectedImage {
                    savedImagePath = try ImageStorageManager.shared.saveBillImage(image, forExpenseId: expenseId)
                }
                
                try await saveExpense(
                    amount: Double(amount) ?? 0,
                    reason: reason,
                    text: extractedText,
                    vehicleId: selectedVehicleId,
                    userId: userId,
                    billImagePath: savedImagePath
                )
                
                DispatchQueue.main.async {
                    isSaving = false
                    showSuccess = true
                    
                    // Dismiss after 1.5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isSaving = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Bundle Bill Image Picker

struct BundleBillImagePicker: View {
    @Binding var selectedImage: UIImage?
    var onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var bundleImages: [(name: String, image: UIImage)] = []
    
    var body: some View {
        ZStack {
            AppTheme.Gradients.auth.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Select Bill Image")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    Spacer().frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                
                ScrollView { // Added ScrollView to handle multiple images
                    VStack(alignment: .leading, spacing: 16) {
                        if !BillImageManager.shared.isBundledFolderAvailable {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                Text("Test Images (Add Documents folder for real images)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        } else {
                            Text("Available Bill Images")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(bundleImages, id: \.name) { item in
                                Button(action: {
                                    selectedImage = item.image
                                    onImageSelected(item.image)
                                    dismiss()
                                }) {
                                    HStack(spacing: 12) {
                                        Image(uiImage: item.image)
                                            .resizable()
                                            .scaledToFill() // Changed to Fill for a better thumbnail look
                                            .frame(width: 60, height: 60)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name.replacingOccurrences(of: "_", with: " ").capitalized)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text("Tap to select")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            // This is now correctly attached to the ZStack inside the body
            bundleImages = BillImageManager.shared.getAvailableBillImages()
        }
    }
}


// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImageSelected: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImageSelected(uiImage)
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


// MARK: - Preview

#Preview {
    ExpenseSubmissionView()
}
