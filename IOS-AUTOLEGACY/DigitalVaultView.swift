import SwiftUI
import Supabase
import PostgREST

struct VehicleDocument: Identifiable, Decodable {
    let id: UUID
    let filepath: String?
    let vehicleid: UUID?
    let doctype: String?
    let expirydate: String?
    
    var daysLeft: Int? {
        guard let expiryString = expirydate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let expiry = formatter.date(from: expiryString) else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiry)
        return components.day
    }
    
    var statusTitle: String {
        if let days = daysLeft {
            if days > 30 { return "ACTIVE" }
            else if days > 0 { return "EXPIRING SOON" }
            else { return "EXPIRED" }
        }
        return "UNKNOWN"
    }
    
    var statusColor: Color {
        if let days = daysLeft {
            if days > 30 { return Color(red: 0.16, green: 0.65, blue: 0.27) }
            else if days > 0 { return Color(red: 0.96, green: 0.53, blue: 0.53) }
            else { return Color.red }
        }
        return Color.gray
    }
    
    var formatExpiryDate: String {
        guard let expiryString = expirydate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let expiry = formatter.date(from: expiryString) else { return "Unknown" }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy-MM-dd"
        return displayFormatter.string(from: expiry)
    }
}

struct DigitalVaultView: View {
    @State private var documents: [VehicleDocument] = []
    @State private var isLoading = false
    @State private var showDocTypeSelection = false
    @State private var selectedDocType: String?
    @State private var showSubmissionView = false
    @State private var selectedDocument: VehicleDocument?
    @State private var showEditView = false
    
    let documentTypes: [(name: String, image: String)] = [
        ("insurance", "https://i.ibb.co/yjryBHR/Gemini-Generated-Image-b5g2ynb5g2ynb5g2.png"),
        ("driving license", "https://i.ibb.co/rRT6JHBF/Gemini-Generated-Image-k2z2dek2z2dek2z2.png"),
        ("vehicle license", "https://i.ibb.co/ntR8943/Gemini-Generated-Image-i4oj76i4oj76i4oj.png")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.23, green: 0.29, blue: 0.38)
                .ignoresSafeArea()
            
            VStack {
                // Custom Header
                HStack {
                    Button(action: {
                        // Back action if needed, though usually tab handles it or we don't need back if it's a top level tab
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Digital Vault")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer for balance
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.top, 50)
                        } else if documents.isEmpty {
                            Text("No documents found")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.top, 50)
                        } else {
                            ForEach(documents) { doc in
                                Button(action: {
                                    selectedDocument = doc
                                    showEditView = true
                                }) {
                                    documentCard(for: doc)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120) // padding for custom nav bar
                }
            }
            
            // Floating Plus Button
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: { showDocTypeSelection = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color(red: 0.62, green: 0.73, blue: 0.96))
                            .clipShape(Circle())
                            .shadow(color: Color(red: 0.62, green: 0.73, blue: 0.96).opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                        .frame(width: 20)
                }
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showDocTypeSelection) {
            DocumentTypeSelectionView(
                isPresented: $showDocTypeSelection,
                selectedDocType: $selectedDocType,
                showSubmissionView: $showSubmissionView,
                documentTypes: documentTypes
            )
        }
        .sheet(isPresented: $showSubmissionView) {
            if let docType = selectedDocType,
               let docInfo = documentTypes.first(where: { $0.name == docType }) {
                DocumentSubmissionView(
                    documentType: docType,
                    documentImage: docInfo.image,
                    documentId: nil,
                    existingVehicleId: nil,
                    existingExpiryDate: nil,
                    onSuccess: {
                        Task {
                            await fetchDocuments()
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showEditView) {
            if let doc = selectedDocument,
               let vehicleId = doc.vehicleid?.uuidString {
                DocumentSubmissionView(
                    documentType: doc.doctype ?? "Document",
                    documentImage: doc.filepath ?? "",
                    documentId: doc.id.uuidString,
                    existingVehicleId: vehicleId,
                    existingExpiryDate: doc.expirydate,
                    onSuccess: {
                        Task {
                            await fetchDocuments()
                        }
                    }
                )
            }
        }
        .task {
            await fetchDocuments()
        }
    }
    
    private func fetchDocuments() async {
        isLoading = true
        do {
            let fetchedDocuments: [VehicleDocument] = try await supabase
                .from("document")
                .select()
                .execute()
                .value
            
            DispatchQueue.main.async {
                self.documents = fetchedDocuments
                self.isLoading = false
            }
        } catch {
            print("Failed to fetch documents: \(error)")
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    @ViewBuilder
    private func documentCard(for doc: VehicleDocument) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(doc.doctype?.uppercased() ?? "DOCUMENT")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(1.5)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: doc.statusTitle == "ACTIVE" ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 10, weight: .bold))
                    Text(doc.statusTitle)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                }
                .foregroundColor(doc.statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(doc.statusColor.opacity(0.2))
                .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.2))
                    .frame(height: 180)
                
                if let urlString = doc.filepath, let _ = URL(string: urlString) {
                    AsyncImage(url: URL(string: urlString)) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Text(doc.doctype?.uppercased() ?? "DOCUMENT")
                        .font(.system(size: 24, weight: .black, design: .serif))
                        .italic()
                        .foregroundColor(.black.opacity(0.4))
                        .rotationEffect(.degrees(-15))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("STATUS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    Text(doc.statusTitle == "ACTIVE" ? "Valid until \(doc.formatExpiryDate)" : "Expires on \(doc.formatExpiryDate)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(doc.statusColor)
                }
                
                Spacer()
                
                if let days = doc.daysLeft {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(max(days, 0))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(red: 0.62, green: 0.73, blue: 0.96))
                        Text(days == 1 ? "DAY LEFT" : "DAYS LEFT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(Color(red: 0.14, green: 0.15, blue: 0.16))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// Helper gradient for placeholder
struct ColorInterpolation {
    func gradient() -> LinearGradient {
        LinearGradient(
            colors: [Color(white: 0.4), Color(white: 0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    DigitalVaultView()
}
