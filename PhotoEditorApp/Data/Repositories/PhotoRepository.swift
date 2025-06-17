//
//  PhotoRepository.swift
//  PhotoEditorApp
//
//  Created by Kostiantyn Kolosov on 17.06.2025.
//

import UIKit

protocol PhotoRepository {
  func saveToLibrary(photo: PhotoEntry, completion: @escaping (Result<Void, Error>) -> Void)
}
final class PhotoRepositoryImpl: NSObject, PhotoRepository {
  private var completion: ((Result<Void, Error>) -> Void)?

  func saveToLibrary(photo: PhotoEntry, completion: @escaping (Result<Void, Error>) -> Void) {
    self.completion = completion
    UIImageWriteToSavedPhotosAlbum(
      photo.image, self,
      #selector(saveImageCompletionHandler(_:didFinishSavingWithError:contextInfo:)), nil)
  }

  @objc private func saveImageCompletionHandler(
    _ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?
  ) {
    if let error {
      completion?(.failure(error))
    } else {
      completion?(.success(()))
    }
    completion = nil
  }
}
