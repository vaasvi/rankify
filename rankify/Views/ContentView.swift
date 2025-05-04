import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                AuthView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            DiscoveryView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
            
            CreateRankingView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Welcome to Rankify")
                .font(.largeTitle)
                .bold()
            
            Text("Create and share your rankings with friends")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button {
                Task {
                    isLoading = true
                    do {
                        try await authViewModel.signInWithGoogle()
                    } catch {
                        print("Error signing in: \(error)")
                    }
                    isLoading = false
                }
            } label: {
                HStack {
                    Image("google_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text("Sign in with Google")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
} 