//
//  EditPhotoUseCase.swift
//  PhotoEditorApp
//
//  Created by Kostiantyn Kolosov on 17.06.2025.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

protocol EditPhotoUseCase {
  func execute(photo: PhotoEntity) throws -> PhotoEntity
}

final class EditPhotoUseCaseImpl: EditPhotoUseCase {
  private let photoRepository: PhotoRepository
  private let context = CIContext()

  init(photoRepository: PhotoRepository) {
    self.photoRepository = photoRepository
  }

  func execute(photo: PhotoEntity) throws -> PhotoEntity {
    guard let filtered = applyMonoFilter(to: photo.image) else {
      throw PhotoError.invalidFormat
    }
    let entry = PhotoEntity(image: filtered)
    return entry
  }

  // Mono filter using CoreImage
  private func applyMonoFilter(to image: UIImage) -> UIImage? {
    guard let ciImage = CIImage(image: image) else { return nil }
    let filter = CIFilter.photoEffectMono()
    filter.inputImage = ciImage
    guard let outputImage = filter.outputImage,
      let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
    else { return nil }
    return UIImage(cgImage: cgImage)
  }
}
