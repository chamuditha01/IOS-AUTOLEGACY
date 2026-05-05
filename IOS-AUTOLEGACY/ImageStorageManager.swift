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
    
    private var qrTransferDirectory: URL {
        let qrDir = documentsDirectory.appendingPathComponent("QRTransfers")
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: qrDir.path) {
            try? fileManager.createDirectory(at: qrDir, withIntermediateDirectories: true)
        }
        
        return qrDir
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
    
    // MARK: - QR Transfer Image Methods
    
    /// Save a QR transfer image locally and return the file path
    /// Format: qr_transfer_<vehicleId>_<timestamp>.jpg
    func saveQRTransferImage(_ image: UIImage, forVehicleId vehicleId: String, buyerId: Int) throws -> String {
        let timestamp = Date().timeIntervalSince1970
        let filename = "qr_transfer_\(vehicleId)_\(buyerId)_\(timestamp).jpg"
        let fileURL = qrTransferDirectory.appendingPathComponent(filename)
        
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            throw StorageError.imageCompressionFailed
        }
        
        try imageData.write(to: fileURL)
        
        print("✅ QR Transfer image saved: \(filename)")
        print("📁 Path: \(fileURL.path)")
        
        return filename
    }
    
    /// Load a QR transfer image from local storage
    func loadQRTransferImage(filename: String) -> UIImage? {
        let fileURL = qrTransferDirectory.appendingPathComponent(filename)
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("❌ QR Transfer image file not found: \(filename)")
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    /// Delete a QR transfer image
    func deleteQRTransferImage(filename: String) throws {
        let fileURL = qrTransferDirectory.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
            print("✅ QR Transfer image deleted: \(filename)")
        }
    }
    
    /// Get all saved QR transfer images
    func getAllQRTransferImages() -> [String] {
        do {
            let files = try fileManager.contentsOfDirectory(atPath: qrTransferDirectory.path)
            return files.filter { $0.hasSuffix(".jpg") }
        } catch {
            print("❌ Error reading QR transfers directory: \(error)")
            return []
        }
    }
    
    /// Get QR transfer images for a specific vehicle
    func getQRTransferImagesForVehicle(_ vehicleId: String) -> [String] {
        getAllQRTransferImages().filter { $0.contains("qr_transfer_\(vehicleId)") }
    }
    
    /// Clear all saved QR transfer images
    func clearAllQRTransfers() throws {
        do {
            let files = try fileManager.contentsOfDirectory(atPath: qrTransferDirectory.path)
            for file in files {
                let fileURL = qrTransferDirectory.appendingPathComponent(file)
                try fileManager.removeItem(at: fileURL)
            }
            print("✅ All QR transfer images cleared")
        } catch {
            print("❌ Error clearing QR transfers: \(error)")
            throw StorageError.deletionFailed
        }
    }
    
    /// Get the full file path for a QR transfer image (useful for asset bundling)
    func getQRTransferImagePath(filename: String) -> String {
        return qrTransferDirectory.appendingPathComponent(filename).path
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
