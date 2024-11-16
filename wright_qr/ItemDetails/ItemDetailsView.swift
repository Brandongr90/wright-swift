//
//  ItemDetailsView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI

struct ItemDetailsView: View {
    let item: Item
    
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Item Details")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(mainColor)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 15) {
                    DetailRow(title: "Name", value: item.itemDescription)
                    DetailRow(title: "Model Name", value: item.modelName.isEmpty ? "N/A" : item.modelName)
                    DetailRow(title: "Brand", value: item.brand.isEmpty ? "N/A" : item.brand)
                    DetailRow(title: "Comment / Description", value: item.comment.isEmpty ? "N/A" : item.comment)
                    DetailRow(title: "Serial Number", value: item.serialNumber.isEmpty ? "N/A" : item.serialNumber)
                    DetailRow(title: "Condition", value: item.conditionO.isEmpty ? "N/A" : item.conditionO)
                    DetailRow(title: "Inspection", value: item.inspection == 1 ? "Passed" : "Failed")
                    DetailRow(title: "Inspection Date 1", value: item.inspectionDate.isEmpty ? "N/A" : item.inspectionDate)
                    DetailRow(title: "Inspector Name", value: item.inspectorName.isEmpty ? "N/A" : item.inspectorName)
                    DetailRow(title: "Inspection Date 2", value: item.inspectionDate1.isEmpty ? "N/A" : item.inspectionDate1)
                    DetailRow(title: "Expiration Date", value: item.expirationDate.isEmpty ? "N/A" : item.expirationDate)
                    DetailRow(title: "Bag ID", value: item.bagID.isEmpty ? "N/A" : item.bagID)
                    
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Vista auxiliar para mostrar cada fila de detalles
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
