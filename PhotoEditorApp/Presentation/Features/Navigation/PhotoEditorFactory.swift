//
//  PhotoEditorFactory.swift
//  PhotoEditorApp
//
//  Created by Kostiantyn Kolosov on 04.07.2025.
//

import SwiftUI

final class PhotoEditorFactory {
  func impl() -> some View {
    // Repository
    let photoRepository = PhotoRepositoryImpl()
    
    // UseCases
    let savePhotoUseCase = SavePhotoUseCaseImpl(photoRepository: photoRepository)
    let editPhotoUseCase: EditPhotoUseCase = EditPhotoUseCaseImpl(photoRepository: photoRepository)
    
    // ViewModel
    let viewModel = PhotoEditorViewModelImpl(
      editPhotoUseCase: editPhotoUseCase,
      savePhotoUseCase: savePhotoUseCase
    )

    return PhotoEditorView(model: viewModel)
  }
}
