import UIKit

final class ImageService {
    static let shared = ImageService()
    private init() {}

    private let maxImageSize: CGFloat = 512
    private let compressionQuality: CGFloat = 0.7

    func process(_ rawData: Data) throws -> Data {
        guard let image = UIImage(data: rawData) else {
            throw AppError.imageProcessingFailed
        }
        let resized = resize(image)
        guard let compressed = resized.jpegData(compressionQuality: compressionQuality) else {
            throw AppError.imageProcessingFailed
        }
        return compressed
    }

    private func resize(_ image: UIImage) -> UIImage {
        let size = image.size
        guard size.width > maxImageSize || size.height > maxImageSize else { return image }
        let ratio = min(maxImageSize / size.width, maxImageSize / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
