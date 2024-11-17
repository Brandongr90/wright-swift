//
//  NewItemFormView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct NewItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    // Form Fields
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
    @State private var expirationDate: Date = Date()
    
    // Focus States
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
                        // Header
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
                                
                                // Custom Stepper
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
                        
                        // Save Button
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
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    func addItem() {
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
            expirationDate: dateFormatter.string(from: expirationDate),
            bagID: String(bag.id)
        )
        
        apiService.postItem(newItem) { success in
            if success {
                onSave(newItem)
                dismiss()
            }
        }
    }
}

// Helper Views
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
