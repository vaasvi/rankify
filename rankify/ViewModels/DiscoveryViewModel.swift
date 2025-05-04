import Foundation
import FirebaseFirestore

@MainActor
class DiscoveryViewModel: ObservableObject {
    @Published var rankings: [Ranking] = []
    @Published var error: Error?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    private var lastDocument: DocumentSnapshot?
    private let pageSize = 10
    
    func fetchRankings() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let query = db.collection("rankings")
                .order(by: "createdAt", descending: true)
                .limit(to: pageSize)
            
            let snapshot = try await query.getDocuments()
            rankings = snapshot.documents.compactMap { try? $0.data(as: Ranking.self) }
            lastDocument = snapshot.documents.last
        } catch {
            self.error = error
        }
    }
    
    func loadMoreRankings() async {
        guard let lastDocument = lastDocument else { return }
        
        do {
            let query = db.collection("rankings")
                .order(by: "createdAt", descending: true)
                .start(afterDocument: lastDocument)
                .limit(to: pageSize)
            
            let snapshot = try await query.getDocuments()
            let newRankings = snapshot.documents.compactMap { try? $0.data(as: Ranking.self) }
            rankings.append(contentsOf: newRankings)
            self.lastDocument = snapshot.documents.last
        } catch {
            self.error = error
        }
    }
    
    func searchRankings(query: String) async {
        guard !query.isEmpty else {
            await fetchRankings()
            return
        }
        
        do {
            let snapshot = try await db.collection("rankings")
                .whereField("title", isGreaterThanOrEqualTo: query)
                .whereField("title", isLessThanOrEqualTo: query + "\u{f8ff}")
                .getDocuments()
            
            rankings = snapshot.documents.compactMap { try? $0.data(as: Ranking.self) }
        } catch {
            self.error = error
        }
    }
    
    func filterByCategory(_ category: Ranking.Category?) async {
        guard let category = category else {
            await fetchRankings()
            return
        }
        
        do {
            let snapshot = try await db.collection("rankings")
                .whereField("category", isEqualTo: category.rawValue)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            rankings = snapshot.documents.compactMap { try? $0.data(as: Ranking.self) }
        } catch {
            self.error = error
        }
    }
    
    func likeRanking(_ ranking: Ranking) async {
        guard let rankingId = ranking.id else { return }
        
        do {
            try await db.collection("rankings").document(rankingId).updateData([
                "likes": FieldValue.increment(Int64(1))
            ])
            
            if let index = rankings.firstIndex(where: { $0.id == rankingId }) {
                var updatedRanking = ranking
                updatedRanking.likes += 1
                rankings[index] = updatedRanking
            }
        } catch {
            self.error = error
        }
    }
} 