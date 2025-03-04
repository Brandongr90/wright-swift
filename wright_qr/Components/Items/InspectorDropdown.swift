//
//  InspectorDropdown.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 04/03/25.
//

import SwiftUI

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
                                            Image(systemName: "person")
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
