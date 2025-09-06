//
//  TaskGroupBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 5/09/25.
//

import SwiftUI


class TaskGroupBootcampDataManager {
    
    let url: String = "https://picsum.photos/200"

    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
            async let fetchImage1 = fetchImage(urlString: url)
            async let fetchImage2 = fetchImage(urlString: url)
            async let fetchImage3 = fetchImage(urlString: url)
            async let fetchImage4 = fetchImage(urlString: url)
            
            let (image1, image2, image3, image4) = try await (fetchImage1,fetchImage2, fetchImage3, fetchImage4)
            return [image1, image2, image3, image4]
    }
    
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
        let urlStrings = ["https://picsum.photos/200","https://picsum.photos/200","https://picsum.photos/200","https://picsum.photos/200","https://picsum.photos/200","https://picsum.photos/200"]
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            images.reserveCapacity(urlStrings.count) //pro tip to reserve memory when arrays size is unknown. best practice
            
            for urlString in urlStrings {
                group.addTask {
                    try? await self.fetchImage(urlString: urlString)
                }
            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
    
    private func fetchImage(urlString: String) async throws -> UIImage {
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject {
    
    let manager = TaskGroupBootcampDataManager()
    
    @Published var images: [UIImage] = []
    
    func getImages() async {
        
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }

}

struct TaskGroupBootcamp: View {
    
    @StateObject private var viewModel = TaskGroupBootcampViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group 🥳")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

#Preview {
    TaskGroupBootcamp()
}
