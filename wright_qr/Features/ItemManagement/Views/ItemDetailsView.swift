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
    
    // Formatter para convertir fechas de MySQL/ISO
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    // Formatter para mostrar fechas
    private let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM/dd/yyyy"
        return formatter
    }()
    
    // Método para formatear fecha
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
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 60))
                                .foregroundColor(mainColor)
                            
                            Text("Item Details")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(item.itemDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Details Sections
                        VStack(spacing: 24) {
                            // Item Information Section
                            FormSection(title: "Item Information") {
                                DetailRow(
                                    icon: "text.alignleft",
                                    title: "Description",
                                    value: item.itemDescription.isEmpty ? "N/A" : item.itemDescription,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "tag",
                                    title: "Model Name",
                                    value: item.modelName.isEmpty ? "N/A" : item.modelName,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "building.2",
                                    title: "Brand",
                                    value: item.brand.isEmpty ? "N/A" : item.brand,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "text.bubble",
                                    title: "Comment",
                                    value: item.comment.isEmpty ? "N/A" : item.comment,
                                    iconColor: mainColor
                                )
                            }
                            
                            // Specifications Section
                            FormSection(title: "Specifications") {
                                DetailRow(
                                    icon: "number",
                                    title: "Serial Number",
                                    value: item.serialNumber.isEmpty ? "N/A" : item.serialNumber,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "sparkles",
                                    title: "Condition",
                                    value: item.conditionO.isEmpty ? "N/A" : item.conditionO,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "checkmark.seal",
                                    title: "Inspection Status",
                                    value: item.inspection == 1 ? "Passed" : "Failed",
                                    iconColor: mainColor
                                )
                            }
                            
                            // Inspection Details Section
                            FormSection(title: "Inspection Details") {
                                DetailRow(
                                    icon: "person.fill",
                                    title: "Inspector Name",
                                    value: item.inspectorName.isEmpty ? "N/A" : item.inspectorName,
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "calendar",
                                    title: "Inspection Date",
                                    value: formatDate(item.inspectionDate),
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "calendar.badge.clock",
                                    title: "Follow-up Inspection",
                                    value: formatDate(item.inspectionDate1),
                                    iconColor: mainColor
                                )
                                DetailRow(
                                    icon: "calendar.badge.exclamationmark",
                                    title: "Expiration Date",
                                    value: formatDate(item.expirationDate),
                                    iconColor: mainColor
                                )
                            }
                            
                            // Additional Information
                            FormSection(title: "Additional Info") {
                                DetailRow(
                                    icon: "bag",
                                    title: "Bag ID",
                                    value: item.bagID.isEmpty ? "N/A" : item.bagID,
                                    iconColor: mainColor
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
