//
//  PhotoEntity.swift
//  PhotoEditorApp
//
//  Created by Kostiantyn Kolosov on 17.06.2025.
//

import UIKit

struct PhotoEntity: Identifiable, Hashable {
  let id: UUID = .init()
  let image: UIImage

  // additional fields and methods
}
