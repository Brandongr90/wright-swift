//
//  ItemDetailsView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct ItemDetailsView: View {
    @State private var item: Item
    @State private var showingEditForm = false
    @State private var isLoading = false
    @State private var shouldRefresh = false
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    let apiService = ApiService()
    
    init(item: Item) {
        _item = State(initialValue: item)
    }
    
    // Formatter para convertir fechas de MySQL/ISO
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    // Formatter para mostrar fechas
    private let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM/dd/yyyy"
        return formatter
    }()
    
    // Método para formatear fecha
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
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 60))
                                .foregroundColor(mainColor)
                            
                            Text("Item Details")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(item.itemDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Details Sections
                        VStack(spacing: 24) {
                            // Item Information Section
                            FormSection(title: "Item Information") {
                                DetailRow(
                                    icon: "text.alignleft",
                                    title: "Description",
                                    value: item.itemDescription.isEmpty ? "N/A" : item.itemDescription,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "tag",
                                    title: "Model Name",
                                    value: item.modelName.isEmpty ? "N/A" : item.modelName,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "building.2",
                                    title: "Brand",
                                    value: item.brand.isEmpty ? "N/A" : item.brand,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "text.bubble",
                                    title: "Comment",
                                    value: item.comment.isEmpty ? "N/A" : item.comment,
                                    iconColor: mainColor
                                )
                            }
                            
                            // Specifications Section
                            FormSection(title: "Specifications") {
                                DetailRow(
                                    icon: "number",
                                    title: "Serial Number",
                                    value: item.serialNumber.isEmpty ? "N/A" : item.serialNumber,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "sparkles",
                                    title: "Condition",
                                    value: item.conditionO.isEmpty ? "N/A" : item.conditionO,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "checkmark.seal",
                                    title: "Inspection Status",
                                    value: item.inspection == 1 ? "Passed" : "Failed",
                                    iconColor: mainColor
                                )
                            }
                            
                            // Inspection Details Section
                            FormSection(title: "Inspection Details") {
                                DetailRow(
                                    icon: "person.fill",
                                    title: "Inspector Name",
                                    value: item.inspectorName.isEmpty ? "N/A" : item.inspectorName,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "calendar",
                                    title: "Inspection Date",
                                    value: formatDate(item.inspectionDate),
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "calendar.badge.clock",
                                    title: "Follow-up Inspection",
                                    value: formatDate(item.inspectionDate1),
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "calendar.badge.exclamationmark",
                                    title: "Expiration Date",
                                    value: formatDate(item.expirationDate),
                                    iconColor: mainColor
                                )
                            }
                            
                            // Additional Information
                            FormSection(title: "Additional Info") {
                                DetailRow(
                                    icon: "bag",
                                    title: "Bag ID",
                                    value: item.bagID.isEmpty ? "N/A" : item.bagID,
                                    iconColor: mainColor
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                if isLoading {
                    LoadingView(message: "Updating item...", mainColor: mainColor)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditForm = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(mainColor)
                    }
                }
            }
            .sheet(isPresented: $showingEditForm) {
                EditItemFormView(item: item) { updatedItem in
                    self.shouldRefresh = true
                    showingEditForm = false
                }
            }
            .onChange(of: shouldRefresh) { oldValue, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        loadItemDetails(itemId: item.id)
                        shouldRefresh = false
                    }
                }
            }
        }
    }
    
    private func loadItemDetails(itemId: Int) {
        print("Iniciando carga de detalles para item: \(itemId)") // Debug
        isLoading = true
        apiService.getItemById(itemId) { result in
            if let updatedItem = result {
                print("Item actualizado recibido: \(updatedItem.itemDescription)") // Debug
                withAnimation {
                    self.item = updatedItem
                }
            } else {
                print("No se recibió item actualizado") // Debug
            }
            self.isLoading = false
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
    
    // Form Fields
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
    
    // Focus States
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
        
        // Inicializar estados
        _itemDescription = State(initialValue: item.itemDescription)
        _modelName = State(initialValue: item.modelName)
        _brand = State(initialValue: item.brand)
        _comment = State(initialValue: item.comment)
        _serialNumber = State(initialValue: item.serialNumber)
        _conditionO = State(initialValue: item.conditionO)
        _inspection = State(initialValue: item.inspection)
        _inspectorName = State(initialValue: item.inspectorName)
        
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
                        // Header
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
                        
                        // Form Sections
                        VStack(spacing: 24) {
                            // Item Details Section
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
                            
                            // Specifications Section
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
                            
                            // Inspection Details Section
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
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
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
        }
    }
    
    private func updateItem() {
        isLoading = true
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
            bagID: item.bagID
        )
        
        apiService.updateItem(updatedItem) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    print("Actualización exitosa") // Debug
                    self.onUpdate(updatedItem)
                    self.dismiss()
                } else {
                    print("Error en la actualización") // Debug
                }
            }
        }
    }
}
