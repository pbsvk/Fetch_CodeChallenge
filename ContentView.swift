import SwiftUI

struct Item: Codable, Identifiable {
    let id: Int
    let listId: Int
    let name: String?
}

struct ContentView: View {
    @State private var items = [Item]()

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedItems.sorted(by: { $0.key < $1.key }), id: \.key) { key, itemsForList in
                    Section(header: Text("ListId: \(key)")) {
                        ForEach(itemsForList.sorted(by: { $0.name ?? "" < $1.name ?? "" })) { item in
                            if let name = item.name, !name.isEmpty {
                                Text(name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Lists")
        }
        .onAppear {
            fetchData()
        }
    }

    private var groupedItems: [Int: [Item]] {
        var groupedItems = [Int: [Item]]()
        for item in items {
            if let name = item.name, !name.isEmpty {
                groupedItems[item.listId, default: []].append(item)
            }
        }
        return groupedItems
    }

    private func fetchData() {
        guard let url = URL(string: "https://fetch-hiring.s3.amazonaws.com/hiring.json") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                let decoder = JSONDecoder()
                items = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
