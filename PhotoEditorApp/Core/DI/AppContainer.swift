//
//  AppContainer.swift
//  PhotoEditorApp
//
//  Created by Sakir Saiyed on 2025-06-20.
//

import Foundation

final class AppContainer {
    static let shared = AppContainer()
    
    private init() {}
    
    // MARK: - Repository
    private lazy var photoRepository: PhotoRepository = {
        return PhotoRepositoryImpl()
    }()
    
    // MARK: - UseCases
    lazy var savePhotoUseCase: SavePhotoUseCase = {
        return SavePhotoUseCaseImpl(photoRepository: photoRepository)
    }()
    
    lazy var editPhotoUseCase: EditPhotoUseCase = {
        return EditPhotoUseCaseImpl(photoRepository: photoRepository)
    }()
    
    // MARK: - ViewModels
    func makePhotoEditorViewModel() -> PhotoEditorViewModelImpl {
        return PhotoEditorViewModelImpl(
            editPhotoUseCase: editPhotoUseCase,
            savePhotoUseCase: savePhotoUseCase
        )
    }
}
