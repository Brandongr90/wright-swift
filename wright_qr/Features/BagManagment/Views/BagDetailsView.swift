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
                    List(items) { item in
                        NavigationLink(destination: ItemDetailsView(item: item)) {
                            VStack(alignment: .leading) {
                                Text(item.itemDescription)
                                    .font(.headline)
                                Text(item.comment)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
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
            // Loading
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
    
    //    func addItem(itemName: String) {
    //        print("Add Item")
    //        let newItem = Item(id: bag.id, itemDescription: <#T##String#>, modelName: <#T##String#>, brand: <#T##String#>, comment: <#T##String#>, serialNumber: <#T##String#>, conditionO: <#T##String#>, inspection: <#T##Int#>, inspectionDate: <#T##String#>, inspectorName: <#T##String#>, inspectionDate1: <#T##String#>, expirationDate: <#T##String#>, bagID: <#T##String#>)
    //
    //        apiService.postItem(newItem) { success in
    //            if success {
    //                loadItems()
    //            }
    //        }
    //    }
    
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


