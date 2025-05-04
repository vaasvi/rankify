import Foundation
import FirebaseFirestore
import FirebaseStorage

@MainActor
class CreateRankingViewModel: ObservableObject {
    @Published var error: Error?
    @Published var isLoading = false
    
    var draggedItem: RankingItem?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func createRanking(title: String, category: Ranking.Category, items: [RankingItem]) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Upload images first
            var updatedItems = items
            for (index, item) in items.enumerated() {
                if let imageData = item.imageData {
                    let imageURL = try await uploadImage(imageData)
                    updatedItems[index].imageURL = imageURL
                }
            }
            
            // Create ranking document
            let ranking = Ranking(
                title: title,
                category: category,
                items: updatedItems,
                userId: Auth.auth().currentUser?.uid ?? "",
                createdAt: Date(),
                updatedAt: Date(),
                likes: 0,
                comments: []
            )
            
            try await db.collection("rankings").addDocument(from: ranking)
        } catch {
            self.error = error
        }
    }
    
    private func uploadImage(_ imageData: Data) async throws -> String {
        let storageRef = storage.reference()
        let imageRef = storageRef.child("rankings/\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await imageRef.downloadURL()
        
        return downloadURL.absoluteString
    }
} 