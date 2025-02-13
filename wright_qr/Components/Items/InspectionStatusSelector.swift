//
//  InspectionStatusSelector.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 16/11/24.
//

import SwiftUI

struct InspectionStatusSelector: View {
    @Binding var status: Int
    @State private var selectedStatus: Bool
    let mainColor: Color
    
    init(status: Binding<Int>, mainColor: Color) {
        self._status = status
        self._selectedStatus = State(initialValue: status.wrappedValue == 1)
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
                        Button(action: {
                            selectedStatus = true
                            status = 1
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Passed")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(selectedStatus ? mainColor : Color.clear)
                            )
                            .foregroundColor(selectedStatus ? .white : .primary)
                        }
                        
                        Button(action: {
                            selectedStatus = false
                            status = 0
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Failed")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(!selectedStatus ? Color.red : Color.clear)
                            )
                            .foregroundColor(!selectedStatus ? .white : .primary)
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
