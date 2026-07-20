//
//  EventDetailView.swift
//  HomeScreen
//
//  Created by Zenith Phan on 17/7/2026.
//

import SwiftUI

struct EventDetailView: View {
    var body: some View {
        NavigationStack {
            VStack(){
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        
                        //ForEach
                        Image(systemName: "photo")
                            .font(.system(size: 150))
                            .foregroundColor(.black)
                        Image(systemName: "photo")
                            .font(.system(size: 150))
                            .foregroundColor(.black)
                    }
                }
                    .padding(.horizontal)
                
                    DetailCard()
                
                    DetailCard()
                
                    DetailCard()
                
                    DetailCard()
                
                    DetailCard()
                Spacer()
                Button("Join") {
                    // Action will be added later
                }
                .font(.title3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 60)
                .buttonStyle(.borderedProminent)
                .tint(.red.opacity(1))
            }
            
            
            .navigationBarTitle("Event 1")            .background(.white.opacity(1))
        }
    }
}
struct DetailCard: View {
    var body: some View {
        Text("BlaBla")
        .foregroundColor(.black)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .topLeading)
        .cornerRadius(8)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal,5)
    }
}
#Preview {
    EventDetailView()
}
