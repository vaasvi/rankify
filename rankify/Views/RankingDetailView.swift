import SwiftUI

struct RankingDetailView: View {
    let ranking: Ranking
    @StateObject private var viewModel = RankingDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(ranking.title)
                        .font(.title)
                        .bold()
                    
                    HStack {
                        Text(ranking.category.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button {
                                Task {
                                    await viewModel.likeRanking(ranking)
                                }
                            } label: {
                                Label("\(ranking.likes)", systemImage: "heart.fill")
                                    .foregroundColor(.red)
                            }
                            
                            Button {
                                // TODO: Show comments sheet
                            } label: {
                                Label("\(ranking.comments.count)", systemImage: "bubble.right.fill")
                            }
                        }
                    }
                }
                .padding()
                
                // Items List
                VStack(spacing: 16) {
                    ForEach(Array(ranking.items.enumerated()), id: \.element.id) { index, item in
                        RankingItemDetailRow(item: item, position: index + 1)
                    }
                }
                .padding()
                
                // Comments Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Comments")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if ranking.comments.isEmpty {
                        Text("No comments yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(ranking.comments) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteRanking(ranking)
                            dismiss()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

struct RankingItemDetailRow: View {
    let item: RankingItem
    let position: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Position Badge
            Text("#\(position)")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.blue)
                .clipShape(Circle())
            
            // Item Image
            if let imageURL = item.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            }
            
            // Item Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                
                if let description = item.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(item.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.userId) // TODO: Replace with actual username
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                Text(comment.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.text)
                .font(.body)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationView {
        RankingDetailView(ranking: Ranking(
            title: "Top Movies 2024",
            category: .movies,
            items: [
                RankingItem(
                    id: "1",
                    title: "Movie 1",
                    description: "Description 1",
                    imageURL: nil,
                    rating: 4.5,
                    position: 0
                )
            ],
            userId: "user1",
            createdAt: Date(),
            updatedAt: Date(),
            likes: 10,
            comments: []
        ))
    }
} 