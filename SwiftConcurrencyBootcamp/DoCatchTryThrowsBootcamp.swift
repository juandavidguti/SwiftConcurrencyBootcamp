//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 1/09/25.
//

import SwiftUI

// do catch
// try
// throws

class DoCatchTryThrowsBootcampDataManager {
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("NEW TEXT!", nil)
        } else {
            return (nil, URLError(.badURL))
        }
        
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New TEXT!!")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle3() throws -> String {
//        if isActive {
//            return "New Text"
//        } else {
            throw URLError(.badServerResponse)
//        }
    }
    
    func getTitle4() throws -> String {
        if isActive {
            return "Final Text"
        } else {
            throw URLError(.badURL)
        }
    }
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject {
    
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    @Published var text: String = "Starting Text..."
    
    func fetchTitle(){
        /*
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error {
            self.text = error.localizedDescription
        }
         */
        /*
        let result = manager.getTitle2()
        switch result {
            case .success(let newTitle):
                self.text = newTitle
            case .failure(let error):
                self.text = error.localizedDescription
        }
         */
        
//        let newTitle = try? manager.getTitle3()
//        if let newTitle = newTitle {
//            self.text = newTitle
//        }
        
        do {
            let newTitle = try? manager.getTitle3()
            if let newTitle = newTitle {
                self.text = newTitle
            }
            let finalTitle = try manager.getTitle4()
            self.text = finalTitle
        } catch let error {
            self.text = error.localizedDescription
        }
        
    }
    
}

struct DoCatchTryThrowsBootcamp: View {
    
    @StateObject private var viewmodels = DoCatchTryThrowsBootcampViewModel()
    
    var body: some View {
        Text(viewmodels.text)
            .frame(width: 300,height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewmodels.fetchTitle()
            }
    }
}

#Preview {
    DoCatchTryThrowsBootcamp()
}
