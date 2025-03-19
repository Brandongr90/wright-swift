//
//  EditItemFormView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez
//

import SwiftUI

struct EditItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    let apiService = ApiService()
    
    let item: Item
    var onUpdate: (Item) -> Void
    
    @State private var itemDescription: String
    @State private var modelName: String
    @State private var brand: String
    @State private var comment: String
    @State private var serialNumber: String
    @State private var conditionO: String
    @State private var inspection: Int
    @State private var inspectionDate: Date
    @State private var inspectorName: String
    @State private var inspectionDate1: Date
    @State private var expirationDate: Date
    @State private var isLoading = false
    
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isShowingCamera = false
    @State private var imageUrl: String?
    @State private var isUploading = false
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case description, model, brand, comment, serial, condition, inspector
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    init(item: Item, onUpdate: @escaping (Item) -> Void) {
        self.item = item
        self.onUpdate = onUpdate
        
        _itemDescription = State(initialValue: item.itemDescription)
        _modelName = State(initialValue: item.modelName)
        _brand = State(initialValue: item.brand)
        _comment = State(initialValue: item.comment)
        _serialNumber = State(initialValue: item.serialNumber)
        _conditionO = State(initialValue: item.conditionO)
        _inspection = State(initialValue: item.inspection)
        _inspectorName = State(initialValue: item.inspectorName)
        
        _imageUrl = State(initialValue: item.imageUrl)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let defaultDate = Date()
        
        _inspectionDate = State(initialValue: dateFormatter.date(from: item.inspectionDate) ?? defaultDate)
        _inspectionDate1 = State(initialValue: dateFormatter.date(from: item.inspectionDate1) ?? defaultDate)
        _expirationDate = State(initialValue: dateFormatter.date(from: item.expirationDate) ?? defaultDate)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        VStack(spacing: 12) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 60))
                                .foregroundColor(mainColor)
                            
                            Text("Edit Item")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Update the details of your item")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 24) {
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
                            
                            FormSection(title: "Inspection Details") {
                                CustomTextField(
                                    title: "Inspector Name",
                                    text: $inspectorName,
                                    icon: "person.fill",
                                    focused: focusedField == .inspector
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
                                
                                CustomDatePickerWithFormat(
                                    title: "Expiration Date",
                                    date: $expirationDate,
                                    icon: "calendar.badge.exclamationmark"
                                )
                            }
                            
                            FormSection(title: "Item Image") {
                                VStack(spacing: 16) {
                                    if let selectedImage = selectedImage {
                                        // Mostrar imagen recién seleccionada
                                        Image(uiImage: selectedImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                Button(action: {
                                                    self.selectedImage = nil
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
                                    } else if let imageUrl = imageUrl, !imageUrl.isEmpty {
                                        // Mostrar imagen existente
                                        AsyncImage(url: URL(string: imageUrl)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .frame(height: 200)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: 200)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    .overlay(
                                                        Button(action: {
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
                                            case .failure:
                                                // Mostrar error
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color(uiColor: .secondarySystemBackground))
                                                        .frame(height: 200)
                                                    
                                                    VStack(spacing: 12) {
                                                        Image(systemName: "photo.slash")
                                                            .font(.system(size: 40))
                                                            .foregroundColor(.secondary)
                                                        
                                                        Text("Failed to load image")
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        // No hay imagen
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
                                    
                                    // Botones para cámara y galería
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
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            Button(action: updateItem) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                    Text("Update Item")
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
                }
                
                if isLoading {
                    LoadingView(message: "Updating item...", mainColor: mainColor)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isImagePickerPresented) {
                PhotoPicker(selectedImage: $selectedImage, isPresented: $isImagePickerPresented)
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                CameraView(image: $selectedImage, isPresented: $isShowingCamera)
                    .ignoresSafeArea()
            }
        }
        .alert("Error, try again or check your internet conection", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func updateItem() {
        isLoading = true
        
        // Si tenemos una nueva imagen seleccionada, la subimos primero
        if let selectedImage = selectedImage {
            uploadImage(selectedImage) { uploadedUrl in
                DispatchQueue.main.async {
                    if let url = uploadedUrl {
                        self.imageUrl = url
                        self.completeItemUpdate()
                    } else {
                        // Manejo de error
                        self.isLoading = false
                        self.errorMessage = "No se pudo cargar la imagen. Por favor intenta de nuevo."
                        self.showErrorAlert = true
                    }
                }
            }
        } else {
            completeItemUpdate()
        }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        // Comprimimos la imagen para reducir el tamaño
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(nil)
            return
        }
        
        apiService.uploadImage(imageData) { result in
            switch result {
            case .success(let url):
                completion(url)
            case .failure(let error):
                print("Error subiendo imagen: \(error)")
                completion(nil)
            }
        }
    }
    
    private func completeItemUpdate() {
        let updatedItem = Item(
            id: item.id,
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
            expirationDate: dateFormatter.string(from: expirationDate),
            bagID: item.bagID,
            imageUrl: imageUrl
        )
        
        apiService.updateItem(updatedItem) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.onUpdate(updatedItem)
                    self.dismiss()
                }
            }
        }
    }
}
