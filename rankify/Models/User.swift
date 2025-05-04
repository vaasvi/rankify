import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let email: String
    let displayName: String
    let photoURL: String?
    var bio: String?
    var followers: [String]
    var following: [String]
    var favoriteCategories: [Ranking.Category]
    let createdAt: Date
    var lastActive: Date
    
    var isProfileComplete: Bool {
        !displayName.isEmpty && photoURL != nil
    }
} 