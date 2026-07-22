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
                        let isJoined = group.memberIds.contains(authViewModel.currentUserId ?? "")
                        GroupCard(group: group, isJoined: isJoined) {
                            Task {
                                if isJoined {
                                    await authViewModel.performIfLoggedIn(successMessage: "You've left \(group.name).") {
                                        guard let groupId = group.id, let userId = authViewModel.currentUserId else { return }
                                        try await GroupService().leaveGroup(groupId: groupId, userId: userId)
                                        viewModel.markLeft(groupId: groupId, userId: userId)
                                    }
                                } else {
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
                    .controlSize(.large)
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
        NavigationLink(destination: EventDetailsView(event: event)) {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Background image - fills entire frame with consistent aspect ratio
                    if !event.coverImage.isEmpty, let url = URL(string: event.coverImage) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                        } placeholder: {
                            Color.blue.opacity(0.2)
                        }
                    } else {
                        Color.blue.opacity(0.2)
                    }
                    
                    // Gradient overlay for text readability - fixed at top
                    VStack(spacing: 0) {
                        LinearGradient(
                            gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 250)
                        
                        Spacer()
                    }
                    
                    // Event info - absolutely positioned from top
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
                            .shadow(radius: 50)
                        
                        Spacer()
                    }
                    
                    .padding(.top, 60) // Fixed distance from top (below status bar/notch)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
