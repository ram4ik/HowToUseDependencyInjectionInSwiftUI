//
//  HowToUseDependencyInjectionInSwiftUIApp.swift
//  HowToUseDependencyInjectionInSwiftUI
//
//  Created by Ramill Ibragimov on 23.10.2021.
//

import SwiftUI

@main
struct HowToUseDependencyInjectionInSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(dataService: ProductionDataService(url: URL(string: "https://jsonplaceholder.typicode.com/posts")!))
        }
    }
}
