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
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Stats
                HStack(spacing: 20) {
                    StatisticView(
                        title: "Total Items",
                        value: "\(items.count)",
                        icon: "cube.box.fill",
                        color: mainColor
                    )
                    
                    StatisticView(
                        title: "New Items",
                        value: "\(items.filter { $0.conditionO.lowercased() == "new" }.count)",
                        icon: "sparkles",
                        color: .green
                    )
                }
                .padding()
                
                if items.isEmpty {
                    VStack {
                        Spacer()
                        ContentUnavailableView(
                            "No Items Yet",
                            systemImage: "cube.box",
                            description: Text("Start by adding your first item to this bag")
                        )
                        .offset(y: -50)
                        Spacer()
                    }
                } else {
                    // Items List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(items) { item in
                                NavigationLink(destination: ItemDetailsView(item: item)) {
                                    ModernItemCard(item: item, mainColor: mainColor)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // Bottom Action Buttons
                VStack(spacing: 12) {
                    ActionButton(
                        title: "Add New Item",
                        icon: "plus.circle.fill",
                        color: mainColor
                    ) {
                        showAddItemForm = true
                    }
                    
                    ActionButton(
                        title: "Generate QR Code",
                        icon: "qrcode",
                        color: mainColor
                    ) {
                        generateQR()
                    }
                    
                    ActionButton(
                        title: "Delete Bag",
                        icon: "trash.fill",
                        color: .red
                    ) {
                        showDeleteAlert = true
                    }
                }
                .padding()
                .background(
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: -5)
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
struct StatisticView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
