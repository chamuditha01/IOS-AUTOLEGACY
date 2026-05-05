import Foundation
import UIKit

class DocumentImageManager {
    static let shared = DocumentImageManager()

    func getAvailableDocumentImages() -> [(name: String, image: UIImage)] {
        let assetNames = ["bill_sample_1"]
        let assets = assetNames.compactMap { name -> (name: String, image: UIImage)? in
            guard let image = UIImage(named: name) else { return nil }
            return (name: name, image: image)
        }

        if !assets.isEmpty {
            return assets
        }

        return BillImageManager.shared.getAvailableBillImages()
    }

    func loadDocumentImage(named name: String) -> UIImage? {
        if let assetImage = UIImage(named: name) {
            return assetImage
        }

        return BillImageManager.shared.loadBillImage(named: name) ?? getAvailableDocumentImages().first(where: { $0.name == name })?.image
    }
}
