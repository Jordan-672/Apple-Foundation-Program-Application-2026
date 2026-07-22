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
    @State private var selectedSpotlightEvent: Event?

    var body: some View {
        SwiftUI.Group {
            if viewModel.isLoading {
                // Same logo as the launch screen, so the transition into the
                // app feels like one continuous moment instead of a jump cut
                // to a spinner.
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    // Spotlight Events Carousel — hidden entirely when there's nothing to show
                    if !viewModel.spotlights.isEmpty {
                        TabView {
                            ForEach(viewModel.spotlights) { spotlight in
                                SpotlightCarouselView(event: spotlight) {
                                    selectedSpotlightEvent = spotlight
                                }
                            }
                        }
                        .offset(y: -64)
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                        .frame(height: 260)
                        .ignoresSafeArea()
                    }

                    // Groups Section
                    VStack(spacing: 16) {
                        if let error = viewModel.errorMessage {
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
                                )
                            }
                        }
                    }
                    .offset(y: viewModel.spotlights.isEmpty ? 0 : -64)
                    .padding()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationDestination(item: $selectedSpotlightEvent) { event in
            EventDetailsView(event: event)
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

    var body: some View {
        NavigationLink(destination: GroupView(groupId: group.id ?? "")) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
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

                    Image(systemName: isJoined ? "checkmark.circle.fill" : "plus.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, isJoined ? Color.gray : Color.red)
                        .font(.system(size: 28))
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1)
                        .padding(8)
                }

                Text(group.name)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.primary)

                Text(group.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(height: 20, alignment: .topLeading)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct SpotlightCarouselView: View {
    let event: Event
    let onTap: () -> Void

    var body: some View {
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
                    .frame(height: 140)

                    Spacer()
                }

                // Event info - absolutely positioned from top
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)

                    Text(event.location)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))

                    Text(event.startAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(radius: 50)

                    Spacer()
                }
                .padding(.top, 54) // Fixed distance from top (below status bar/notch)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
