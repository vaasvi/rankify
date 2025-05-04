import SwiftUI
import PhotosUI

struct CreateRankingView: View {
    @StateObject private var viewModel = CreateRankingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var selectedCategory: Ranking.Category = .movies
    @State private var items: [RankingItem] = []
    @State private var showingImagePicker = false
    @State private var selectedItem: RankingItem?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ranking Details")) {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Ranking.Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section(header: Text("Items")) {
                    ForEach(items) { item in
                        RankingItemRow(item: item)
                            .onDrag {
                                viewModel.draggedItem = item
                                return NSItemProvider(object: item.id as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(item: item, items: $items))
                    }
                    .onMove { from, to in
                        items.move(fromOffsets: from, toOffset: to)
                    }
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Label("Add Item", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Create Ranking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.createRanking(
                                title: title,
                                category: selectedCategory,
                                items: items
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || items.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                RankingItemFormView { newItem in
                    items.append(newItem)
                }
            }
        }
    }
}

struct RankingItemRow: View {
    let item: RankingItem
    
    var body: some View {
        HStack {
            if let imageURL = item.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 50, height: 50)
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                if let description = item.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("#\(item.position + 1)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: RankingItem
    @Binding var items: [RankingItem]
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let fromIndex = items.firstIndex(where: { $0.id == item.id }),
              let toIndex = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        if fromIndex != toIndex {
            withAnimation {
                let item = items.remove(at: fromIndex)
                items.insert(item, at: toIndex)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

struct RankingItemFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    let onSave: (RankingItem) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Image")) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let selectedImageData,
                           let uiImage = UIImage(data: selectedImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } else {
                            Label("Select Image", systemImage: "photo")
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let newItem = RankingItem(
                            id: UUID().uuidString,
                            title: title,
                            description: description.isEmpty ? nil : description,
                            imageURL: nil, // TODO: Upload image and get URL
                            rating: 0,
                            position: 0
                        )
                        onSave(newItem)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
}

#Preview {
    CreateRankingView()
} 