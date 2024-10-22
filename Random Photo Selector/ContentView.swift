//
//  ContentView.swift
//  Random Photo Selector
//
//  Created by Gabriel Huke-Jenner on 01/05/2024.
//

import SwiftUI
import Photos
import CoreLocation

struct ContentView: View {
    @State private var randomImage: UIImage? = nil
    @State private var randomImageDate: String? = nil
    @State private var randomImageLocation: String? = nil


    var body: some View {
        NavigationView {
            VStack {
                    Spacer()
                if let image = randomImage {
                    Button(action: {
                        if let asset = self.getRandomAsset() {
                            self.openPhotoInPhotosApp(asset: asset)
                        }
                    }) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .frame(maxHeight: .infinity)

                    if let date = randomImageDate {
                        Text(date)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                        
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                    
                Spacer()

                Button("Select Random Photo") {
                    self.selectRandomPhoto()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            }
                
            .navigationTitle("Random Photo Viewer")
            .padding()
            .background(Color.black)
        }
    }

    private func selectRandomPhoto() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("Permission denied")
                return
            }

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            if fetchResult.count > 0 {
                let randomIndex = Int.random(in: 0..<fetchResult.count)
                let randomAsset = fetchResult.object(at: randomIndex)

                let imageManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true

                imageManager.requestImage(for: randomAsset, targetSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), contentMode: .aspectFill, options: requestOptions) { image, _ in
                    DispatchQueue.main.async {
                        self.randomImage = image
                        self.randomImageDate = self.getFormattedDate(from: randomAsset.creationDate)
                    }
                }
            }
        }
    }
    
    private func getFormattedDate(from date: Date?) -> String {
        guard let date = date else {
            return "Unknown Date"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy - HH:mm"
        return dateFormatter.string(from: date)
    }
        
    
    private func getRandomAsset() -> PHAsset? {
            guard randomImage != nil else {
            return nil
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResult.count > 0 {
            let randomIndex = Int.random(in: 0..<fetchResult.count)
            return fetchResult.object(at: randomIndex)
        }
        else {
            self.selectRandomPhoto()
        }
        
        return nil
    }
    
        private func openPhotoInPhotosApp(asset: PHAsset) {
            asset.requestContentEditingInput(with: nil) { (input, _) in
                guard let url = input?.fullSizeImageURL else {
                    print("Failed to get URL of the photo")
                    return
                }
                print("URL of the photo:", url)
                    UIApplication.shared.open(url)
            }
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
