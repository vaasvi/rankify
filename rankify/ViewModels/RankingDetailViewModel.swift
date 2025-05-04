import Foundation
import FirebaseFirestore

@MainActor
class RankingDetailViewModel: ObservableObject {
    @Published var error: Error?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func likeRanking(_ ranking: Ranking) async {
        guard let rankingId = ranking.id else { return }
        
        do {
            try await db.collection("rankings").document(rankingId).updateData([
                "likes": FieldValue.increment(Int64(1))
            ])
        } catch {
            self.error = error
        }
    }
    
    func addComment(_ comment: String, to ranking: Ranking) async {
        guard let rankingId = ranking.id,
              let userId = Auth.auth().currentUser?.uid else { return }
        
        let newComment = Comment(
            id: UUID().uuidString,
            userId: userId,
            text: comment,
            createdAt: Date()
        )
        
        do {
            try await db.collection("rankings").document(rankingId).updateData([
                "comments": FieldValue.arrayUnion([try Firestore.Encoder().encode(newComment)])
            ])
        } catch {
            self.error = error
        }
    }
    
    func deleteRanking(_ ranking: Ranking) async {
        guard let rankingId = ranking.id else { return }
        
        do {
            try await db.collection("rankings").document(rankingId).delete()
        } catch {
            self.error = error
        }
    }
    
    func shareRanking(_ ranking: Ranking) {
        // TODO: Implement sharing functionality
    }
} 