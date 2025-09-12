//
//  MVVMBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 11/09/25.
//

import SwiftUI

final class MyManagerClass {
    
    func getData() async throws -> String {
        "Some Data"
    }
    
}

actor MyManagerActor {
    func getData() async throws -> String {
        "Some Data"
    }
}

// Normally the ViewModel updates the view and everything that updates the view shouldb e in MainActor. Going to other actors and returning will be doing automatically.
@MainActor
final class MVVMBootcampViewModel: ObservableObject {
    let managerClass = MyManagerClass()
    let managerActor = MyManagerActor()
    
    @Published private(set) var myData: String = "Starting text"
    private var tasks: [Task<Void, Never>] = []
    
    func cancelTasks() {
        tasks.forEach({ $0.cancel() })
        tasks = []
    }
    
    func onCallToActionButtonPressed() {
        let task = Task {
            do {
//                myData = try await managerClass.getData()
                myData = try await managerActor.getData()
            } catch {
                print(error)
            }
        }
        tasks.append(task)
    }
    
}

struct MVVMBootcamp: View {
    
    @StateObject private var viewModel = MVVMBootcampViewModel()
    
    var body: some View {
        
        VStack {
            Button(viewModel.myData) {
                viewModel.onCallToActionButtonPressed()
            }
            
        }
        .onDisappear{
            
        }
    }
}

#Preview {
    MVVMBootcamp()
}
