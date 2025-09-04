//
//  AsyncAwaitBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 4/09/25.
//

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    //DispatchQueue threading
    
    /*
    func addTitle1(){
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.dataArray.append("Title1 : \(Thread.current)")
        }
        
    }
    
    func addTitle2(){
        DispatchQueue.global().asyncAfter(deadline: .now()+2) {
            let title = "Title2 : \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
                let title3 = "Title3 : \(Thread.current)"
                self.dataArray.append(title3)
            }
        }
    }
    */
     
    
    func addTitleWithAsync() async {
        await MainActor.run {
            let newTitle = "Title with Async : \(Thread.current)"
            dataArray.append(newTitle)
        }

        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await MainActor.run {
            let author2 = "Author 2 : \(Thread.current)"
            self.dataArray.append(author2)
            let author3 = "Author 3 : \(Thread.current)"
            dataArray.append(author3)
        }
        
    }
    
    func addSomething() async {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let something2 = "Something 2 : \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(something2)
            let something3 = "Something 3 : \(Thread.current)"
            dataArray.append(something3)
        }
        
    }
    
}

struct AsyncAwaitBootcamp: View {
    
    @StateObject private var viewModel = AsyncAwaitBootcampViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear {
            Task {
                await viewModel.addTitleWithAsync()
                await viewModel.addSomething()
                
                let finalText = "Final TEXT: \(Thread.current)"
                viewModel.dataArray.append(finalText)
            }
        }
    }
    //        .onAppear {
    //            viewModel.addTitle1()
    //            viewModel.addTitle2()
    //        }
}

#Preview {
    AsyncAwaitBootcamp()
}
