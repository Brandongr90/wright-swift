//
//  ScanQRView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 14/11/24.
//

import SwiftUI
import AVFoundation

struct ScanQRView: View {
    @State private var scannedCode: String?
    @State private var showBagDetails = false
    @State private var scannedBag: Bag?
    let apiService = ApiService()
    
    var body: some View {
        NavigationStack {
            VStack {
                QRScannerView(scannedCode: $scannedCode)
                    .frame(width: 300, height: 300)
                    .cornerRadius(12)
                    .padding()
                    .onChange(of: scannedCode) { code in
                        if let code = code {
                            loadBag(withId: code)
                        }
                    }
                
                if scannedCode == nil {
                    Text("Scan a QR code to view bag details")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Scan QR")
            .navigationDestination(isPresented: $showBagDetails) {
                if let bag = scannedBag {
                    BagDetailsView(bag: bag)
                }
            }
        }
    }
    
    private func loadBag(withId id: String) {
        // Aquí deberías hacer una llamada a tu API para obtener los detalles del bag
        // Por ahora, creamos un bag temporal
        scannedBag = Bag(id: id, name: "Scanned Bag")
        showBagDetails = true
    }
}
