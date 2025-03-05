//
//  InspectionHistoryView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 04/03/25.
//

import SwiftUI

struct InspectionHistoryView: View {
    let item: Item
    @State private var inspections: [InspectionHistory] = []
    @State private var isLoading = true
    @State private var showAddInspectionForm = false
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    let apiService = ApiService()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    private let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    private func formatDate(_ dateString: String) -> String {
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        return displayFormatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            if isLoading {
                LoadingView(message: "Loading inspection history...", mainColor: mainColor)
            } else if inspections.isEmpty {
                EmptyHistoryView()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(inspections) { inspection in
                            InspectionCard(inspection: inspection)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Inspection History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddInspectionForm = true
                }) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(mainColor)
                }
            }
        }
        .sheet(isPresented: $showAddInspectionForm) {
            AddInspectionFormView(item: item) { success in
                if success {
                    loadInspectionHistory()
                }
            }
        }
        .onAppear {
            loadInspectionHistory()
        }
    }
    
    private func loadInspectionHistory() {
        isLoading = true
        apiService.getInspectionHistory(for: item.id) { inspections in
            self.inspections = inspections
            self.isLoading = false
        }
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clipboard")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Inspection History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first inspection record to start tracking this item's history")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct InspectionCard: View {
    let inspection: InspectionHistory
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    private let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    private func formatDate(_ dateString: String) -> String {
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        return displayFormatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: inspection.inspectionStatus == 1 ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .foregroundColor(inspection.inspectionStatus == 1 ? .green : .red)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(inspection.inspectionDate))
                        .font(.headline)
                    
                    Text("Inspector: \(inspection.inspectorName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let nextDate = inspection.nextInspectionDate {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Next Inspection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatDate(nextDate))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(mainColor.opacity(0.1))
                            .foregroundColor(mainColor)
                            .cornerRadius(4)
                    }
                }
            }
            
            if let comments = inspection.comments, !comments.isEmpty {
                Text(comments)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}
