import Foundation
import FirebaseFirestoreSwift

struct Ranking: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let category: Category
    let items: [RankingItem]
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    var likes: Int
    var comments: [Comment]
    
    enum Category: String, Codable, CaseIterable {
        case movies = "Movies"
        case tvShows = "TV Shows"
        case music = "Music"
        case books = "Books"
        case games = "Games"
        case restaurants = "Restaurants"
        case other = "Other"
    }
}

struct RankingItem: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let imageURL: String?
    let rating: Double
    let position: Int
}

struct Comment: Identifiable, Codable {
    let id: String
    let userId: String
    let text: String
    let createdAt: Date
} 