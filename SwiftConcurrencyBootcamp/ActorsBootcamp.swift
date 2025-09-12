//
//  ActorsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 9/09/25.
//

import SwiftUI

// 1. What is the problem that actors are solving? Data race when try to access the same Heap memory. Is thread-safe.
// 2. How was this problem solved prior to actors?
// 3. Actors can solve the problem!

class MyDataManager {
    
    static let instance = MyDataManager()
    private init() {}
    
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.MyApp.MyDataManager") // queue
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
}

actor MyActorDataManager {
    
    static let instance = MyActorDataManager()
    private init() {}
    
    nonisolated let myRandomText = "Something"
    
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }
    
    nonisolated func getSavedData() -> String {
        
        return "New DATA"
    }
    
}


struct HomeView: View {
    
    let manager = MyActorDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
            
        }
        .onAppear(perform: {
            Task {
                let newString = manager.myRandomText
            }
        })
        
        .onReceive(timer) { _ in
            
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
            
            
//            DispatchQueue.global(qos: .background).async {
//                
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async{
//                            self.text = data
//                        }
//                        
//                    }
//                }
//            }
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.instance
    
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
            
            
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async{
//                            self.text = data
//                        }
//                        
//                    }
//                }
//            }
        }
    }
}


struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("Browse", systemImage: "magnifyingglass") {
                BrowseView()
            }
        
        }
    }
}

#Preview {
    ActorsBootcamp()
}
