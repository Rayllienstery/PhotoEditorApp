//
//  PhotoRepository.swift
//  PhotoEditorApp
//
//  Created by Sakir Saiyed on 2025-06-20.
//

import Foundation

protocol PhotoRepository {
    func saveToLibrary(photo: PhotoEntity, completion: @escaping (Result<Void, Error>) -> Void)
}

