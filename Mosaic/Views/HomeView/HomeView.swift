//
//  HomeView.swift
//  Mosaic
//
//  Created by Jordan Joseph on 17/7/2026.
//

import SwiftUI
import Foundation

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            // Spotlight Events Carousel
            TabView {
                if viewModel.spotlights.isEmpty {
                    // Show placeholder carousels while loading or if no spotlights
                    Carousel1View()
                    Carousel2View()
                    Carousel3View()
                    Carousel4View()
                    Carousel5View()
                } else {
                    ForEach(viewModel.spotlights) { spotlight in
                        SpotlightCarouselView(event: spotlight)
                    }
                }
            }
            .offset(y: -64)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 400)
            .ignoresSafeArea()
            
            // Groups Section
            VStack(spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("Loading groups...")
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                } else if viewModel.groups.isEmpty {
                    Text("No groups available")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(viewModel.groups) { group in
                        GroupCard(
                            group: group,
                            isJoined: group.memberIds.contains(authViewModel.currentUserId ?? "")
                        ) {
                            Task {
                                await authViewModel.performIfLoggedIn(successMessage: "You've joined \(group.name)!") {
                                    guard let groupId = group.id, let userId = authViewModel.currentUserId else { return }
                                    try await GroupService().joinGroup(groupId: groupId, userId: userId)
                                    viewModel.markJoined(groupId: groupId, userId: userId)
                                }
                            }
                        }
                    }
                }
            }
            .offset(y: -64)
            .padding()
        }
        .task {
            await viewModel.fetchData()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

struct GroupCard: View {
    let group: Group
    let isJoined: Bool
    let onJoin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(destination: GroupView(groupId: group.id ?? "")) {
                VStack(alignment: .leading, spacing: 8) {
                    AsyncImage(url: URL(string: group.coverImage)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: 150)
                    .clipped()

                    Text(group.name)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primary)

                    Text(group.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)

            HStack {
                Spacer()
                Button(isJoined ? "Joined" : "Join", action: onJoin)
                    .buttonStyle(.borderedProminent)
                    .tint(isJoined ? .gray : .red)
                    .disabled(isJoined)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

struct SpotlightCarouselView: View {
    let event: Event
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            if !event.coverImage.isEmpty, let url = URL(string: event.coverImage) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.blue.opacity(0.2)
                }
            } else {
                Color.blue.opacity(0.2)
            }
            
            // Gradient overlay for text readability
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Event info
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                Text(event.location)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(event.startAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .offset(y: -25)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct Carousel1View: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.2)
            Text("Slide 1")
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct Carousel2View: View {
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.2)
                
            Text("Slide 2")
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct Carousel3View: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.2)
                
            Text("Slide 3")
                    .font(.largeTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct Carousel4View: View {
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.2)
                
            Text("Slide 4")
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct Carousel5View: View {
    var body: some View {
        ZStack {
            Color.green.opacity(0.2)
                
            Text("Slide 5")
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
