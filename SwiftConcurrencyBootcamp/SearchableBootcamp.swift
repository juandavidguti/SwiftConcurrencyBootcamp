//
//  SearchableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 12/09/25.
//

import SwiftUI
import Combine

struct Restaurant: Identifiable, Hashable {
    let id: String
    let title: String
    let cuisine: CuisineOption
}


enum CuisineOption: String {
    case american, italian, japanese
}

final class RestaurantManager {
    func getAllRestaurants() async throws -> [Restaurant] {
        [
            Restaurant(id: "1", title: "Burger Shack", cuisine: .american),
            Restaurant(id: "2", title: "Pasta Palace", cuisine: .italian),
            Restaurant(id: "3", title: "Sushi Heaven", cuisine: .japanese),
            Restaurant(id: "4", title: "Local Market", cuisine: .american),
        ]
    }
}

@MainActor
final class SearchableViewModel: ObservableObject {
    
    
    @Published private(set) var allRestaurants: [Restaurant] = []
    @Published private(set) var filteredRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var searchScope: SearchScopeOption = .all
    @Published private(set) var allSearchScopes: [SearchScopeOption] = []
    
    
    let manager = RestaurantManager()
    private var cancellables = Set<AnyCancellable>()
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    
    var showSearchSuggestions: Bool {
        searchText.count < 5
    }
    
    enum SearchScopeOption: Hashable {
        case all
        case cuisine(option: CuisineOption)
        
        var title: String {
            switch self {
                case .all:
                    return "All"
                case .cuisine(option: let option):
                    return option.rawValue.capitalized
            }
        }
    }
    
    
    init() {
        addSubscribers()
    }
    
    func loadRestaurants() async {
        do {
            allRestaurants = try await manager.getAllRestaurants()
            
            let allCuisines = Set(allRestaurants.map { $0.cuisine })
            allSearchScopes = [.all] + allCuisines.map ({ SearchScopeOption.cuisine(option: $0) })
        } catch {
            print(error)
        }
    }
    
    // we could use async algorithm package for debounce. we will use Combine instead.
    
    private func addSubscribers() {
        $searchText
            .combineLatest($searchScope) // we are listening to both for the filters
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .sink {
                [weak self] searchValue,
                searchScope in
                self?.filterRestaurants(searchValue: searchValue,currentSearchScope: searchScope)
            }
            .store(in: &cancellables)
    }
    
    private func filterRestaurants(searchValue: String, currentSearchScope: SearchScopeOption) {
        guard !searchValue.isEmpty else {
            filteredRestaurants = []
            self.searchScope = .all
            return
        }
        
        // Filter on Search Scope
        var restaurantsInScope = allRestaurants
        switch currentSearchScope {
            case .all:
                break
            case .cuisine(option: let option):
                restaurantsInScope = allRestaurants.filter({ $0.cuisine == option })
        }
        
        
        // Filter on search Text
        let search = searchValue.lowercased()
        filteredRestaurants = restaurantsInScope.filter({ restaurant in
            let titleContainsSearch = restaurant.title.lowercased().contains(search)
            let cuisineContainSearch = restaurant.cuisine.rawValue.lowercased().contains(search)
            return titleContainsSearch || cuisineContainSearch
        })
    }
    
    func getSearchSuggestions() -> [String] {
        guard showSearchSuggestions else { return [] }
        
        var suggestions: [String] = []
        
        let search = searchText.lowercased()
        if search.contains("pa") {
            suggestions.append("Pasta")
        }
        if search.contains("su") {
            suggestions.append("Sushi")
        }
        if search.contains("bu") {
            suggestions.append("Burger")
        }
        
        suggestions.append("Market")
        suggestions.append("Grocery")
        
        suggestions.append(CuisineOption.italian.rawValue.capitalized)
        suggestions.append(CuisineOption.japanese.rawValue.capitalized)
        suggestions.append(CuisineOption.american.rawValue.capitalized)
        
        return suggestions
    }
    
    func getRestaurantSuggestions() -> [Restaurant] {
        guard showSearchSuggestions else { return [] }
        
        var suggestions: [Restaurant] = []
        
        let search = searchText.lowercased()
        if search.contains("ita") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .italian}))
            
        }
        if search.contains("jap") {
            suggestions.append(contentsOf: allRestaurants.filter({ $0.cuisine == .japanese}))
        }
        
        return suggestions
    }
    
    
}


struct SearchableBootcamp: View {
    
    @StateObject private var viewModel = SearchableViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(
                    viewModel.isSearching ? viewModel.filteredRestaurants
                    : viewModel.allRestaurants) { restaurant in
                        NavigationLink(value: restaurant) {
                            restaurantRow(restaurant: restaurant)
                        }
                        
                    }
            }
            .padding()
            
            //            Text("View Model is searching: \(viewModel.isSearching.description)")
            //            SearchChildView()
            
        }
        
        .searchable(text: $viewModel.searchText,placement: .automatic,prompt: "Search restaurants...")
        .searchScopes($viewModel.searchScope, scopes: {
            ForEach(viewModel.allSearchScopes, id: \.self) { scope in
                Text(scope.title)
                    .tag(scope)
            }
        })
        
        
        .searchSuggestions(
            {
                ForEach(viewModel.getSearchSuggestions(), id: \.self) { suggestion in
                    Text(suggestion)
                        .searchCompletion(suggestion)
                }
                ForEach(viewModel.getRestaurantSuggestions(), id: \.self) { suggestion in
                    NavigationLink(value: suggestion) {
                        Text(suggestion.title)
                    }
                }
            })
        
        
        //        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Restaurants")
        .task {
            await viewModel.loadRestaurants()
        }
        .navigationDestination(for: Restaurant.self) { restaurant in
            Text(restaurant.title.uppercased())
        }
    }
    
    private func restaurantRow(restaurant: Restaurant) -> some View {
        VStack (alignment: .leading, spacing: 10) {
            Text(restaurant.title)
                .font(.headline)
                .foregroundStyle(.red)
            Text(restaurant.cuisine.rawValue.capitalized)
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.05))
        .tint(.primary)
    }
    
}

struct SearchChildView: View {
    
    @Environment(\.isSearching) private var isSearching
    
    var body: some View {
        Text("Child view is searching: \(isSearching.description)")
    }
}


#Preview {
    NavigationStack {
        SearchableBootcamp()
    }
}
