# PhotoEditorApp

PhotoEditorApp is a minimal educational iOS application demonstrating the core principles of [TMArchitecture](https://github.com/Rayllienstery/TMArchitecture) — a clean, scalable architecture for SwiftUI projects.

---

## About

- **Purpose:** This project serves as a simple, practical example of how to implement TMArchitecture in a real iOS app.
- **Architecture:** Strict separation of Presentation, Domain, Data, and Application layers, following Clean Architecture and MVVM patterns.
- **Technologies:** Swift 5.10+, SwiftUI (with Observation framework), Clean Architecture, MVVM.

---

## Project Structure

```
PhotoEditorApp/
  ├── Application/         // App entry point, DI
  ├── Data/                // Repositories, data sources
  ├── Domain/              // UseCases, Entities, Errors
  ├── Presentation/        // SwiftUI Views, ViewModels
  ├── Resources/           // Assets, localization
```

---

## Key Features

- **Entities:** Domain models (e.g., `PhotoEntry`)
- **UseCases:** Business logic (`EditPhotoUseCase`, `SavePhotoUseCase`)
- **Repositories:** Data access abstraction (`PhotoRepository`)
- **ViewModels:** State and UI logic (`PhotoEditorViewModel`)
- **Views:** SwiftUI interface (`PhotoEditorView`)
- **Errors:** Explicit domain error types (`PhotoError`)

---

## Testing

> **Note:**  
> This project does **not** include unit or UI tests.  
> It is intentionally minimal, focusing on architectural structure and clarity.

---

## References

- **TMArchitecture:**  
  [https://github.com/Rayllienstery/TMArchitecture](https://github.com/Rayllienstery/TMArchitecture)
- **Clean Architecture:**  
  [Uncle Bob's Clean Architecture](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html)
- **SwiftUI Documentation:**  
  [Apple Developer SwiftUI](https://developer.apple.com/documentation/swiftui)

---

## License

MIT License

---

**This project is for educational purposes only.  
Feel free to use, study, and extend it as a starting point for your own TMArchitecture-based apps!**
