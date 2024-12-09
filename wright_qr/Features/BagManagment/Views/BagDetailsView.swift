//
//  BagDetailsView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct BagDetailsView: View {
    var bag: Bag
    @State private var items: [Item] = []
    @State private var showAddItemForm = false
    @State private var isLoading = false
    @State private var qrImage: UIImage? = nil
    @State private var showQRPreview = false
    @State private var isGeneratingQR = false
    @State private var showDeleteAlert = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    let apiService = ApiService()
    
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    Color(uiColor: .systemBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
                // Header Stats
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        StatisticCard(
                            title: "Total Items",
                            value: "\(items.count)",
                            icon: "cube.box.fill",
                            color: mainColor
                        )
                        
                        StatisticCard(
                            title: "New Items",
                            value: "\(items.filter { $0.conditionO.lowercased() == "new" }.count)",
                            icon: "sparkles",
                            color: .green
                        )
                        
                        StatisticCard(
                            title: "Used Items",
                            value: "\(items.filter { $0.conditionO.lowercased() == "used" }.count)",
                            icon: "archivebox",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                }
                .scrollClipDisabled()
                
                if items.isEmpty {
                    EmptyStateView()
                } else {
                    // Lista de items mejorada
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(items) { item in
                                NavigationLink(destination: ItemDetailsView(item: item)) {
                                    EnhancedItemCard(item: item, mainColor: mainColor)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
                
                // Bottom Action Buttons
                VStack(spacing: 12) {
                    EnhancedActionButton(
                        title: "Add New Item",
                        icon: "plus.circle.fill",
                        color: mainColor,
                        action: { showAddItemForm = true }
                    )
                    
                    HStack(spacing: 12) {
                        EnhancedActionButton(
                            title: "QR Code",
                            icon: "qrcode",
                            color: mainColor,
                            isSecondary: true,
                            action: generateQR
                        )
                        
                        EnhancedActionButton(
                            title: "Delete",
                            icon: "trash.fill",
                            color: .red,
                            isSecondary: true,
                            action: { showDeleteAlert = true }
                        )
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: -5)
                )
            }
            
            if isLoading {
                LoadingView(message: "Loading items...", mainColor: mainColor)
            }
            
            if isGeneratingQR {
                LoadingView(message: "Generating QR Code...", mainColor: mainColor)
            }
        }
        .alert("Delete Bag", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteBag()
            }
        } message: {
            Text("Are you sure you want to delete this bag? All items in this bag will be deleted. This action cannot be undone.")
        }
        .sheet(isPresented: $showQRPreview) {
            if let qrImage = qrImage {
                QRPreviewView(qrImage: qrImage)
            }
        }
        .sheet(isPresented: $showAddItemForm) {
            NewItemFormView(bag: bag) { newItem in
                loadItems()
                showAddItemForm = false
            }
        }
        .navigationTitle(bag.name)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadItems()
        }
    }
    
    // Existing functions remain the same
    func loadItems() {
        isLoading = true
        apiService.getItemsByBag(for: bag.id) { loadedItems in
            DispatchQueue.main.async {
                self.items = loadedItems
                self.isLoading = false
            }
        }
    }
    
    func generateQR() {
        isGeneratingQR = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let context = CIContext()
            let filter = CIFilter.qrCodeGenerator()
            let bagId = bag.id
            filter.message = Data(bagId.utf8)
            
            if let outputImage = filter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledImage = outputImage.transformed(by: transform)
                
                if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                    DispatchQueue.main.async {
                        self.qrImage = UIImage(cgImage: cgImage)
                        self.isGeneratingQR = false
                        self.showQRPreview = true
                    }
                }
            }
        }
    }
    
    func deleteBag() {
        isLoading = true
        apiService.delete(bag.id, direction: "bags") { success in
            
            if success {
                DispatchQueue.main.async {
                    isLoading = false
                    // Navegar a GenerateQRView
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView:
                                                                            NavigationView {
                            MainTabView()
                        }
                        )
                    }
                }
            } else {
                print("Error")
            }
        }
    }
}

// New Components
struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(width: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ModernItemCard: View {
    let item: Item
    let mainColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Container
            ZStack {
                Circle()
                    .fill(mainColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: "cube.box.fill")
                    .foregroundColor(mainColor)
                    .font(.title2)
            }
            
            // Item Details
            VStack(alignment: .leading, spacing: 8) {
                Text(item.itemDescription)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Label(item.brand.isEmpty ? "N/A" : item.brand, systemImage: "tag.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Condition Badge
                    Text(item.conditionO.isEmpty ? "N/A" : item.conditionO)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(item.conditionO.lowercased() == "new" ? Color.green.opacity(0.2) :
                                        item.conditionO.lowercased() == "used" ? Color.orange.opacity(0.2) : Color.gray.opacity(0.2))
                        )
                        .foregroundColor(item.conditionO.lowercased() == "new" ? .green :
                                            item.conditionO.lowercased() == "used" ? .orange : .gray)
                }
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct EnhancedItemCard: View {
    let item: Item
    let mainColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono mejorado
            ZStack {
                Circle()
                    .fill(mainColor.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: "cube.box.fill")
                    .font(.system(size: 24))
                    .foregroundColor(mainColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.itemDescription)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Label(
                        item.brand.isEmpty ? "N/A" : item.brand,
                        systemImage: "tag.fill"
                    )
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    ConditionBadge(condition: item.conditionO)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        )
    }
}

struct ConditionBadge: View {
    let condition: String
    
    private var conditionColor: Color {
        switch condition.lowercased() {
        case "new": return .green
        case "used": return .orange
        default: return .gray
        }
    }
    
    var body: some View {
        Text(condition.isEmpty ? "N/A" : condition)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(conditionColor.opacity(0.15))
            )
            .foregroundColor(conditionColor)
    }
}

struct EnhancedActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var isSecondary: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(isSecondary ? color : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSecondary ? color.opacity(0.15) : color)
            )
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cube.box")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Items Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start by adding your first item to this bag")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
