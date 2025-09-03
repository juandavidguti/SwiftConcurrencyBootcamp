//
//  DownloadImageAsync.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Juan David Gutierrez Olarte on 3/09/25.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
        
    let url = URL(string: "https://picsum.photos/200")!
    
    private var isActive: Bool = true
    
    func handleResponse(data:Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            200...299 ~= response.statusCode else {return nil}
        return image
    }
    
    
    func downloadWithEscaping(
        completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()
    ) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            let image = self?.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
        
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
    
    func getData() throws -> (text: String, image: UIImage?) {
        if isActive {
            return ("hola",UIImage(systemName: "heart.fill"))
        } else {
            throw URLError(.unknown)
        }
        
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var text: String? = nil
    @Published var image: UIImage? = nil
    @Published var imageFromInternet: UIImage? = nil
    private var cancellable: Set<AnyCancellable> = []
    let loader = DownloadImageAsyncImageLoader()
    
    
    
    func fetchData() {
        do {
            let newData = try loader.getData()
            self.text = newData.text
            self.image = newData.image
        } catch let error {
            self.text = error.localizedDescription
        }
    }
    
    func fetchImage() async {
        /*
//        loader.downloadWithEscaping { [weak self] image, error in
//            DispatchQueue.main.async {
//                self?.imageFromInternet = image
//                self?.text = error?.localizedDescription
//            }
//        }
//        loader.downloadWithCombine()
//            .receive(on: DispatchQueue.main)
//            .sink { _ in
//                
//            } receiveValue: { [weak self] returnedImage in
//                self?.imageFromInternet = returnedImage
//            }
//            .store(in: &cancellable)
         */
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
    
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                if let image2 = viewModel.imageFromInternet {
                    Image(uiImage: image2)
                        .resizable()
                        .frame(width: 250, height: 250)
                }
                if let image = viewModel.image{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                }
                if let text = viewModel.text {
                    Text(text)
                        .foregroundStyle(.black)
                }
                Button("Fetch text") {
                    viewModel.fetchData()
                }
            }
        }
        .onAppear {
//            viewModel.fetchImage()
            Task {
                await viewModel.fetchImage()
            }
        }
    }

}

#Preview {
    DownloadImageAsync()
}
