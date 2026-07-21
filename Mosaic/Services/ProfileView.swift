//
//  ProfileView.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var user: User?
    @State private var isLoading = true
    @State private var showEditSheet = false
    @State private var errorMessage: String?
    
    private let userService = UserService()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView("Loading profile...")
                        .padding()
                } else if let user = user {
                    VStack(spacing: 24) {
                        // Profile Header
                        HStack(alignment: .top, spacing: 16) {
                            // Profile Image
                            if !user.profileImage.isEmpty, let url = URL(string: user.profileImage) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 90, height: 90)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                // User Name
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(.title2)
                                    .bold()

                                // Location
                                HStack(alignment: .firstTextBaseline, spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(user.location), \(user.country)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                // Joined date
                                if let createdAt = authViewModel.accountCreatedAt {
                                    Text("Joined \(createdAt.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)

                        Divider()
                            .padding(.horizontal)
                        
                        // Profile Information Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Profile Information")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                ProfileInfoRow(icon: "person.fill", title: "First Name", value: user.firstName)
                                ProfileInfoRow(icon: "person.fill", title: "Last Name", value: user.lastName)
                                ProfileInfoRow(icon: "mappin.and.ellipse", title: "Location", value: user.location)
                                ProfileInfoRow(icon: "globe", title: "Country", value: user.country)
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button {
                                showEditSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(role: .destructive) {
                                authViewModel.signOut()
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Log Out")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                } else if !authViewModel.isLoggedIn {
                    VStack(spacing: 16) {
                        Text("Sign in to see your profile")
                            .foregroundStyle(.secondary)
                        Button("Sign In") {
                            authViewModel.showLoginSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("Unable to load profile")
                            .font(.headline)

                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                        }

                        Button("Retry") {
                            Task {
                                await loadUserProfile()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .refreshable {
                await loadUserProfile()
            }
            .sheet(isPresented: $showEditSheet) {
                if let user = user {
                    EditProfileView(user: user) { updatedFirstName, updatedLastName, updatedCountry in
                        await updateProfile(firstName: updatedFirstName, lastName: updatedLastName, country: updatedCountry)
                    }
                }
            }
        }
        .task(id: authViewModel.isLoggedIn) {
            await loadUserProfile()
        }
    }

    private func loadUserProfile() async {
        guard let userId = authViewModel.currentUserId else {
            isLoading = false
            user = nil
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            user = try await userService.fetchUser(id: userId)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func updateProfile(firstName: String, lastName: String, country: String) async {
        guard let userId = authViewModel.currentUserId else { return }

        do {
            try await userService.updateUser(id: userId, firstName: firstName, lastName: lastName, country: country)
            // Refresh the user data
            await loadUserProfile()
            showEditSheet = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String
    @State private var lastName: String
    @State private var country: String
    @State private var showCountryPicker = false
    @State private var isUpdating = false

    let user: User
    let onSave: (String, String, String) async -> Void

    init(user: User, onSave: @escaping (String, String, String) async -> Void) {
        self.user = user
        self.onSave = onSave
        _firstName = State(initialValue: user.firstName)
        _lastName = State(initialValue: user.lastName)
        _country = State(initialValue: user.country)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Information") {
                    TextField("First Name", text: $firstName)
                        .textContentType(.givenName)

                    TextField("Last Name", text: $lastName)
                        .textContentType(.familyName)
                }

                Section {
                    Text("Location: \(user.location)")
                        .foregroundColor(.secondary)

                    Button {
                        showCountryPicker = true
                    } label: {
                        HStack {
                            Text("Country")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(country)
                                .foregroundColor(.secondary)
                        }
                    }
                } footer: {
                    Text("Location can't be changed here.")
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            isUpdating = true
                            await onSave(firstName, lastName, country)
                            isUpdating = false
                            dismiss()
                        }
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || isUpdating)
                }
            }
            .disabled(isUpdating)
            .sheet(isPresented: $showCountryPicker) {
                CountryPicker(selectedCountry: $country)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
