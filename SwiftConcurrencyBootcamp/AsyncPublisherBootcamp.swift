//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 11/09/25.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Banana")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Orange")
        try? await Task.sleep(for: .seconds(2))
        myData.append("Watermelon")
        
    }
    
}


class AsyncPublisherBootcampViewModel: ObservableObject {
    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        
        // NEW Async method instead of Combine for publishers and listeners
        Task {
            
            await MainActor.run {
                self.dataArray = ["ONE"]
            }
            
            // this for will wait for ever (listens to asynchronous values) for the values. To use break otherwise further code won't execute
            for await value in manager.$myData.values { // .values with the money sign to  access publisher
                await MainActor.run {
                    self.dataArray = value
                }
                // break
            }
            // we need to break it to be able to see the TWO
            
            await MainActor.run {
                self.dataArray = ["TWO"]
            }
            
        }
        //adding another task will help not to depend on the looop to end in the task above unless we dont use break.
        
//        Task {
//            for await value in manager.$myData.values {
//                await MainActor.run {
//                    self.dataArray = value
//                }
//                break
//            }
//        }
        
        // Combine method OLD METHOD
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
    }
    
    func start() async {
        await manager.addData()
    }
    
}

struct AsyncPublisherBootcamp: View {
    
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBootcamp()
}
