import Foundation
import SwiftUI

class BillImageManager {
    static let shared = BillImageManager()
    private let folderName = "Documents"
    private let supportedExtensions = ["png", "jpg", "jpeg", "heic"]
    
    private var bundleFolderURL: URL? {
        Bundle.main.resourceURL?.appendingPathComponent(folderName, isDirectory: true)
    }
    
    /// Check if the Documents folder exists in the bundle
    var isBundledFolderAvailable: Bool {
        guard let folderURL = bundleFolderURL else { return false }
        return FileManager.default.fileExists(atPath: folderURL.path)
    }
    
    /// Get setup instructions for adding Documents folder
    var setupInstructions: String {
        """
        To add real bill images:
        
        1. Create a folder named "Documents" in your Xcode project
        2. Add your bill images (.png, .jpg, .jpeg, .heic) to that folder
        3. In Xcode: Right-click project → Add Files
        4. Select the Documents folder
        5. Check "Copy items if needed" and "Create folder references"
        6. Ensure it's added to the IOS-AUTOLEGACY target
        7. Rebuild and run
        """
    }
    
    /// Generate a test bill image with placeholder content
    private func generateTestBillImage(title: String) -> UIImage {
        let size = CGSize(width: 400, height: 500)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Header
            let headerRect = CGRect(x: 0, y: 0, width: size.width, height: 60)
            UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1).setFill()
            context.fill(headerRect)
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.white
            ]
            let titleString = title as NSString
            titleString.draw(in: CGRect(x: 20, y: 20, width: size.width - 40, height: 20), withAttributes: titleAttributes)
            
            // Content text
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray
            ]
            let bodyText = "SAMPLE BILL CONTENT\nDate: \(Date().formatted())\nTotal: Rs. 5,000.00"
            (bodyText as NSString).draw(in: CGRect(x: 20, y: 80, width: size.width - 40, height: 300), withAttributes: contentAttributes)
        }
        
        return image
    }

    /// Get all available bill images from the bundled Documents folder, or load from Assets
    func getAvailableBillImages() -> [(name: String, image: UIImage)] {
        // 1. Try to load from bundled Documents folder first
        if let folderURL = bundleFolderURL {
            do {
                let files = try FileManager.default.contentsOfDirectory(
                    at: folderURL,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )
                
                let images: [(name: String, image: UIImage)] = files
                    .filter { supportedExtensions.contains($0.pathExtension.lowercased()) }
                    .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
                    .compactMap { (url: URL) -> (name: String, image: UIImage)? in
                        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
                        return (name: url.deletingPathExtension().lastPathComponent, image: image)
                    }
                
                if !images.isEmpty {
                    print("✅ Loaded \(images.count) real images from Documents folder")
                    return images
                }
            } catch {
                print("⚠️ Failed to scan bundled Documents folder: \(error)")
            }
        }
        
        // 2. Try to load specific samples from Assets if folder search failed
        print("📋 Checking Assets for bill_sample images")
        var assets: [(name: String, image: UIImage)] = []
        for i in 1...3 {
            let assetName = "bill_sample_\(i)"
            if let assetImage = UIImage(named: assetName) {
                assets.append((name: assetName, image: assetImage))
            }
        }
        
        if !assets.isEmpty {
            return assets
        }
        
        // 3. Last Resort: Generate purely dynamic test images
        print("🛠 Generating dynamic test images")
        return [
            (name: "test_bill_1", image: generateTestBillImage(title: "AUTO REPAIR BILL #001")),
            (name: "test_bill_2", image: generateTestBillImage(title: "SERVICE INVOICE #002"))
        ]
    }
    
    /// Load a bill image by filename from the bundled Documents folder.
    func loadBillImage(named name: String) -> UIImage? {
        // Check Assets first
        if let assetImage = UIImage(named: name) {
            return assetImage
        }
        
        guard let folderURL = bundleFolderURL else { return nil }
        
        let exactMatchCandidates = supportedExtensions.flatMap { [folderURL.appendingPathComponent(name).appendingPathExtension($0)] }
        if let existingURL = exactMatchCandidates.first(where: { FileManager.default.fileExists(atPath: $0.path) }) {
            return UIImage(contentsOfFile: existingURL.path)
        }
        
        let files = (try? FileManager.default.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []
        
        guard let matchedURL = files.first(where: { $0.deletingPathExtension().lastPathComponent == name }) else {
            return nil
        }
        
        return UIImage(contentsOfFile: matchedURL.path)
    }
    
    /// Get the file names available in the bundled Documents folder.
    func getAllBundleImageNames() -> [String] {
        getAvailableBillImages().map { $0.name }
    }
}
