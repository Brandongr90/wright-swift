//
//  LoadingView.swift
//  wright_qr
//
//  Created by Brandon Gonzalez on 19/11/24.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    let mainColor: Color
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Fondo con efecto glassmorphism
            Color.black.opacity(0.2)
                .background(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
            
            // Contenedor principal
            VStack(spacing: 20) {
                // Indicador de carga personalizado
                ZStack {
                    // Círculo exterior rotativo
                    Circle()
                        .stroke(mainColor.opacity(0.3), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    // Círculo interior con animación
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(mainColor, style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round
                        ))
                        .frame(width: 60, height: 60)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(
                            .linear(duration: 1)
                            .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                }
                
                // Mensaje con diseño mejorado
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(mainColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(mainColor.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .opacity(isAnimating ? 1 : 0.7)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: isAnimating)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(UIColor.systemBackground).opacity(0.7))
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}
