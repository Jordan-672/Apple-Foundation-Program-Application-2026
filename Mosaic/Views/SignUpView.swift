//
//  SignUpView.swift
//  Mosaic
//
<<<<<<< Updated upstream
//  Created by Gahyeon Kim on 20/7/2026.
=======
//  Created by Jordan Joseph on 18/7/2026.
>>>>>>> Stashed changes
//

import SwiftUI

<<<<<<< Updated upstream
private struct PasswordField: View {
    let title: String
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        HStack {
            SwiftUI.Group {
                if isVisible {
                    TextField(title, text: $text)
                } else {
                    SecureField(title, text: $text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct RequirementRow: View {
    let text: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isMet ? .green : .secondary)
            Text(text)
                .font(.caption)
                .foregroundStyle(isMet ? .primary : .secondary)
        }
    }
}

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var location = ""
    @State private var country = ""
    @State private var showCountryPicker = false
    @State private var isFetchingLocation = false
    @State private var locationErrorMessage: String?

    private var isEmailValid: Bool {
        email.contains("@") && email.split(separator: "@").count == 2
            && (email.split(separator: "@").last?.contains(".") ?? false)
    }
    private var hasMinLength: Bool { password.count >= 8 }
    private var hasLetter: Bool { password.contains(where: \.isLetter) }
    private var hasNumber: Bool { password.contains(where: \.isNumber) }
    private var passwordMeetsRequirements: Bool { hasMinLength && hasLetter && hasNumber }
    private var canSubmit: Bool {
        !firstName.isEmpty && !lastName.isEmpty && isEmailValid
            && passwordMeetsRequirements
            && !location.isEmpty && !country.isEmpty
            && !authViewModel.isLoading
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    if !email.isEmpty && !isEmailValid {
                        Text("Enter a valid email address")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    PasswordField(title: "Password", text: $password)
                    if !password.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            RequirementRow(text: "At least 8 characters", isMet: hasMinLength)
                            RequirementRow(text: "Contains a letter", isMet: hasLetter)
                            RequirementRow(text: "Contains a number", isMet: hasNumber)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section("Profile") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)

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
                        await authViewModel.signUp(email: email, password: password, firstName: firstName, lastName: lastName, location: location, country: country)
                        if authViewModel.isLoggedIn {
                            dismiss()
                        }
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Sign Up")
                    }
                }
                .disabled(!canSubmit)
            }
            .navigationTitle("Sign Up")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showCountryPicker) {
                CountryPicker(selectedCountry: $country)
            }
        }
=======
struct SignUpView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
>>>>>>> Stashed changes
    }
}

#Preview {
    SignUpView()
<<<<<<< Updated upstream
        .environmentObject(AuthViewModel())
=======
>>>>>>> Stashed changes
}
