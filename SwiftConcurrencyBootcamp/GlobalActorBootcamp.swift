//
//  GlobalActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 11/09/25.
//

import SwiftUI

@globalActor final class MyFirstGlobalActor {
    static var shared = MyNewDataManager()
}


actor MyNewDataManager {
    
    func getDataFromDataBase() -> [String]{
        return ["One", "Two", "Three","Four","Five","Six"]
    }
    
}

@MainActor class GlobalActorBootcampViewModel: ObservableObject { //  we can declare a full class to run in the MainActor and mark as nonisolated funcs inside that we want to run in the global (backgorund)
    
    let manager = MyFirstGlobalActor.shared
    
   @Published var dataArray: [String] = [] // this affects the UI directly. so we declare @MAINACTOR
    
    // nonisolated
    @MyFirstGlobalActor func getData() { // we know we're are in the global actor and the Published variable is affecting the UI. Everytime we want UI we need to be in main actor.
        
        // LETS IMAGINE WE'RE DOING HEAVY COMPLEX METHODS HERE. A LOT OF TIMES WE DONT WANT THE MAIN THREAD TO BE CLOGGED DOWN WITH REALLY HEAVY COMPLEX TASKS.
        Task {
            let data = await manager.getDataFromDataBase()
            await MainActor.run {
                self.dataArray = data
            }
            
        }
        
    }
}

struct GlobalActorBootcamp: View {
    
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
    
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
            await viewModel.getData()
        }
    }
    
    
    
}

#Preview {
    GlobalActorBootcamp()
}
