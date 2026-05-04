import Foundation
import UIKit

class DocumentImageManager {
    static let shared = DocumentImageManager()
    private let sampleNames = ["document_sample_1", "document_sample_2", "document_sample_3"]

    private func generateSampleDocumentImage(title: String, subtitle: String, expiryLine: String) -> UIImage {
        let size = CGSize(width: 420, height: 560)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            let headerRect = CGRect(x: 0, y: 0, width: size.width, height: 72)
            UIColor(red: 0.17, green: 0.25, blue: 0.36, alpha: 1).setFill()
            context.fill(headerRect)

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 19),
                .foregroundColor: UIColor.white
            ]
            (title as NSString).draw(in: CGRect(x: 20, y: 18, width: size.width - 40, height: 24), withAttributes: titleAttributes)

            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(0.85)
            ]
            (subtitle as NSString).draw(in: CGRect(x: 20, y: 44, width: size.width - 40, height: 18), withAttributes: subtitleAttributes)

            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.darkGray
            ]
            let bodyText = "Policy Holder: AUTO LEGACY\nVehicle: Sample Vehicle\nDocument No: DL-2048-8891\nIssue Date: 12/03/2025\n\n" + expiryLine + "\n\nNotes: OCR should detect the expiry date from this page."
            (bodyText as NSString).draw(in: CGRect(x: 24, y: 102, width: size.width - 48, height: 360), withAttributes: bodyAttributes)

            let footerRect = CGRect(x: 24, y: 470, width: size.width - 48, height: 58)
            UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1).setFill()
            context.fill(footerRect)

            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor(red: 0.17, green: 0.25, blue: 0.36, alpha: 1)
            ]
            ("EXPIRY: " as NSString).draw(in: CGRect(x: 36, y: 486, width: 90, height: 18), withAttributes: footerAttributes)

            let expiryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1)
            ]
            (expiryLine as NSString).draw(in: CGRect(x: 120, y: 484, width: size.width - 140, height: 22), withAttributes: expiryAttributes)
        }
    }

    func getAvailableDocumentImages() -> [(name: String, image: UIImage)] {
        var assets: [(name: String, image: UIImage)] = []

        for name in sampleNames {
            if let image = UIImage(named: name) {
                assets.append((name: name, image: image))
            }
        }

        if !assets.isEmpty {
            return assets
        }

        return [
            (name: "sample_insurance", image: generateSampleDocumentImage(title: "INSURANCE CERTIFICATE", subtitle: "Sample document image", expiryLine: "Expiry Date: 24/12/2026")),
            (name: "sample_driving_license", image: generateSampleDocumentImage(title: "DRIVING LICENSE", subtitle: "Sample document image", expiryLine: "Valid Until: 15 Jan 2027")),
            (name: "sample_vehicle_license", image: generateSampleDocumentImage(title: "VEHICLE LICENSE", subtitle: "Sample document image", expiryLine: "Expires On: 2026-10-15"))
        ]
    }

    func loadDocumentImage(named name: String) -> UIImage? {
        if let assetImage = UIImage(named: name) {
            return assetImage
        }

        return getAvailableDocumentImages().first(where: { $0.name == name })?.image
    }
}
