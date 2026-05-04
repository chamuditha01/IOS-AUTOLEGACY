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
        To add bill images:
        
        1. Create a folder named "Documents" in your Xcode project
        2. Add your bill images (.png, .jpg, .jpeg, .heic) to that folder
        3. In Xcode: Right-click project → Add Files
        4. Select the Documents folder
        5. Check "Copy items if needed" and "Create folder references"
        6. Ensure it's added to the IOS-AUTOLEGACY target
        7. Rebuild and run
        """
    }
    
    /// Get all available bill images from the bundled Documents folder.
    func getAvailableBillImages() -> [(name: String, image: UIImage)] {
        guard let folderURL = bundleFolderURL else {
            print("⚠️ Documents folder not found in bundle. Add it via Xcode.")
            return []
        }

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
            
            print("✅ Loaded \(images.count) images from Documents folder")
            return images
        } catch {
            print("❌ Failed to scan bundled Documents folder: \(error)")
            return []
        }
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
