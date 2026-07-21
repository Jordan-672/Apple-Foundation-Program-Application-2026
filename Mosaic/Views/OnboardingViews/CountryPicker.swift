//
//  CountryPicker.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 20/7/2026.
//

import SwiftUI

struct CountryPicker: View {
    @Binding var selectedCountry: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private static let allCountries: [String] = NSLocale.isoCountryCodes
        .compactMap { Locale.current.localizedString(forRegionCode: $0) }
        .sorted()

    private var filteredCountries: [String] {
        guard !searchText.isEmpty else { return Self.allCountries }
        return Self.allCountries.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredCountries, id: \.self) { country in
                Button {
                    selectedCountry = country
                    dismiss()
                } label: {
                    HStack {
                        Text(country)
                        Spacer()
                        if country == selectedCountry {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .foregroundStyle(.primary)
            }
            .searchable(text: $searchText, prompt: "Search countries")
            .navigationTitle("Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CountryPicker(selectedCountry: .constant(""))
}
