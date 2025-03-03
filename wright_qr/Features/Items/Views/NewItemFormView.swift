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
    
    // Dropdown state variables
    @State private var isInspectorDropdownShown = false
    // Static list of inspectors
    private let inspectors = ["Saul Villa"]
    
    // Cambio de expirationDate * Eliminar despues de pruebas *
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
                        .padding(.horizontal)
                        
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
        .interactiveToast($toasts)
    }
    
    func addItem() {
        let expDateString = isExpirationNA ? "N/A" : dateFormatter.string(from: expirationDateValue)
        
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
            bagID: String(bag.id)
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

// Inspector Dropdown component
struct InspectorDropdown: View {
    @Binding var inspectorName: String
    @Binding var isDropdownShown: Bool
    let inspectors: [String]
    let focused: Bool
    let mainColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Inspector Name")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .top) {
                // Text field with dropdown button
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(mainColor)
                    
                    TextField("Inspector Name", text: $inspectorName)
                        .autocorrectionDisabled()
                        .autocapitalization(.words)
                    
                    Button(action: {
                        withAnimation(.spring(dampingFraction: 0.7)) {
                            isDropdownShown.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(isDropdownShown ? "Close" : "Select")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            Image(systemName: isDropdownShown ? "chevron.up" : "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(mainColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(mainColor.opacity(0.1))
                        )
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(focused || isDropdownShown ? mainColor : Color.clear, lineWidth: 2)
                )
                
                // Dropdown list
                if isDropdownShown {
                    let filteredInspectors = inspectors.filter {
                        inspectorName.isEmpty || $0.lowercased().contains(inspectorName.lowercased())
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        if filteredInspectors.isEmpty {
                            Text("No matching inspectors")
                                .foregroundColor(.secondary)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 16)
                        } else {
                            ForEach(filteredInspectors, id: \.self) { inspector in
                                Button(action: {
                                    inspectorName = inspector
                                    withAnimation(.spring(dampingFraction: 0.7)) {
                                        isDropdownShown = false
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        if inspectorName == inspector {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(mainColor)
                                                .font(.subheadline)
                                        } else {
                                            Image(systemName: "person.badge.shield.checkmark")
                                                .foregroundColor(.secondary)
                                                .font(.subheadline)
                                        }
                                        
                                        Text(inspector)
                                            .foregroundColor(inspectorName == inspector ? mainColor : .primary)
                                            .fontWeight(inspectorName == inspector ? .semibold : .regular)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(inspectorName == inspector ?
                                                  mainColor.opacity(0.15) : Color.clear)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if inspector != filteredInspectors.last {
                                    Divider()
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
                            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .offset(y: 60)
                    .zIndex(1)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.bottom, isDropdownShown ? 70 : 0) // Space for dropdown
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
