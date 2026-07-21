//
//  CompleteProfileView.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 20/7/2026.
//

import SwiftUI

struct CompleteProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var locationManager = LocationManager()

    @State private var location = ""
    @State private var country = ""
    @State private var showCountryPicker = false
    @State private var isFetchingLocation = false
    @State private var locationErrorMessage: String?

    private var canSubmit: Bool {
        !location.isEmpty && !country.isEmpty && !authViewModel.isLoading
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Just need a couple more details before you're in.")
                        .foregroundStyle(.secondary)
                }

                Section("Profile") {
                    HStack {
                        Text(location.isEmpty ? "Location not set" : location)
                            .foregroundStyle(location.isEmpty ? .secondary : .primary)
                        Spacer()
                        Button {
                            Task {
                                isFetchingLocation = true
                                locationErrorMessage = nil
                                do {
                                    location = try await locationManager.requestCurrentLocation()
                                } catch {
                                    locationErrorMessage = error.localizedDescription
                                }
                                isFetchingLocation = false
                            }
                        } label: {
                            if isFetchingLocation {
                                ProgressView()
                            } else {
                                Label("Use Current", systemImage: "location.fill")
                                    .font(.caption)
                            }
                        }
                        .disabled(isFetchingLocation)
                    }
                    if let locationErrorMessage {
                        Text(locationErrorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button {
                        showCountryPicker = true
                    } label: {
                        HStack {
                            Text(country.isEmpty ? "Select Country" : country)
                                .foregroundStyle(country.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Button {
                    Task {
                        await authViewModel.completeProfile(location: location, country: country)
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!canSubmit)

                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
            }
            .navigationTitle("Complete Your Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCountryPicker) {
                CountryPicker(selectedCountry: $country)
            }
        }
    }
}

#Preview {
    CompleteProfileView()
        .environmentObject(AuthViewModel())
}
