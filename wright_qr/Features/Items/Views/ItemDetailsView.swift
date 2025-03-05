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
                    self.onUpdate(updatedItem)
                    self.dismiss()
                } else {
                }
            }
        }
    }
}
