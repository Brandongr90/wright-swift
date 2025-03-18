//
//  NewItemFormView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct NewItemFormView: View {
    @State private var toasts: [Toast] = []
    
    @Environment(\.dismiss) private var dismiss
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    @State private var itemDescription: String = ""
    @State private var modelName: String = ""
    @State private var brand: String = ""
    @State private var comment: String = ""
    @State private var serialNumber: String = ""
    @State private var conditionO: String = ""
    @State private var inspection: Int = 0
    @State private var inspectionDate: Date = Date()
    @State private var inspectorName: String = ""
    @State private var inspectionDate1: Date = Date()
    @State private var isLoading = false
    
    // Upload Photos
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isShowingCamera = false
    @State private var imageUrl: String?
    @State private var isUploading = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // Dropdown state variables
    @State private var isInspectorDropdownShown = false
    // Static list of inspectors
    private let inspectors = ["Saul Villa"]
    
    // Expiration date variables
    @State private var expirationDate: String = ""
    @State private var isExpirationNA: Bool = false
    @State private var expirationDateValue: Date = Date()
    
    @FocusState private var focusedField: Field?
    
    var bag: Bag
    var onSave: (Item) -> Void
    let apiService = ApiService()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    enum Field {
        case description, model, brand, comment, serial, condition, inspector
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Encabezado
                        headerView
                        
                        VStack(spacing: 24) {
                            // Secciones del formulario usando los componentes
                            ItemDetailsSection(
                                itemDescription: $itemDescription,
                                modelName: $modelName,
                                brand: $brand,
                                comment: $comment,
                                focusedField: _focusedField,
                                mainColor: mainColor
                            )
                            
                            SpecificationsSection(
                                serialNumber: $serialNumber,
                                conditionO: $conditionO,
                                inspection: $inspection,
                                focusedField: _focusedField,
                                mainColor: mainColor
                            )
                            
                            InspectionDetailsSection(
                                inspectorName: $inspectorName,
                                inspectionDate: $inspectionDate,
                                inspectionDate1: $inspectionDate1,
                                isExpirationNA: $isExpirationNA,
                                expirationDateValue: $expirationDateValue,
                                isInspectorDropdownShown: $isInspectorDropdownShown,
                                focusedField: _focusedField,
                                inspectors: inspectors,
                                mainColor: mainColor
                            )
                            
                            ItemImageSection(
                                selectedImage: $selectedImage,
                                isShowingCamera: $isShowingCamera,
                                isImagePickerPresented: $isImagePickerPresented,
                                imageUrl: $imageUrl,
                                mainColor: mainColor
                            )
                        }
                        .padding(.horizontal)
                        
                        // Botones
                        buttonSection
                    }
                }
                .sheet(isPresented: $isShowingCamera) {
                    cameraPicker
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    photoPicker
                }
                .onTapGesture {
                    // Close dropdown when tapping outside
                    isInspectorDropdownShown = false
                }
                
                if isLoading {
                    LoadingView(message: "Processing...", mainColor: mainColor)
                }
            }
            .navigationBarHidden(true)
            .alert("Error al cargar imagen", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .interactiveToast($toasts)
        }
    }
    
    // Vistas computadas adicionales
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.climbing")
                .font(.system(size: 60))
                .foregroundColor(mainColor)
            
            Text("Add New Item")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Fill in the details for your new item")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var buttonSection: some View {
        VStack(spacing: 16) {
            Button(action: addItem) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    Text("Save Item")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(mainColor)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: mainColor.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            
            Button(action: { dismiss() }) {
                Text("Cancel")
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    private var cameraPicker: some View {
        ZStack {
            CameraView(image: $selectedImage, isPresented: $isShowingCamera)
                .ignoresSafeArea()
            
            if isUploading {
                LoadingView(message: "Uploading image...", mainColor: mainColor)
            }
        }
        .onDisappear {
            if let image = selectedImage {
                uploadImage(image) { _ in
                    // No necesitamos hacer nada aquí
                }
            }
        }
    }
    
    private var photoPicker: some View {
        ZStack {
            PhotoPicker(selectedImage: $selectedImage, isPresented: $isImagePickerPresented)
            
            if isUploading {
                LoadingView(message: "Uploading image...", mainColor: mainColor)
            }
        }
        .onDisappear {
            if let image = selectedImage {
                uploadImage(image) { _ in
                    // No necesitamos hacer nada aquí
                }
            }
        }
    }
    
    func addItem() {
        let expDateString = isExpirationNA ? "N/A" : dateFormatter.string(from: expirationDateValue)
        
        // Si hay una imagen seleccionada pero aún no se ha subido
        if selectedImage != nil && imageUrl == nil {
            isLoading = true
            uploadImage(selectedImage!) { uploadedUrl in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let url = uploadedUrl {
                        self.imageUrl = url
                        // Ahora que tenemos la URL, continuamos con la creación del ítem
                        self.proceedWithItemCreation(expDateString)
                    } else {
                        // Error al subir la imagen
                        self.errorMessage = "No se pudo cargar la imagen. Por favor intenta de nuevo."
                        self.showErrorAlert = true
                    }
                }
            }
        } else {
            // No hay imagen nueva o ya tenemos la URL
            proceedWithItemCreation(expDateString)
        }
    }
    
    private func uploadImage(_ image: UIImage) {
        uploadImage(image) { _ in }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        // Asegurarse de que la imagen no sea demasiado grande
        let maxDimension: CGFloat = 1200
        let originalSize = image.size
        var newSize = originalSize
        
        if originalSize.width > maxDimension || originalSize.height > maxDimension {
            let ratio = originalSize.width / originalSize.height
            if ratio > 1 {
                newSize = CGSize(width: maxDimension, height: maxDimension / ratio)
            } else {
                newSize = CGSize(width: maxDimension * ratio, height: maxDimension)
            }
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        // Intentar diferentes niveles de compresión
        var compressionQuality: CGFloat = 0.8
        var imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
        
        while imageData == nil && compressionQuality > 0.1 {
            compressionQuality -= 0.1
            imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
        }
        
        guard let finalImageData = imageData else {
            print("Error: No se pudo comprimir la imagen")
            completion(nil)
            return
        }
        
        print("Iniciando subida de imagen. Tamaño: \(finalImageData.count / 1024) KB")
        
        apiService.uploadImage(finalImageData) { result in
            switch result {
            case .success(let url):
                print("Imagen subida exitosamente: \(url)")
                completion(url)
            case .failure(let error):
                print("Error subiendo imagen: \(error)")
                completion(nil)
            }
        }
    }
    
    private func proceedWithItemCreation(_ expDateString: String) {
        let newItem = Item(
            id: 0,
            itemDescription: itemDescription,
            modelName: modelName,
            brand: brand,
            comment: comment,
            serialNumber: serialNumber,
            conditionO: conditionO,
            inspection: inspection,
            inspectionDate: dateFormatter.string(from: inspectionDate),
            inspectorName: inspectorName,
            inspectionDate1: dateFormatter.string(from: inspectionDate1),
            expirationDate: expDateString,
            bagID: String(bag.id),
            imageUrl: imageUrl
        )
        
        apiService.postItem(newItem) { success in
            if success {
                withAnimation(.bouncy) {
                    let toast = Toast { id in
                        SuccessToastView(id)
                    }
                    self.toasts.append(toast)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        if let index = self.toasts.firstIndex(where: { $0.id == toast.id }) {
                            withAnimation(.bouncy) {
                                self.toasts.remove(at: index)
                            }
                        }
                    }
                }
                onSave(newItem)
                dismiss()
            } else {
                withAnimation(.bouncy) {
                    let toast = Toast { id in
                        ErrorToastView(id)
                    }
                    self.toasts.append(toast)
                }
            }
        }
    }
    
    @ViewBuilder
    func SuccessToastView(_ id: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text("Item creado exitosamente")
                .font(.callout)
            
            Spacer(minLength: 0)
            
            Button {
                $toasts.delete(id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
            }
        }
        .foregroundStyle(Color.primary)
        .padding(.vertical, 12)
        .padding(.leading, 15)
        .padding(.trailing, 10)
        .background {
            Capsule()
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
        }
        .padding(.horizontal, 15)
    }
    
    @ViewBuilder
    func ErrorToastView(_ id: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
            
            Text("Error al crear el item")
                .font(.callout)
            
            Spacer(minLength: 0)
            
            Button {
                $toasts.delete(id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
            }
        }
        .foregroundStyle(Color.primary)
        .padding(.vertical, 12)
        .padding(.leading, 15)
        .padding(.trailing, 10)
        .background {
            Capsule()
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 1, y: 3)
        }
        .padding(.horizontal, 15)
    }
}

