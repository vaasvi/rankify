import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack {
                        if let photoURL = authViewModel.user?.photoURL {
                            AsyncImage(url: URL(string: photoURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        Text(authViewModel.user?.displayName ?? "")
                            .font(.title2)
                            .bold()
                        
                        if let bio = authViewModel.user?.bio {
                            Text(bio)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        HStack(spacing: 40) {
                            VStack {
                                Text("\(authViewModel.user?.followers.count ?? 0)")
                                    .font(.headline)
                                Text("Followers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(authViewModel.user?.following.count ?? 0)")
                                    .font(.headline)
                                Text("Following")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                    
                    // User's Rankings
                    VStack(alignment: .leading) {
                        Text("My Rankings")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else if viewModel.rankings.isEmpty {
                            Text("No rankings yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(viewModel.rankings) { ranking in
                                NavigationLink(destination: RankingDetailView(ranking: ranking)) {
                                    RankingCard(ranking: ranking)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        // TODO: Show edit profile sheet
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        try? authViewModel.signOut()
                    }
                }
            }
            .task {
                await viewModel.fetchUserRankings()
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
} 