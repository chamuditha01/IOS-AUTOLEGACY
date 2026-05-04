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
            
                }
            } catch {
                print("⚠️ Failed to scan bundled Documents folder: \(error)")
            }
        }
        
        // Fallback: Generate test bill images
        print("📋 Generating test bill images (Documents folder not found)")
        return [
            (name: "test_bill_1", image: generateTestBillImage(title: "AUTO REPAIR BILL #001")),
            (name: "test_bill_2", image: generateTestBillImage(title: "SERVICE INVOICE #002")),
            (name: "test_bill_3", image: generateTestBillImage(title: "MAINTENANCE BILL #003"))
        ]
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
    
        /// Get all available bill images from the bundled Documents folder, or load from Assets
        func getAvailableBillImages() -> [(name: String, image: UIImage)] {
            // Try to load from bundled Documents folder first
            if let folderURL = bundleFolderURL {
                do {
                    let files = try FileManager.default.contentsOfDirectory(
                        at: folderURL,
                        includingPropertiesForKeys: nil,
                        options: [.skipsHiddenFiles]
                    )

                    let images = files
                        .filter { supportedExtensions.contains($0.pathExtension.lowercased()) }
                        .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
                        .compactMap { url in
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
        
            // Fallback: Load test bill images from Assets
            print("📋 Loading test bill images from Assets")
            var assets: [(name: String, image: UIImage)] = []
            if let image1 = UIImage(named: "bill_sample_1") {
                assets.append((name: "bill_sample_1", image: image1))
            }
            if let image2 = UIImage(named: "bill_sample_2") {
                assets.append((name: "bill_sample_2", image: image2))
            }
            if let image3 = UIImage(named: "bill_sample_3") {
                assets.append((name: "bill_sample_3", image: image3))
            }
            return assets

    // The BillImageManager class has been replaced with an assets-based image loading implementation.
    // The previous image generation functionality has been removed.
        }
    
    /// Load a bill image by filename from the bundled Documents folder.
    func loadBillImage(named name: String) -> UIImage? {
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
