import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var error: Error?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.fetchUser(userId: user.uid)
            } else {
                self.user = nil
                self.isAuthenticated = false
            }
        }
    }
    
    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.noIdToken
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                     accessToken: result.user.accessToken.tokenString)
        
        try await auth.signIn(with: credential)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    private func fetchUser(userId: String) {
        Task {
            do {
                let document = try await db.collection("users").document(userId).getDocument()
                if let user = try? document.data(as: User.self) {
                    self.user = user
                    self.isAuthenticated = true
                } else {
                    // Create new user if doesn't exist
                    try await createNewUser(userId: userId)
                }
            } catch {
                self.error = error
            }
        }
    }
    
    private func createNewUser(userId: String) async throws {
        guard let firebaseUser = auth.currentUser else { return }
        
        let newUser = User(
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName ?? "",
            photoURL: firebaseUser.photoURL?.absoluteString,
            followers: [],
            following: [],
            favoriteCategories: [],
            createdAt: Date(),
            lastActive: Date()
        )
        
        try await db.collection("users").document(userId).setData(from: newUser)
        self.user = newUser
        self.isAuthenticated = true
    }
}

enum AuthError: Error {
    case noRootViewController
    case noIdToken
} 