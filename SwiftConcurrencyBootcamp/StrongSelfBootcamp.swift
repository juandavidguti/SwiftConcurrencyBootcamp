//
//  StrongSelfBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 11/09/25.
//

import SwiftUI

final class StrongSelfDataService {
    func getData() async -> String {
        "Updated data"
    }
}

final class StrongSelfBootcampViewModel: ObservableObject {
    
    @Published var data: String = "some title"
    let dataService = StrongSelfDataService()
    
    private var someTask: Task<Void, Never>? = nil
    private var myTasks: [Task<Void, Never>] = []
    
    func cancelTask() {
        someTask?.cancel()
        someTask = nil
        
        myTasks.forEach({ $0.cancel()})
        myTasks = []
    }
    
    // This implies a strong reference...
    func updateData() {
        Task {
            data = await dataService.getData()
        }
    }
    
    // This IS a strong reference... putting self just to refer to different parameter
    func updateData2() {
        Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // This IS a strong reference...
    func updateData3() {
        Task { [self] in
            self.data = await self.dataService.getData()
        }
    }
    
    // this is a weak reference
    func updateData4() {
        Task { [weak self] in
            if let data = await self?.dataService.getData() {
                self?.data = data
            }
        }
    }
    
    // WE don't need to manage weak/strong
    // Because we can manage the Task!
    func updateData5() {
        someTask = Task {
            self.data = await self.dataService.getData()
        }
    }
    
    // We can manage the task at task level
    func updateData6() {
        let task1 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task1)
        let task2 = Task {
            self.data = await self.dataService.getData()
        }
        myTasks.append(task2)
    }
    
    // We purposely do not cancel to keep strong references
    func updateData7() {
        Task {
            self.data = await self.dataService.getData()
        }
        Task.detached {
                self.data = await self.dataService.getData()
            }
    }
    func updateData8() async {
            self.data = await self.dataService.getData()
    }
    
}

// .task cancel tasks in Views but in View models probably is better to do the methods above.
struct StrongSelfBootcamp: View {
    
    @StateObject private var viewModel = StrongSelfBootcampViewModel()
    
    var body: some View {
        Text(viewModel.data)
            .onAppear{
                viewModel.updateData()
            }
            .onDisappear{
                viewModel.cancelTask()
            }
            .task {
                await viewModel.updateData8()
            }
    }
}

#Preview {
    StrongSelfBootcamp()
}