// Vista para la sección de detalles del ítem
struct ItemDetailsSection: View {
    @Binding var itemDescription: String
    @Binding var modelName: String
    @Binding var brand: String
    @Binding var comment: String
    @FocusState var focusedField: NewItemFormView.Field?
    let mainColor: Color
    
    var body: some View {
        FormSection(title: "Item Details") {
            CustomTextField(
                title: "Item Name",
                text: $itemDescription,
                icon: "textformat.characters",
                focused: focusedField == .description
            )
            .focused($focusedField, equals: .description)
            
            CustomTextField(
                title: "Model Name",
                text: $modelName,
                icon: "tag",
                focused: focusedField == .model
            )
            .focused($focusedField, equals: .model)
            
            CustomTextField(
                title: "Brand",
                text: $brand,
                icon: "shield",
                focused: focusedField == .brand
            )
            .focused($focusedField, equals: .brand)
            
            CustomTextField(
                title: "Comment",
                text: $comment,
                icon: "text.bubble",
                focused: focusedField == .comment
            )
            .focused($focusedField, equals: .comment)
        }
    }
}

// Vista para la sección de especificaciones
struct SpecificationsSection: View {
    @Binding var serialNumber: String
    @Binding var conditionO: String
    @Binding var inspection: Int
    @FocusState var focusedField: NewItemFormView.Field?
    let mainColor: Color
    
