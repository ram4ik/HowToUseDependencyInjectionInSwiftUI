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

protocol DataServiceProtocol {
    
    func getData() -> AnyPublisher<[PostModel], Error>
}

class ProductionDataService: DataServiceProtocol {
    
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

class MockDataService: DataServiceProtocol {
    
    let testData: [PostModel]
    
    init(data: [PostModel]?) {
        self.testData = data ?? [
            PostModel(userId: 1, id: 1, title: "One", body: "One"),
            PostModel(userId: 2, id: 2, title: "Two", body: "Two"),
        ]
    }
    
    func getData() -> AnyPublisher<[PostModel], Error> {
        Just(testData)
            .tryMap({ $0 })
            .eraseToAnyPublisher()
    }
    
}

class DependencyInjectionViewModel: ObservableObject {
    
    @Published var dataArray: [PostModel] = []
    var cancellables = Set<AnyCancellable>()
    
    let dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
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
    
    init(dataService: DataServiceProtocol) {
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
    
    static let mockDataService = MockDataService(data: nil)
    static let someMockDataService = MockDataService(data: [PostModel(userId: 3, id: 3, title: "Mock Title", body: "Mock Body")])
    
    static let dataService = ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!)
    
    static var previews: some View {
        
        Group {
            ContentView(dataService: mockDataService)
            ContentView(dataService: someMockDataService)
            
            ContentView(dataService: dataService)
        }
    }
}
