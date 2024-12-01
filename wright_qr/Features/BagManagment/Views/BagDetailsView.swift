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
    @Environment(\.colorScheme) var colorScheme
    let apiService = ApiService()
    
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        ZStack {
            VStack {
                if items.isEmpty {
                    ContentUnavailableView(
                        "No Items",
                        systemImage: "bag",
                        description: Text("Add your first item to this bag")
                    )
                } else {
                    List {
                        ForEach(items) { item in
                            NavigationLink(destination: ItemDetailsView(item: item)) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(mainColor.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "cube.box.fill")
                                            .foregroundColor(mainColor)
                                            .font(.title2)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(item.itemDescription)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        HStack {
                                            Label(item.brand.isEmpty ? "N/A" : item.brand, systemImage: "tag.fill")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                            
                                            Label(item.conditionO.isEmpty ? "N/A" : item.conditionO, systemImage: "checkmark.circle.fill")
                                                .font(.subheadline)
                                                .foregroundColor(
                                                    item.conditionO.lowercased() == "new" ? .green :
                                                    item.conditionO.lowercased() == "used" ? .orange : .gray
                                                )
                                                .lineLimit(1)
                                        }
                                    }
                                    .padding(.leading, 8)
                                    
                                    Spacer()
                                    
//                                    Image(systemName: "chevron.right")
//                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 12)
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        showAddItemForm = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New Item")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(mainColor)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        generateQR()
                    }) {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("Generate QR for Bag")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(mainColor)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            if isLoading {
                LoadingView(message: "Loading items...", mainColor: mainColor)
            }
        }
        .sheet(isPresented: $showQRPreview) {
            QRPreviewView(qrImage: qrImage)
        }
        .sheet(isPresented: $showAddItemForm) {
            NewItemFormView(bag: bag) { newItem in
                loadItems()
                showAddItemForm = false
            }
        }
        .navigationTitle(bag.name)
        .onAppear {
            loadItems()
        }
    }
    
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
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(bag.id.utf8)
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                qrImage = UIImage(cgImage: cgImage)
                showQRPreview = true
            } else {
                print("Failed to create CGImage from QR output")
            }
        } else {
            print("Failed to generate QR code")
        }
    }
}
