import UIKit

final class ImageManager {
  static let shared = ImageManager()
  weak var firebase: FirebaseCommunicator?
  
  private var largeProfileImages: [String:UIImage] = [:]
  private var smallProfileImages: [String:UIImage] = [:]
  private var idQueue: Set<String> = []
  
  func retreiveProfileImageFor(id: String, isLargeSize: Bool = false, completion: @escaping (UIImage) -> Void) {
    if isLargeSize {
      if let profileImage = largeProfileImages[id] {
        completion(profileImage)
        return
      }
    } else {
      if let profileImage = smallProfileImages[id] {
        completion(profileImage)
        return
      }
    }
    
    // If insertion is successful, it means the image associated with this id has not been queued
    // If insertion is unsucessful, it means the image associated with this id is currently in queue
    if idQueue.insert(id).inserted {
      firebase?.downloadImage(withID: id) { data in
        guard let data = data else { return }
        // WWDC18: 'Image and Graphics Best Practices'
        // Source: https://developer.apple.com/videos/play/wwdc2018/219/
        let cgImageSource = CGImageSourceCreateWithData(data as CFData, nil)!  // What is CFdata...?
        // There are more options that can be added here
        let options: [NSString: Any] = [
          kCGImageSourceThumbnailMaxPixelSize: isLargeSize ? 150 : 20,
          kCGImageSourceCreateThumbnailFromImageAlways: true,
          kCGImageSourceShouldCacheImmediately: true,
          kCGImageSourceCreateThumbnailWithTransform: true
        ]
        if let scaledImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, options as CFDictionary) {
          let image = UIImage(cgImage: scaledImage)
          if isLargeSize {
            self.largeProfileImages[id] = image
          } else {
            self.smallProfileImages[id] = image
          }
          self.idQueue.remove(id)
          completion(image)
        }
      }
    }
  }
  
  private init(){}
}
