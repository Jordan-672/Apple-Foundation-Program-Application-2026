import SwiftUI

struct GroupView: View {
    let groupId: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = GroupViewModel()

    var body: some View {
        NavigationStack {
            if vm.isLoading {
                ProgressView("Loading group...")
            } else if let group = vm.group {
                VStack {
                    Text(group.description)
                        .font(.system(size: 15, weight: .bold))
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text(group.name.uppercased())
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(16)
                                    .padding()
                            }
                        }

                    AsyncImage(url: URL(string: group.coverImage)) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    List {
                        ForEach(vm.events) { event in
                            NavigationLink(destination: EventDetailsView(event: event)) {
                                VStack(alignment: .leading) {
                                    Text(event.title)
                                        .fontWeight(.bold)

                                    HStack {
                                        Text(event.location)
                                        Text(event.startAt.formatted(date: .abbreviated, time: .shortened))
                                    }
                                }
                            }
                        }

                        Button {
                            print("Create event tapped")
                        } label: {
                            HStack {
                                Text("Create a new event")
                                    .padding()
                                    .font(.headline)
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "plus")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.black)
                                    .cornerRadius(20)
                            }
                        }
                    }

                    Button {
                        Task {
                            await authViewModel.performIfLoggedIn {
                                guard let userId = authViewModel.currentUserId else { return }
                                try await GroupService().joinGroup(groupId: groupId, userId: userId)
                            }
                        }
                    } label: {
                        Text("Join the community")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(20)
                    }
                }
            } else {
                Text("Group not found.")
            }
        }
        .task {
            await vm.load(groupId: groupId)
        }
    }
}

