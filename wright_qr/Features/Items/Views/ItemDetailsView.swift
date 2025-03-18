//
//  ItemDetailsView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct ItemDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var item: Item
    @State private var showingEditForm = false
    @State private var isLoading = false
    @State private var shouldRefresh = false
    @State private var showDeleteAlert = false
    @State private var navigateToHistory = false
    
    @State private var showFullScreenImage = false
    
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    let apiService = ApiService()
    
    init(item: Item) {
        _item = State(initialValue: item)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    private let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM/dd/yyyy"
        return formatter
    }()
    
    private func formatDate(_ dateString: String) -> String {
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        return displayFormatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        HeaderView(description: item.itemDescription)
                        
                        // Reemplaza el bloque actual de visualización de imagen con este código
                        if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                // Encabezado de sección similar a los otros componentes
                                HStack(spacing: 8) {
                                    Image(systemName: "photo.fill")
                                        .foregroundColor(mainColor)
                                    Text("Item Image")
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                                
                                // Contenedor de imagen mejorado
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(uiColor: .secondarySystemBackground))
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                    
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            VStack(spacing: 12) {
                                                ProgressView()
                                                    .scaleEffect(1.5)
                                                    .tint(mainColor)
                                                Text("Loading image...")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 250)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .padding(8)
                                                .transition(.opacity.combined(with: .scale))
                                                .overlay(
                                                    ZStack {
                                                        // Botón para ampliar la imagen
                                                        VStack {
                                                            Spacer()
                                                            HStack {
                                                                Spacer()
                                                                Button(action: {
                                                                    showFullScreenImage = true
                                                                }) {
                                                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                                        .font(.system(size: 14, weight: .bold))
                                                                        .foregroundColor(.white)
                                                                        .padding(8)
                                                                        .background(mainColor.opacity(0.8))
                                                                        .clipShape(Circle())
                                                                }
                                                                .padding(16)
                                                            }
                                                        }
                                                        
                                                        // Información opcional sobre la imagen en la parte inferior
                                                        VStack {
                                                            Spacer()
                                                            HStack {
                                                                VStack(alignment: .leading) {
                                                                    Text(item.itemDescription)
                                                                        .font(.caption)
                                                                        .fontWeight(.medium)
                                                                        .foregroundColor(.white)
                                                                        .lineLimit(1)
                                                                    
                                                                    if !item.brand.isEmpty {
                                                                        Text(item.brand)
                                                                            .font(.caption2)
                                                                            .foregroundColor(.white.opacity(0.8))
                                                                    }
                                                                }
                                                                .padding(10)
                                                                .background(
                                                                    Rectangle()
                                                                        .fill(Color.black.opacity(0.6))
                                                                        .cornerRadius(10, corners: [.topRight, .bottomRight])
                                                                )
                                                                .padding(.bottom, 8)
                                                                
                                                                Spacer()
                                                            }
                                                        }
                                                    }
                                                )
                                            
                                        case .failure:
                                            VStack(spacing: 16) {
                                                Image(systemName: "photo.slash")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.secondary)
                                                
                                                Text("Failed to load image")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                
                                                Button(action: {
                                                    // Acción para reintentar cargar la imagen
                                                }) {
                                                    HStack {
                                                        Image(systemName: "arrow.clockwise")
                                                        Text("Retry")
                                                    }
                                                    .font(.caption)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(Color(uiColor: .systemBackground))
                                                    .cornerRadius(8)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .stroke(mainColor, lineWidth: 1)
                                                    )
                                                }
                                            }
                                            .frame(height: 250)
                                            
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .animation(.easeInOut(duration: 0.3), value: imageUrl)
                                }
                                .frame(height: 266)
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 10)
                        }
                        
                        VStack(spacing: 20) {
                            DetailSection(
                                title: "Item Information",
                                icon: "doc.text.fill",
                                items: [
                                    DetailItem(icon: "text.alignleft", title: "Description", value: item.itemDescription),
                                    DetailItem(icon: "tag", title: "Model Name", value: item.modelName),
                                    DetailItem(icon: "building.2", title: "Brand", value: item.brand),
                                    DetailItem(icon: "text.bubble", title: "Comment", value: item.comment)
                                ]
                            )
                            
                            DetailSection(
                                title: "Specifications",
                                icon: "gearshape.fill",
                                items: [
                                    DetailItem(icon: "number", title: "Serial Number", value: item.serialNumber),
                                    DetailItem(icon: "sparkles", title: "Condition", value: item.conditionO),
                                    DetailItem(
                                        icon: item.inspection == 1 ? "checkmark.seal" :
                                            (item.inspection == 0 ? "xmark.seal" : "questionmark.circle.dashed"),
                                        title: "Inspection Status",
                                        value: item.inspection == 1 ? "Passed" :
                                            (item.inspection == 0 ? "Failed" : "N/A"),
                                        iconColor: item.inspection == 1 ? .green :
                                            (item.inspection == 0 ? .red : .gray),
                                        valueColor: item.inspection == 1 ? .green :
                                            (item.inspection == 0 ? .red : .gray)
                                    )
                                ]
                            )
                            
                            DetailSection(
                                title: "Inspection Details",
                                icon: "clipboard.fill",
                                items: [
                                    DetailItem(icon: "person.fill", title: "Inspector", value: item.inspectorName),
                                    DetailItem(icon: "calendar", title: "Inspection Date", value: formatDate(item.inspectionDate)),
                                    DetailItem(icon: "calendar.badge.clock", title: "Follow-up", value: formatDate(item.inspectionDate1)),
                                    DetailItem(icon: "calendar.badge.exclamationmark", title: "Expiration", value: formatDate(item.expirationDate))
                                ]
                            )
                            
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Note: For detailed inspection records and history, please check the inspection history.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    navigateToHistory = true
                                }) {
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.system(size: 16))
                                        Text("View Inspection History")
                                            .font(.system(size: 15, weight: .medium))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                    )
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.top, 4)
                            .padding(.bottom, 12)
                            
                            DetailSection(
                                title: "Additional Info",
                                icon: "info.circle.fill",
                                items: [
                                    DetailItem(icon: "bag", title: "Bag ID", value: item.bagID)
                                ]
                            )
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ActionButtonn(
                                title: "Edit Item",
                                icon: "square.and.pencil",
                                color: mainColor
                            ) {
                                showingEditForm = true
                            }
                            
                            ActionButtonn(
                                title: "Delete Item",
                                icon: "trash.fill",
                                color: .red
                            ) {
                                showDeleteAlert = true
                            }
                        }
                        .padding()
                    }
                }
                
                if isLoading {
                    LoadingView(message: "Updating item...", mainColor: mainColor)
                }
            }
            .background(
                NavigationLink(
                    destination: InspectionHistoryView(item: item),
                    isActive: $navigateToHistory,
                    label: { EmptyView() }
                )
            )
            .alert("Delete Item", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteItem()
                }
            } message: {
                Text("Are you sure you want to delete this item? This action cannot be undone.")
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingEditForm) {
                EditItemFormView(item: item) { updatedItem in
                    self.shouldRefresh = true
                    showingEditForm = false
                }
            }
            .onChange(of: shouldRefresh) { oldValue, newValue in
                if newValue {
                    loadItemDetails(itemId: item.id)
                    shouldRefresh = false
                }
            }
            .sheet(isPresented: $showFullScreenImage) {
                if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        
                        VStack {
                            // Botón de cierre
                            HStack {
                                Spacer()
                                Button(action: {
                                    showFullScreenImage = false
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                                .padding()
                            }
                            
                            Spacer()
                            
                            // Imagen
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .tint(.white)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    
                                case .failure:
                                    VStack(spacing: 16) {
                                        Image(systemName: "photo.slash")
                                            .font(.system(size: 60))
                                            .foregroundColor(.white)
                                        Text("Failed to load image")
                                            .foregroundColor(.white)
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .padding()
                            
                            Spacer()
                            
                            // Información de la imagen
                            Text(item.itemDescription)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                            
                            if !item.brand.isEmpty {
                                Text(item.brand)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.bottom, 30)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func deleteItem() {
        isLoading = true
        apiService.delete(String(item.id), direction: "items") { success in
            DispatchQueue.main.async {
                isLoading = false
                if success {
                    dismiss()
                }
            }
        }
    }
    
    
    
    private func loadItemDetails(itemId: Int) {
        isLoading = true
        apiService.getItemById(itemId) { result in
            if let updatedItem = result {
                withAnimation {
                    self.item = updatedItem
                }
            } else {
            }
            self.isLoading = false
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct HeaderView: View {
    let description: String
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(mainColor.opacity(0.1))
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "figure.climbing.circle")
                        .font(.system(size: 36))
                        .foregroundColor(mainColor)
                )
            
            Text(description)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct DetailSection: View {
    let title: String
    let icon: String
    let items: [DetailItem]
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(mainColor)
                Text(title)
                    .font(.headline)
            }
            
            VStack(spacing: 12) {
                ForEach(items, id: \.title) { item in
                    EnhancedDetailRow(item: item)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

struct DetailItem {
    let icon: String
    let title: String
    let value: String
    var iconColor: Color? = nil
    var valueColor: Color? = nil
}

struct EnhancedDetailRow: View {
    let item: DetailItem
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .foregroundColor(item.iconColor ?? mainColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(item.value.isEmpty ? "N/A" : item.value)
                    .font(.body)
                    .foregroundColor(item.valueColor ?? .primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
    }
}

struct ActionButtonn: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

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
                                    
                                    // Botones para cámara y galería (igual que en NewItemFormView)
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
        
        print("Iniciando subida de imagen...") // Para debug
        
        apiService.uploadImage(imageData) { result in
            switch result {
            case .success(let url):
                print("Imagen subida exitosamente: \(url)") // Para debug
                completion(url)
            case .failure(let error):
                print("Error subiendo imagen: \(error)")
                completion(nil)
            }
        }
    }
    
    private func completeItemUpdate() {
        print("Completando actualización con imageUrl: \(imageUrl ?? "nil")") // Para debug
        
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
            imageUrl: imageUrl // Asegúrate de que este valor no sea nil
        )
        
        apiService.updateItem(updatedItem) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    print("Item actualizado exitosamente") // Para debug
                    self.onUpdate(updatedItem)
                    self.dismiss()
                } else {
                    print("Error al actualizar el Item")
                }
            }
        }
    }
}
