//
//  QRPreviewView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 15/11/24.
//

import SwiftUI
import UIKit

struct QRPreviewView: View {
    let qrImage: UIImage?
    @State private var showingSaveConfirmation = false
    
    // Color scheme
    private let mainColor = Color(red: 0.04, green: 0.36, blue: 0.25)
    
    var body: some View {
        ZStack {
            // Background
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header Area
                VStack(spacing: 12) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(mainColor)
                    
                    Text("QR Code Ready")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Save or print your QR code")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // QR Code Display
                if let qrImage = qrImage {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 20) {
                            Image(uiImage: qrImage)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                        }
                        .padding(24)
                    }
                    .frame(width: 300, height: 300)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: saveImage) {
                            ActionButtonContent(
                                icon: "square.and.arrow.down.fill",
                                title: "Save to Photos",
                                subtitle: "Save QR code to your photo library",
                                color: mainColor
                            )
                        }
                        
                        Button(action: printImage) {
                            ActionButtonContent(
                                icon: "printer.fill",
                                title: "Print QR Code",
                                subtitle: "Send to a nearby printer",
                                color: mainColor
                            )
                        }
                    }
                    .padding(.horizontal)
                } else {
                    ErrorView()
                }
                
                Spacer()
            }
        }
        .alert("QR Code Saved", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("The QR code has been saved to your photo library.")
        }
    }
    
    func saveImage() {
        guard let qrImage = qrImage else { return }
        UIImageWriteToSavedPhotosAlbum(qrImage, nil, nil, nil)
        showingSaveConfirmation = true
    }
    
    func printImage() {
        guard let qrImage = qrImage else { return }
        
        // Tamaño de impresión en puntos (ejemplo: 200x200 puntos)
        let printWidth: CGFloat = 200
        let printHeight: CGFloat = 200
        
        // Tamaño de la hoja A4 en puntos (72 puntos = 1 pulgada)
        let pageWidth: CGFloat = 595.2 // 8.27 pulgadas (A4)
        let pageHeight: CGFloat = 841.8 // 11.69 pulgadas (A4)
        
        // Crear una vista personalizada para el contenido a imprimir
        let printableView = UIView(frame: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        printableView.backgroundColor = .white
        
        // Calcular posición centrada de la imagen
        let imageX = (pageWidth - printWidth) / 2
        let imageY = (pageHeight - printHeight) / 2
        let imageView = UIImageView(image: qrImage)
        imageView.frame = CGRect(x: imageX, y: imageY, width: printWidth, height: printHeight)
        imageView.contentMode = .scaleAspectFit
        printableView.addSubview(imageView)
        
        // Renderizar la vista como una imagen
        let renderer = UIGraphicsImageRenderer(size: printableView.bounds.size)
        let renderedImage = renderer.image { context in
            printableView.layer.render(in: context.cgContext)
        }
        
        // Configurar el controlador de impresión
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "QR Code Print"
        printInfo.outputType = .photo
        printController.printInfo = printInfo
        printController.printingItem = renderedImage
        
        // Mostrar el controlador de impresión
        printController.present(animated: true, completionHandler: nil)
    }

}

// Custom Action Button Content View
struct ActionButtonContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Error View
struct ErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("QR Code Not Available")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("There was an error generating the QR code")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
