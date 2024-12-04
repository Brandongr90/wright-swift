//
//  ScanQRView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct ScanQRView: View {
    @State private var scannedCode: String?
    @State private var showBagDetails = false
    @State private var scannedBag: Bag?
    @StateObject private var userManager = UserManager.shared
    @State private var isImagePickerPresented = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showError = false
    @State private var errorMessage = ""
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    let apiService = ApiService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Scanner Header
                    VStack(spacing: 8) {
                        Text("QR Scanner")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Position the QR code within the frame")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Scanner Area
                    ZStack {
                        QRScannerView(scannedCode: $scannedCode)
                            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(mainColor, lineWidth: 2)
                                    .opacity(0.5)
                            )
                        
                        // Scanner Animation
                        ScannerAnimation()
                            .frame(width: UIScreen.main.bounds.width - 80, height: 2)
                    }
                    .padding()
                    
                    // Status Message
                    if scannedCode == nil {
                        Label("Scanning for QR Code...", systemImage: "qrcode.viewfinder")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Bottom Actions
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $selectedItem,
                                     matching: .images) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Select from Library")
                            }
                            .font(.headline)
                            .foregroundColor(mainColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(mainColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Instructions
                        VStack(spacing: 8) {
                            InstructionRow(icon: "qrcode.viewfinder", text: "Align QR code within frame")
                            InstructionRow(icon: "photo", text: "Or select from your photo library")
                            InstructionRow(icon: "checkmark.circle", text: "Code will be detected automatically")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding()
                }
            }
            .onChange(of: scannedCode) { oldValue, newValue in
                if let code = newValue {
                    loadBag(withId: code)
                }
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                if let newValue {
                    processPickedImage(newValue)
                }
            }
            .navigationDestination(isPresented: $showBagDetails) {
                if let bag = scannedBag {
                    BagDetailsView(bag: bag)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func processPickedImage(_ item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        if let code = scanQRCode(from: uiImage) {
                            self.scannedCode = code
                        } else {
                            showError = true
                            errorMessage = "No QR code found in the selected image"
                        }
                    }
                case .failure:
                    showError = true
                    errorMessage = "Failed to process the selected image"
                }
            }
        }
    }
    
    private func scanQRCode(from image: UIImage) -> String? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: ciImage) as? [CIQRCodeFeature]
        return features?.first?.messageString
    }
    
    private func loadBag(withId id: String) {
        if let userId = userManager.currentUser?.id {
            scannedBag = Bag(id: id, name: "Scanned Bag", userId: userId)
            showBagDetails = true
        }
    }
}

// Helper Views
struct ScannerAnimation: View {
    @State private var position = false
    
    var body: some View {
        Rectangle()
            .fill(Color.green)
            .opacity(0.5)
            .offset(y: position ? 180 : -180)
            .animation(
                Animation.easeInOut(duration: 3)
                    .repeatForever(autoreverses: true),
                value: position
            )
            .onAppear {
                position.toggle()
            }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}
