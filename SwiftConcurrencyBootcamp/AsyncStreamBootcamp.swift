//
//  AsyncStreamBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 15/09/25.
//

import SwiftUI

class AsyncStreamDataManager {
    //we're simulating a stream of data coming to the app
    
    func getAsyncStream () -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { [weak self] continuation in
            self?.getFakeData(newValue: { value in
                continuation.yield(value)
            }, onFinish: { error in
                continuation.finish(throwing: error)
            })
        }
    }
    
    func getFakeData(newValue: @escaping (_ value: Int) -> (),
                     onFinish: @escaping (_ error: Error?) -> Void
    )  {
        let items: [Int] = [1,2,3,4,5,6,7,8,9,10]
        
        for item in items {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(item)) {
                newValue(item)
                print("New DATA: \(item)")
                if item == items.last {
                    onFinish(nil)
                }
            }
        }
    }
}


@MainActor
final class AsyncStreamViewModel: ObservableObject {
    
    let manager = AsyncStreamDataManager()
    @Published private(set) var currentNumber: Int = 0
    
    func onViewAppear() {
//        manager.getFakeData { [weak self] value in
//            self?.currentNumber = value
//        }
        
        let task = Task {
            do {
                for try await value in manager.getAsyncStream() /* .dropFirst to skip items */ {
                    currentNumber = value
                }
            } catch {
                print(error)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            task.cancel()
            print("TASK CANCELLED")
        })
    }
    
}

struct AsyncStreamBootcamp: View {
    
    @StateObject private var viewModel = AsyncStreamViewModel()
    
    var body: some View {
        Text("\(viewModel.currentNumber)")
            .onAppear {
                viewModel.onViewAppear()
            }
    }
}

#Preview {
    AsyncStreamBootcamp()
}
