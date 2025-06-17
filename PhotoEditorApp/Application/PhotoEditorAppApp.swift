//
//  PhotoEditorAppApp.swift
//  PhotoEditorApp
//
//  Created by Kostiantyn Kolosov on 17.06.2025.
//

import SwiftUI

@main
struct PhotoEditorApp: App {

  var body: some Scene {
    WindowGroup {
      PhotoEditorView(
        model: PhotoEditorViewModelImpl(
          editPhotoUseCase: EditPhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl()),
          savePhotoUseCase: SavePhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl())
        )
      )
    }
  }
}
