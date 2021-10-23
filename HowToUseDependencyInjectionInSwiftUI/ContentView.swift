//
//  ContentView.swift
//  HowToUseDependencyInjectionInSwiftUI
//
//  Created by Ramill Ibragimov on 23.10.2021.
//

import SwiftUI
import Combine

struct PostModel: Identifiable, Codable {
    
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

class ProductionDataService {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func getData() -> AnyPublisher<[PostModel], Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data })
            .decode(type: [PostModel].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

class DependencyInjectionViewModel: ObservableObject {
    
    @Published var dataArray: [PostModel] = []
    var cancellables = Set<AnyCancellable>()
    
    let dataService: ProductionDataService
    
    init(dataService: ProductionDataService) {
        self.dataService = dataService
        loadPosts()
    }
    
    private func loadPosts() {
        dataService.getData()
            .sink { _ in
                
            } receiveValue: { [weak self] returnedPosts in
                self?.dataArray = returnedPosts
            }
            .store(in: &cancellables)

    }
    
}

struct ContentView: View {
    
    @StateObject private var vm: DependencyInjectionViewModel
    
    init(dataService: ProductionDataService) {
        _vm = StateObject(wrappedValue: DependencyInjectionViewModel(dataService: dataService))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(vm.dataArray) { post in
                    Text(post.title)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
    
    static var previews: some View {
        ContentView(dataService: dataService)
    }
}
