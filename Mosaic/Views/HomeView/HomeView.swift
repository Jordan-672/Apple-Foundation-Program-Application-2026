//
//  HomeView.swift
//  Mosaic
//
//  Created by Jordan Joseph on 17/7/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VerticalScrollExample()
    }
}

struct VerticalScrollExample: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(1...10, id: \.self) { number in
                    VStack {
                        
                        /*Text("GROUP \(number)")
                            .font(.headline)*/
                        Spacer()
                        
                        CardPattern()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    /*.background(.white.opacity(0.1))*/
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

struct CardPattern: View {
    var body: some View {
        VStack() {
            Image(systemName: "photo")
                .font(.system(size: 150))
                .foregroundColor(.gray)
            
            Text("Thai Food Enjoyers")
                .font(.title2)
                .bold()
            HStack {
                Text("Thai Food lovers in ...")
                    .font(.body)
                    .foregroundColor(.secondary)
                Spacer()
                Button("Join") {
                    // Action will be added later
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    HomeView()
}
