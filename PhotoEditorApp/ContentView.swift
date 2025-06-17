//
//  ContentView.swift
//  PhotoEditorApp
//
//  Created by Kostiantyn Kolosov on 17.06.2025.
//

import Combine
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

// MARK: - Application Layer

@main
struct PhotoEditorApp: App {
  @Bindable private var errorService = ErrorApplicationService()

  var body: some Scene {
    WindowGroup {
      PhotoEditorView(
        model: PhotoEditorViewModel(
          selectPhotoUseCase: SelectPhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl()),
          editPhotoUseCase: EditPhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl()),
          savePhotoUseCase: SavePhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl())
        )
      )
      .alert(isPresented: .init(get: { errorService.userMessage != nil }, set: { _ in errorService.userMessage = nil })) {
        Alert(
          title: Text("Error"),
          message: Text("\(errorService.userMessage ?? "")"), 
          dismissButton: .default(Text("Ok"))
        )
      }
    }
  }
}

@Observable
final class ErrorApplicationService {
  var userMessage: String?
  private var cancellable: AnyCancellable?
  private let errorMapper = ErrorMapper()

  init() {
    cancellable = NotificationCenter.default.publisher(for: .error)
      .sink { [weak self] notification in
        if let error = notification.userInfo?["error"] as? Error {
          self?.userMessage = self?.errorMapper.map(error: error)
        }
      }
  }
}

struct ErrorMapper {
  func map(error: Error?) -> String? {
    switch error {
    case let err as PhotoError:
      return err.errorDescription
    default:
      return nil
    }
  }
}

// MARK: - Presentation Layer

struct PhotoEditorView: View {
  @State private var selectedItem: PhotosPickerItem?
  @State private var isLoading: Bool = false
  let model: PhotoEditorViewModel

  var body: some View {
    VStack(spacing: 16) {
      if let photo = model.photo {
        Image(uiImage: photo.image)
          .resizable()
          .scaledToFit()
          .frame(height: 200)
          .accessibilityLabel("Selected photo")
      } else {
        Text("No photo selected")
          .accessibilityLabel("No photo selected")
      }

      VStack(spacing: 12) {
        PhotosPicker(
          selection: $selectedItem,
          matching: .images,
          photoLibrary: .shared()
        ) {
          Text("Select Photo")
        }
        .accessibilityLabel("Select Photo")
        .disabled(isLoading)

        Button("Apply Mono Filter") {
          model.applyFilter()
        }
        .disabled(model.photo == nil)
        .accessibilityLabel("Apply Mono Filter")

        Button("Save to Photos") {
          model.savePhoto()
        }
        .disabled(model.photo == nil || model.isSaving)
        .accessibilityLabel("Save to Photos")
      }

      if isLoading || model.isSaving {
        ProgressView()
      }

      if let error = model.error {
        Text(error.localizedDescription)
          .foregroundColor(.red)
          .accessibilityLabel("Error: \(error.localizedDescription)")
      }

      if let saveMessage = model.saveMessage {
        Text(saveMessage)
          .foregroundColor(.green)
          .accessibilityLabel(saveMessage)
      }
    }
    .padding()
    .onChange(of: selectedItem) { _, newItem in
      guard let item = newItem else { return }
      isLoading = true
      Task {
        if let data = try? await item.loadTransferable(type: Data.self),
          let image = UIImage(data: data)
        {
          await MainActor.run {
            model.setPhoto(image: image)
            isLoading = false
          }
        } else {
          await MainActor.run {
            model.error = PhotoError.invalidFormat
            isLoading = false
          }
        }
      }
    }
  }
}

@Observable
final class PhotoEditorViewModel {
  private let selectPhotoUseCase: SelectPhotoUseCase
  private let editPhotoUseCase: EditPhotoUseCase
  private let savePhotoUseCase: SavePhotoUseCase

  var photo: PhotoEntry?
  var error: PhotoError?
  var saveMessage: String?
  var isSaving: Bool = false

  init(
    selectPhotoUseCase: SelectPhotoUseCase, editPhotoUseCase: EditPhotoUseCase,
    savePhotoUseCase: SavePhotoUseCase
  ) {
    self.selectPhotoUseCase = selectPhotoUseCase
    self.editPhotoUseCase = editPhotoUseCase
    self.savePhotoUseCase = savePhotoUseCase
  }

  // Set photo from UIImage
  func setPhoto(image: UIImage) {
    do {
      photo = try selectPhotoUseCase.execute(with: image)
      error = nil
    } catch let err as PhotoError {
      error = err
    } catch {
      self.error = PhotoError.unknown
    }
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
    isSaving = true
    error = nil
    saveMessage = nil
    savePhotoUseCase.execute(photo: photo) { [weak self] result in
      DispatchQueue.main.async {
        self?.isSaving = false
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

// MARK: - Domain Layer

struct PhotoEntry {
  let image: UIImage
}

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

protocol SelectPhotoUseCase {
  func execute(with image: UIImage) throws -> PhotoEntry
}

protocol EditPhotoUseCase {
  func execute(photo: PhotoEntry) throws -> PhotoEntry
}

protocol SavePhotoUseCase {
  func execute(photo: PhotoEntry, completion: @escaping (Result<Void, PhotoError>) -> Void)
}

final class SelectPhotoUseCaseImpl: SelectPhotoUseCase {
  private let photoRepository: PhotoRepository

  init(photoRepository: PhotoRepository) {
    self.photoRepository = photoRepository
  }

  func execute(with image: UIImage) throws -> PhotoEntry {
    let entry = PhotoEntry(image: image)
    return entry
  }
}

final class EditPhotoUseCaseImpl: EditPhotoUseCase {
  private let photoRepository: PhotoRepository
  private let context = CIContext()

  init(photoRepository: PhotoRepository) {
    self.photoRepository = photoRepository
  }

  func execute(photo: PhotoEntry) throws -> PhotoEntry {
    guard let filtered = applyMonoFilter(to: photo.image) else {
      throw PhotoError.invalidFormat
    }
    let entry = PhotoEntry(image: filtered)
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

final class SavePhotoUseCaseImpl: SavePhotoUseCase {
  private let photoRepository: PhotoRepository

  init(photoRepository: PhotoRepository) {
    self.photoRepository = photoRepository
  }

  func execute(photo: PhotoEntry, completion: @escaping (Result<Void, PhotoError>) -> Void) {
    photoRepository.saveToLibrary(photo: photo, completion: completion)
  }
}

// MARK: - Data Layer

protocol PhotoRepository {
  func saveToLibrary(photo: PhotoEntry, completion: @escaping (Result<Void, PhotoError>) -> Void)
}

final class PhotoRepositoryImpl: PhotoRepository {
  func saveToLibrary(photo: PhotoEntry, completion: @escaping (Result<Void, PhotoError>) -> Void) {
    UIImageWriteToSavedPhotosAlbum(
      photo.image, self,
      #selector(saveImageCompletionHandler(_:didFinishSavingWithError:contextInfo:)), nil)
  }

  @objc private func saveImageCompletionHandler(
    _ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?
  ) {
    if let error {
      NotificationCenter.default.post(name: .error, object: nil, userInfo: ["error": error])
    }
  }
}

extension Notification.Name {
  static let error = Notification.Name("error")
}

#Preview {
  PhotoEditorView(
    model: PhotoEditorViewModel(
      selectPhotoUseCase: SelectPhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl()),
      editPhotoUseCase: EditPhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl()),
      savePhotoUseCase: SavePhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl())
    )
  )
}