    var body: some View {
        FormSection(title: "Specifications") {
            CustomTextField(
                title: "Serial Number",
                text: $serialNumber,
                icon: "number",
                focused: focusedField == .serial
            )
            .focused($focusedField, equals: .serial)
            
            CustomTextField(
                title: "Condition",
                text: $conditionO,
                icon: "sparkles",
                focused: focusedField == .condition
            )
            .focused($focusedField, equals: .condition)
            
            InspectionStatusSelector(status: $inspection, mainColor: mainColor)
        }
    }
}

// Vista para la sección de imagen
struct ItemImageSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var isShowingCamera: Bool
    @Binding var isImagePickerPresented: Bool
    @Binding var imageUrl: String?
    let mainColor: Color
    
    var body: some View {
        FormSection(title: "Item Image") {
            VStack(spacing: 16) {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            Button(action: {
                                self.selectedImage = nil
                                self.imageUrl = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .background(Color.black.opacity(0.7))
                                    .clipShape(Circle())
                            }
                                .padding(8),
                            alignment: .topTrailing
                        )
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: .secondarySystemBackground))
                            .frame(height: 200)
                        
                        VStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No Image Selected")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        isShowingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text("Take Photo")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(mainColor)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        isImagePickerPresented = true
                    }) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Choose Photo")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(mainColor)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

// Vista para la sección de inspección
struct InspectionDetailsSection: View {
    @Binding var inspectorName: String
    @Binding var inspectionDate: Date
    @Binding var inspectionDate1: Date
    @Binding var isExpirationNA: Bool
    @Binding var expirationDateValue: Date
    @Binding var isInspectorDropdownShown: Bool
    @FocusState var focusedField: NewItemFormView.Field?
    let inspectors: [String]
    let mainColor: Color
    
    var body: some View {
        FormSection(title: "Inspection Details") {
            InspectorDropdown(
                inspectorName: $inspectorName,
                isDropdownShown: $isInspectorDropdownShown,
                inspectors: inspectors,
                focused: focusedField == .inspector,
                mainColor: mainColor
            )
            .focused($focusedField, equals: .inspector)
            
            CustomDatePickerWithFormat(
                title: "Inspection Date",
                date: $inspectionDate,
                icon: "calendar"
            )
            
            CustomDatePickerWithFormat(
                title: "Follow-up Inspection",
                date: $inspectionDate1,
                icon: "calendar.badge.clock"
            )
            
            ExpirationDateView(
                isExpirationNA: $isExpirationNA,
                expirationDateValue: $expirationDateValue,
                mainColor: mainColor
            )
        }
    }
}

// Vista para la sección de fecha de expiración
struct ExpirationDateView: View {
    @Binding var isExpirationNA: Bool
    @Binding var expirationDateValue: Date
    let mainColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Expiration Date")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                if isExpirationNA {
                    HStack {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .foregroundColor(mainColor)
                        Text("No Expiration Date (N/A)")
                            .foregroundColor(.primary)
                        Spacer()
                        Button(action: {
                            isExpirationNA = false
                        }) {
                            Text("Select Date")
                                .font(.footnote)
                                .foregroundColor(mainColor)
                        }
                    }
                } else {
                    HStack {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .foregroundColor(mainColor)
                        
                        DatePicker(
                            "",
                            selection: $expirationDateValue,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: {
                            isExpirationNA = true
                        }) {
                            Text("Set N/A")
                                .font(.footnote)
                                .foregroundColor(mainColor)
                        }
                    }
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}

struct FormSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                content
            }
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let focused: Bool
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(mainColor)
                TextField(title, text: $text)
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focused ? mainColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct CustomDatePickerWithFormat: View {
    let title: String
    @Binding var date: Date
    let icon: String
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(mainColor)
                
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .accentColor(mainColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transformEffect(.init(translationX: -8, y: 0))
                
                Text(dateFormatter.string(from: date))
                    .foregroundColor(.primary)
                    .font(.body)
                    .frame(minWidth: 100, alignment: .trailing)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}
