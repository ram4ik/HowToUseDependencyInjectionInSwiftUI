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
    
    static let instance = ProductionDataService()
    
    let url: URL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    
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
    
    init() {
        loadPosts()
    }
    
    private func loadPosts() {
        ProductionDataService.instance.getData()
            .sink { _ in
                
            } receiveValue: { [weak self] returnedPosts in
                self?.dataArray = returnedPosts
            }
            .store(in: &cancellables)

    }
    
}

struct ContentView: View {
    
    @StateObject private var vm = DependencyInjectionViewModel()
    
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
    static var previews: some View {
        ContentView()
    }
}
