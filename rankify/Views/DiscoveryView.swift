import SwiftUI

struct DiscoveryView: View {
    @StateObject private var viewModel = DiscoveryViewModel()
    @State private var selectedCategory: Ranking.Category?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Ranking.Category.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                action: {
                                    withAnimation {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Rankings List
                List {
                    ForEach(viewModel.rankings) { ranking in
                        NavigationLink(destination: RankingDetailView(ranking: ranking)) {
                            RankingCard(ranking: ranking)
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.fetchRankings()
                }
            }
            .navigationTitle("Discover")
            .searchable(text: $searchText, prompt: "Search rankings")
            .onChange(of: searchText) { _ in
                Task {
                    await viewModel.searchRankings(query: searchText)
                }
            }
            .onChange(of: selectedCategory) { _ in
                Task {
                    await viewModel.filterByCategory(selectedCategory)
                }
            }
            .task {
                await viewModel.fetchRankings()
            }
        }
    }
}

struct CategoryButton: View {
    let category: Ranking.Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct RankingCard: View {
    let ranking: Ranking
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(ranking.title)
                    .font(.headline)
                Spacer()
                Text(ranking.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            if let firstItem = ranking.items.first {
                HStack {
                    if let imageURL = firstItem.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(firstItem.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        if let description = firstItem.description {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
            }
            
            HStack {
                Label("\(ranking.likes)", systemImage: "heart.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label("\(ranking.comments.count)", systemImage: "bubble.right.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    DiscoveryView()
} 