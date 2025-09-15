//
//  ObservableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 15/09/25.
//

import SwiftUI

actor TitleDataBase {
    func getNewTitle() -> String {
        "Some new title"
    }
}

@Observable class ObservableViewModel {
//class ObservableViewModel: ObservableObject { // the purple warning about threading issue comes from this protocol
    
    @ObservationIgnored let database = TitleDataBase()
    @MainActor var title: String = "Starting Title"
    
    // @MainActor -> One way to solve the issue of publishing from a background thread. As Devs. UI Changes are always from the main thread
    func updateTitle() async {
        
        // This is the second way to solve it. To put Main Actor in a Task and make a regular function.
//        Task { @MainActor in
//            title = await database.getNewTitle()
//            print(Thread.current)
//        }
        
        
        // The third way to solve this.
        await MainActor.run {
            self.title = title
            print(Thread.current)
        }
    }
    
}

struct ObservableBootcamp: View {
    
//    @StateObject private var viewModel = ObservableViewModel()
    @State private var viewModel = ObservableViewModel()
    
    var body: some View {
        Text(viewModel.title)
            .task{
               await viewModel.updateTitle()
            }
    }
}

#Preview {
    ObservableBootcamp()
}
