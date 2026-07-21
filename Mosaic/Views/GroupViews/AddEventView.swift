//
//  AddEventView.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 21/7/2026.
//

import SwiftUI

struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    let groupId: String
    var onEventCreated: () -> Void

    @State private var title = ""
    @State private var location = ""
    @State private var description = ""
    @State private var coverImage = ""
    @State private var startAt = Date()
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var canSave: Bool {
        !title.isEmpty && !location.isEmpty && !isSaving
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event Name", text: $title)
                    TextField("Location", text: $location)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("When") {
                    DatePicker("Date & Time", selection: $startAt)
                }

                Section("Cover Image") {
                    TextField("Image URL", text: $coverImage)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                isSaving = true
                                errorMessage = nil
                                do {
                                    try await EventService().createEvent(
                                        groupId: groupId,
                                        title: title,
                                        description: description,
                                        location: location,
                                        startAt: startAt,
                                        coverImage: coverImage
                                    )
                                    onEventCreated()
                                    dismiss()
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                                isSaving = false
                            }
                        }
                        .disabled(!canSave)
                    }
                }
            }
        }
    }
}

#Preview {
    AddEventView(groupId: "preview-group") {}
}
