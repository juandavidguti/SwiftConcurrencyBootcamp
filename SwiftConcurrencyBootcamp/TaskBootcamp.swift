//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 4/09/25.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
//    @Published var array: [String] = []
    @Published var count: Int = 0
    @Published var isFinished: Bool = false
    
    func getDataForArray() async throws {
        do {
            print("Started 💛")
            for i in 0...19 {
                print(i)
                print(Thread.isMainThread)
                await MainActor.run {
//                    array.append(String(i))
                    count += 1
                    print(Thread.isMainThread)
                }
                try await Task.sleep(for: .seconds(1))
                try Task.checkCancellation()
            }
            await MainActor.run {
                isFinished = true
                print("Finished 🟢")
            }} catch is CancellationError {
                print("Aborted 🛑")
        }
    }
    
    
    func fetchImage() async throws {
        try? await Task.sleep(for: .seconds(5))
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {return}
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image = UIImage(data: data)
                print("Image returned successfully!")
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async throws {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {return}
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                self.image2 = UIImage(data: data)
                print("Image returned successfully!")
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationStack{
            ZStack {
                NavigationLink("Click me! 😊") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    
    @StateObject private var viewModel = TaskBootcampViewModel()
//    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: 200,height: 200)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200,height: 200)
            }
            //            List {
            //                Text(viewModel.array.joined(separator: ", "))
            //            }
            //                    .frame(height: 150)
            //                    .padding()
            if !viewModel.isFinished {
                let countText = viewModel.count.description
                withAnimation(.bouncy) {
                    Text(countText)
                        .font(.title)
                        .fontWeight(.semibold)
                }} else {
                    VStack(spacing: 20) {
                        Image(systemName: "flame.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.orange)
                            .padding()
                            .frame(width: 300,height: 300)
                        Text("YEEEESSSS!!")
                            .font(.title)
                    }
                }
        }
        .task {
            try? await viewModel.getDataForArray()
        }
        .task {
            try? await viewModel.fetchImage()
            try? await viewModel.fetchImage2()
            
        }
        //        .onDisappear {
        //            fetchImageTask?.cancel()
        //        }
        //        .onAppear {
        //            self.fetchImageTask = Task {
        //                await viewModel.fetchImage()
        //            }
        //            Task {
        //                print(Thread.current)
        //                print(Task.currentPriority)
        //                await viewModel.fetchImage2()
        //            }
        //            Task(priority: .high) {
        //                try? await Task.sleep(for: .seconds(2))
        //                await Task.yield()
        //                print("HIGH : \(Thread.current) : \(Task.currentPriority)")
        //            }
        //            Task(priority: .userInitiated) {
        //                print("USER INITIATED : \(Thread.current) : \(Task.currentPriority)")
        //            }
        //            Task(priority: .medium) {
        //                print("MEDIUM : \(Thread.current) : \(Task.currentPriority)")
        //            }
        //            Task(priority: .low) {
        //                print("LOW : \(Thread.current) : \(Task.currentPriority)")
        //            }
        //            Task(priority: .utility) {
        //                print("UTILITY : \(Thread.current) : \(Task.currentPriority)")
        //            }
        //            Task(priority: .background) {
        //                print("BACKGROUND : \(Thread.current) : \(Task.currentPriority)")
        //            }
        
        //            Task(priority: .low) {
        //                print("USER INITIATED : \(Thread.current) : \(Task.currentPriority)")
        //
        //                Task.detached {
        //                    print("detached : \(Thread.current) : \(Task.currentPriority)")
        //
        //                }
        
        //            }
        
//    }
    }
}

#Preview {
    TaskBootcamp()
}
