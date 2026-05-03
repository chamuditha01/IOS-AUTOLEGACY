import Foundation
import SwiftUI

class BillImageManager {
    static let shared = BillImageManager()
    
    /// Get all available bill images from the bundle
    func getAvailableBillImages() -> [(name: String, image: UIImage?)] {
        let imageNames = ["bill_sample_1", "bill_sample_2", "bill_sample_3", "bill_receipt", "bill_invoice"]
        
        return imageNames.compactMap { name in
            if let image = UIImage(named: name) {
                return (name: name, image: image)
            }
            return nil
        }
    }
    
    /// Load a bill image by name
    func loadBillImage(named name: String) -> UIImage? {
        return UIImage(named: name)
    }
    
    /// Get all image names in Assets (for demonstration)
    func getAllBundleImageNames() -> [String] {
        // This lists common bill-related image names that should be in Assets.xcassets
        return [
            "bill_sample_1",
            "bill_sample_2",
            "bill_sample_3",
            "bill_receipt",
            "bill_invoice"
        ]
    }
}
