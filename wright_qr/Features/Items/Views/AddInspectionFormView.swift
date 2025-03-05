//
//  AddInspectionFormView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 04/03/25.
//

import SwiftUI

struct AddInspectionFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var inspectionStatus: Int = 1
    @State private var inspectionDate: Date = Date()
    @State private var inspectorName: String = ""
    @State private var nextInspectionDate: Date = Date().addingTimeInterval(60*60*24*30*6) // 6 meses después
    @State private var comments: String = ""
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    
    let item: Item
    let onCompletion: (Bool) -> Void
    let apiService = ApiService()
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    enum Field {
        case inspector, comments
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Item")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(item.itemDescription)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        
                        InspectionStatusSelector(status: $inspectionStatus, mainColor: mainColor)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Inspector Name")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(mainColor)
                                TextField("Enter inspector name", text: $inspectorName)
                                    .focused($focusedField, equals: .inspector)
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .inspector ? mainColor : Color.clear, lineWidth: 2)
                            )
                        }
                        
                        CustomDatePickerWithFormat(
                            title: "Inspection Date",
                            date: $inspectionDate,
                            icon: "calendar"
                        )
                        
                        CustomDatePickerWithFormat(
                            title: "Next Inspection Date",
                            date: $nextInspectionDate,
                            icon: "calendar.badge.clock"
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Comments")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ZStack(alignment: .topLeading) {
                                
                                
                                TextEditor(text: $comments)
                                    .focused($focusedField, equals: .comments)
                                    .frame(minHeight: 100)
                                    .padding(4)
                                    .scrollContentBackground(.hidden)
                                    .background(Color(uiColor: .secondarySystemBackground))
                                
                                if comments.isEmpty {
                                    Text("Enter any comments about this inspection...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .comments ? mainColor : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                    .padding()
                }
                
                if isLoading {
                    LoadingView(message: "Saving inspection...", mainColor: mainColor)
                }
            }
            .navigationTitle("Add Inspection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.gray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveInspection()
                    } label: {
                        Text("Save")
                            .fontWeight(inspectorName.isEmpty ? .regular : .semibold)
                            .foregroundColor(inspectorName.isEmpty ? mainColor.opacity(0.4) : mainColor)
                    }
                    .disabled(inspectorName.isEmpty)
                }
            }
        }
    }
    
    private func saveInspection() {
        isLoading = true
        
        apiService.createInspection(
            itemId: item.id,
            status: inspectionStatus,
            date: dateFormatter.string(from: inspectionDate),
            inspector: inspectorName,
            nextDate: dateFormatter.string(from: nextInspectionDate),
            comments: comments
        ) { success in
            isLoading = false
            onCompletion(success)
            dismiss()
        }
    }
}
