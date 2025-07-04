//
//  SavePhotoUseCase.swift
//  PhotoEditorApp
//
//  Created by Kostiantyn Kolosov on 17.06.2025.
//

import Foundation

protocol SavePhotoUseCase {
  func execute(photo: PhotoEntity, completion: @escaping (Result<Void, Error>) -> Void)
}

final class SavePhotoUseCaseImpl: SavePhotoUseCase {
  private let photoRepository: PhotoRepository

  init(photoRepository: PhotoRepository) {
    self.photoRepository = photoRepository
  }

  func execute(photo: PhotoEntity, completion: @escaping (Result<Void, Error>) -> Void) {
    photoRepository.saveToLibrary(photo: photo, completion: completion)
  }
}
