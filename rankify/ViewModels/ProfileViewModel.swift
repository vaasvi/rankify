import Foundation
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var rankings: [Ranking] = []
    @Published var error: Error?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func fetchUserRankings() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection("rankings")
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            rankings = snapshot.documents.compactMap { try? $0.data(as: Ranking.self) }
        } catch {
            self.error = error
        }
    }
    
    func updateProfile(bio: String, favoriteCategories: [Ranking.Category]) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(userId).updateData([
                "bio": bio,
                "favoriteCategories": favoriteCategories.map { $0.rawValue }
            ])
        } catch {
            self.error = error
        }
    }
    
    func followUser(_ userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(currentUserId).updateData([
                "following": FieldValue.arrayUnion([userId])
            ])
            
            try await db.collection("users").document(userId).updateData([
                "followers": FieldValue.arrayUnion([currentUserId])
            ])
        } catch {
            self.error = error
        }
    }
    
    func unfollowUser(_ userId: String) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection("users").document(currentUserId).updateData([
                "following": FieldValue.arrayRemove([userId])
            ])
            
            try await db.collection("users").document(userId).updateData([
                "followers": FieldValue.arrayRemove([currentUserId])
            ])
        } catch {
            self.error = error
        }
    }
} 