import PhotosUI
import SwiftUI

protocol PhotoEditorViewModel: Observable, AnyObject {
  var photo: PhotoEntity? { get set }
  var error: Error? { get set }
  var saveMessage: String? { get set }
  var isLoading: Bool { get set }
  var selectedItem: PhotosPickerItem? { get set }

  init(
    editPhotoUseCase: EditPhotoUseCase,
    savePhotoUseCase: SavePhotoUseCase
  )

  func setPhoto(image: UIImage)
  func applyFilter()
  func savePhoto()
}

@Observable
final class PhotoEditorViewModelImpl: PhotoEditorViewModel {
  private let editPhotoUseCase: EditPhotoUseCase
  private let savePhotoUseCase: SavePhotoUseCase

  var photo: PhotoEntity?
  var error: Error?
  var saveMessage: String?
  var isLoading: Bool = false
  var selectedItem: PhotosPickerItem?

  init(
    editPhotoUseCase: EditPhotoUseCase,
    savePhotoUseCase: SavePhotoUseCase
  ) {
    self.editPhotoUseCase = editPhotoUseCase
    self.savePhotoUseCase = savePhotoUseCase
  }

  func setPhoto(image: UIImage) {
    self.photo = .init(image: image)
  }

  func applyFilter() {
    guard let photo = photo else { return }
    do {
      self.photo = try editPhotoUseCase.execute(photo: photo)
      error = nil
    } catch let err as PhotoError {
      error = err
    } catch {
      self.error = PhotoError.unknown
    }
  }

  func savePhoto() {
    guard let photo = photo else { return }
    isLoading = true
    error = nil
    saveMessage = nil
    savePhotoUseCase.execute(photo: photo) { [weak self] result in
      DispatchQueue.main.async {
        self?.isLoading = false
        switch result {
        case .success:
          self?.saveMessage = "Saved to Photos!"
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self?.saveMessage = nil
          }
        case .failure(let err):
          self?.error = err
        }
      }
    }
  }
}
