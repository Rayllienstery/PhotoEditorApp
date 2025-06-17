//
//  PhotoError.swift
//  PhotoEditorApp
//
//  Created by Kostiantyn Kolosov on 17.06.2025.
//

import Foundation

enum PhotoError: Error, LocalizedError {
  case noPhoto
  case invalidFormat
  case unknown
  case saveFailed

  var errorDescription: String? {
    switch self {
    case .noPhoto: return "No photo selected."
    case .invalidFormat: return "Invalid photo format."
    case .unknown: return "Unknown error."
    case .saveFailed: return "Failed to save photo."
    }
  }
}
