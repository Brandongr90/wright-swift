//
//  InspectionStatusSelector.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 16/11/24.
//

import SwiftUI

struct InspectionStatusSelector: View {
    @Binding var status: Int
    @State private var selectedStatus: Int
    let mainColor: Color
    
    init(status: Binding<Int>, mainColor: Color) {
        self._status = status
        self._selectedStatus = State(initialValue: status.wrappedValue)
        self.mainColor = mainColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Inspection Status")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(mainColor)
                
                ZStack {
                    Capsule()
                        .fill(Color(uiColor: .secondarySystemBackground))
                    
                    HStack(spacing: 0) {
                        // Passed Button
                        Button(action: {
                            selectedStatus = 1
                            status = 1
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Passed")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(selectedStatus == 1 ? mainColor : Color.clear)
                            )
                            .foregroundColor(selectedStatus == 1 ? .white : .primary)
                        }
                        
                        // Failed Button
                        Button(action: {
                            selectedStatus = 0
                            status = 0
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Failed")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(selectedStatus == 0 ? Color.red : Color.clear)
                            )
                            .foregroundColor(selectedStatus == 0 ? .white : .primary)
                        }
                        
                        // N/A Button
                        Button(action: {
                            selectedStatus = 2
                            status = 2
                        }) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                Text("N/A")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(selectedStatus == 2 ? Color.gray : Color.clear)
                            )
                            .foregroundColor(selectedStatus == 2 ? .white : .primary)
                        }
                    }
                }
            }
            .frame(height: 44)
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
        }
    }
}
