import Foundation
import UIKit

class ImageStorageManager {
    static let shared = ImageStorageManager()
    
    private let fileManager = FileManager.default
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var billsDirectory: URL {
        let billsDir = documentsDirectory.appendingPathComponent("Bills")
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: billsDir.path) {
            try? fileManager.createDirectory(at: billsDir, withIntermediateDirectories: true)
        }
        
        return billsDir
    }
    
    /// Save a bill image locally and return the file path
    func saveBillImage(_ image: UIImage, forExpenseId expenseId: String) throws -> String {
        // Create filename with timestamp
        let timestamp = Date().timeIntervalSince1970
        let filename = "bill_\(expenseId)_\(timestamp).jpg"
        let fileURL = billsDirectory.appendingPathComponent(filename)
        
        // Compress and save image
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.imageCompressionFailed
        }
        
        try imageData.write(to: fileURL)
        
        print("✅ Bill image saved: \(filename)")
        print("📁 Path: \(fileURL.path)")
        
        // Return relative path for storage in database
        return filename
    }
    
    /// Load a bill image from local storage
    func loadBillImage(filename: String) -> UIImage? {
        let fileURL = billsDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("❌ Image file not found: \(filename)")
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// Delete a bill image
    func deleteBillImage(filename: String) throws {
        let fileURL = billsDirectory.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("✅ Bill image deleted: \(filename)")
        }
    }
    
    /// Get all saved bill images
    func getAllBillImages() -> [String] {
        do {
            let files = try fileManager.contentsOfDirectory(atPath: billsDirectory.path)
            return files.filter { $0.hasSuffix(".jpg") }
        } catch {
            print("❌ Error reading bills directory: \(error)")
            return []
        }
    }
    
    /// Get the size of all saved bills
    func getBillsDirectorySize() -> String {
        var totalSize: Int = 0
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: billsDirectory.path)
            
            for file in files {
                let fileURL = billsDirectory.appendingPathComponent(file)
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                if let fileSize = attributes[.size] as? Int {
                    totalSize += fileSize
                }
            }
        } catch {
            print("❌ Error calculating directory size: \(error)")
        }
        
        return formatFileSize(totalSize)
    }
    
    /// Format bytes to human-readable size
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    /// Clear all saved bill images
    func clearAllBills() throws {
        do {
            let files = try fileManager.contentsOfDirectory(atPath: billsDirectory.path)
            for file in files {
                let fileURL = billsDirectory.appendingPathComponent(file)
                try fileManager.removeItem(at: fileURL)
            }
            print("✅ All bill images cleared")
        } catch {
            print("❌ Error clearing bills: \(error)")
            throw StorageError.deletionFailed
        }
    }
}

enum StorageError: Error {
    case imageCompressionFailed
    case deletionFailed
    case directoryCreationFailed
    
    var localizedDescription: String {
        switch self {
        case .imageCompressionFailed:
            return "Failed to compress image"
        case .deletionFailed:
            return "Failed to delete image"
        case .directoryCreationFailed:
            return "Failed to create storage directory"
        }
    }
}