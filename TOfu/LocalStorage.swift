import Foundation
import UIKit

class LocalStorage {
  enum StorageType {
    case userDefaults
    case fileSystem
  }
  static let shared = LocalStorage()
  
  // Storing profile image using 2 methods, UserDefaults or FileManager
  func storeProfileImage(with imageData: Data, id: String, using type: StorageType) {
    switch type {
      case .userDefaults:
        UserDefaults.standard.set(imageData, forKey: "profileImages")
      case .fileSystem:
        if let filePath = retrivePNGFilePath(withDirectoryName: "profileImages") {
          let isDirectoryCreated = FileManager.default.fileExists(atPath: filePath.path)
          if !isDirectoryCreated {
            do {
              print("directory is not created")
              try FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
              print(error)
            }
          }
          
          do {
            try imageData.write(to: filePath.appendingPathComponent(id), options: .atomic)
          } catch let error {
            print("Failed retriving local profile image. \(error)")
            return
          }
        }
    }
    
    // Recording the date of stored image
    UserDefaults.standard.set(Date(), forKey: "imageSaveTimestamp")
  }
  
  func restreiveProfileImage(forID id: String, from type: StorageType) -> UIImage? {
    switch type {
      case .userDefaults:
        if let imageData = UserDefaults.standard.object(forKey: "profileImages") as? Data,
           let image     = UIImage(data: imageData) {
           return image
        }
      case .fileSystem:
        if let filePath  = retrivePNGFilePath(withDirectoryName: "profileImages"),
           let imageData = FileManager.default.contents(atPath: filePath.appendingPathComponent(id).path),
           let image     = UIImage(data: imageData) {
           return image
        }
    }
    return nil // Error
  }
  
  // Extra step for using FileManager to store profile picture
  // Creating a file path (example: /Home/documents/image.png)
  func retrivePNGFilePath(withDirectoryName directoryName: String) -> URL? {
    let fileManager = FileManager.default
    guard let url = fileManager.urls(
      for: .documentDirectory,
      in:  FileManager.SearchPathDomainMask.userDomainMask).first
    else { return nil }
    return url.appendingPathComponent("\(directoryName)/")
  }
}
