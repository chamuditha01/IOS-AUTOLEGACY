import SwiftUI

struct DocumentTypeSelectionView: View {
    @Binding var isPresented: Bool
    @Binding var selectedDocType: String?
    @Binding var showSubmissionView: Bool
    
    let documentTypes: [(name: String, image: String)]
    
    let documentInfo: [String: (icon: String, description: String)] = [
        "insurance": (icon: "lock.shield.fill", description: "Vehicle Insurance Document"),
        "driving license": (icon: "card.fill", description: "Driver's License"),
        "vehicle license": (icon: "paperclip", description: "Vehicle Registration License")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.23, green: 0.29, blue: 0.38)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Select Document Type")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Document Type Options
                VStack(spacing: 16) {
                    ForEach(documentTypes, id: \.name) { docType in
                        documentTypeButton(
                            title: docType.name.uppercased(),
                            icon: documentInfo[docType.name]?.icon ?? "doc",
                            description: documentInfo[docType.name]?.description ?? "",
                            action: {
                                selectedDocType = docType.name
                                isPresented = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showSubmissionView = true
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                Spacer()
            }
        }
    }
    
    private func documentTypeButton(title: String, icon: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(red: 0.62, green: 0.73, blue: 0.96))
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct DocumentTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentTypeSelectionView(
            isPresented: .constant(true),
            selectedDocType: .constant(nil),
            showSubmissionView: .constant(false),
            documentTypes: [
                ("insurance", "https://i.ibb.co/yjryBHR/Gemini-Generated-Image-b5g2ynb5g2ynb5g2.png"),
                ("driving license", "https://i.ibb.co/rRT6JHBF/Gemini-Generated-Image-k2z2dek2z2dek2z2.png"),
                ("vehicle license", "https://i.ibb.co/ntR8943/Gemini-Generated-Image-i4oj76i4oj76i4oj.png")
            ]
        )
    }
}
