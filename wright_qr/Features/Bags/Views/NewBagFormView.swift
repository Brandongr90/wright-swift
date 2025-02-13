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
    @FocusState private var isNameFocused: Bool
    var onSave: (String) -> Void
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
                        
                        Text("New Climbing Gear Bag")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Give your bag a memorable name")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Bag Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("", text: $bagName)
                            .placeholder(when: bagName.isEmpty) {
                                Text("Enter the owner name")
                                    .foregroundColor(.secondary)
                            }
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
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            if !bagName.isEmpty {
                                onSave(bagName)
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
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

//#Preview {
//    NewBagFormView(onSave: { _ in })
//}
