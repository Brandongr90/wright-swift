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
    
    var body: some View {
        ZStack {
            // Background with blur effect
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 10)
            
            // Main loading content
            VStack(spacing: 24) {
                // Animated loading indicator
                ZStack {
                    // Main progress view
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: mainColor))
                        .scaleEffect(2)
                }
                .frame(width: 100, height: 100)
                
                // Message with subtle animation
                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(mainColor.opacity(0.3))
                    )
            }
            .padding()
        }
    }
}
