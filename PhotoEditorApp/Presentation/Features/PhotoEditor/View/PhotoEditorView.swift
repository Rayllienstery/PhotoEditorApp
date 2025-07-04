import PhotosUI
import SwiftUI

// MARK: - Presentation Layer

struct PhotoEditorView<ViewModel: PhotoEditorViewModel>: View {
  @Bindable var model: ViewModel

  var body: some View {
    VStack(spacing: 16) {
      if let photo = model.photo {
        Image(uiImage: photo.image)
          .resizable()
          .scaledToFit()
          .frame(height: 200)
      } else {
        Text("No photo selected")
      }

      VStack(spacing: 12) {
        PhotosPicker(
          selection: $model.selectedItem,
          matching: .images,
          photoLibrary: .shared()
        ) {
          Text("Select Photo")
        }
        .disabled(model.isLoading)

        Button("Apply Mono Filter") {
          model.applyFilter()
        }
        .disabled(model.photo == nil)

        Button("Save to Photos") {
          model.savePhoto()
        }
        .disabled(model.photo == nil || model.isLoading)
      }

      if model.isLoading {
        ProgressView()
      }

      if let error = model.error {
        Text(error.localizedDescription)
          .foregroundColor(.red)
      }

      if let saveMessage = model.saveMessage {
        Text(saveMessage)
          .foregroundColor(.green)
      }
    }
    .padding()
    .onChange(of: model.selectedItem) { _, newItem in
      guard let item = newItem else { return }
      model.isLoading = true
      Task {
        if let data = try? await item.loadTransferable(type: Data.self),
          let image = UIImage(data: data)
        {
          await MainActor.run {
            model.setPhoto(image: image)
            model.isLoading = false
          }
        } else {
          await MainActor.run {
            model.error = PhotoError.invalidFormat
            model.isLoading = false
          }
        }
      }
    }
  }
}

#Preview {
  PhotoEditorView(
    model: PhotoEditorViewModelImpl(
      editPhotoUseCase: EditPhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl()),
      savePhotoUseCase: SavePhotoUseCaseImpl(photoRepository: PhotoRepositoryImpl())
    )
  )
}
