//
//  NewBagFormView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct NewBagFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bagName: String = ""
    @State private var hasAssignmentDate: Bool = false
    @State private var assignmentDate: Date = Date()
    @FocusState private var isNameFocused: Bool
    var onSave: (Bag) -> Void
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    VStack(spacing: 12) {
                        Image(systemName: "bag.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(mainColor)
                        
                        Text("Assign a new bag")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Enter the name of the owner of the bag")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Owner Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter the owner name", text: $bagName)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(uiColor: .secondarySystemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isNameFocused ? mainColor : Color.clear, lineWidth: 2)
                            )
                            .focused($isNameFocused)
                        
                        Toggle("Add Assignment Date", isOn: $hasAssignmentDate)
                            .padding(.top, 12)
                        
                        if hasAssignmentDate {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Assignment Date")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                DatePicker(
                                    "",
                                    selection: $assignmentDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(uiColor: .secondarySystemBackground))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            if !bagName.isEmpty {
                                saveBag()
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                Text("Save Bag")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(bagName.isEmpty ? mainColor.opacity(0.5) : mainColor)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: mainColor.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .disabled(bagName.isEmpty)
                        
                        Button(action: {
                            dismiss()
                        }) {
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
    }
    
    private func saveBag() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let assignmentDateString = hasAssignmentDate ? dateFormatter.string(from: assignmentDate) : nil
        
        // Use UserManager to get the current user's ID
        let userId = UserManager.shared.currentUser?.id ?? 0
        
        let newBag = Bag(
            id: UUID().uuidString,
            name: bagName,
            userId: userId,
            assignmentDate: assignmentDateString
        )
        
        onSave(newBag)
    }
}
