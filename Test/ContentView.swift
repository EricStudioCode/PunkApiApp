//
//  ContentView.swift
//  BeerApiTest
//
//  Created by Eric  on 17.05.23.
//

import SwiftUI

struct URLImage: View {
    let urlString: String
    
    @State var data: Data?
    
    var body: some View {
        if let data = data, let uiimage = UIImage(data: data) {
            Image(uiImage: uiimage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .background(Color.gray)
            
        }
        else {
            Image("")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70).background(Color.gray)
                .onAppear{
                fetchData()            }
        }
    }
        private func fetchData(){
            guard let url = URL(string: urlString) else {
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) {
                data, _, _ in self.data = data
            }
            task.resume()
        }
}


struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    @State private var searchText = ""
    
    var searchResults: [Beer] {
        if searchText.isEmpty {
            return viewModel.beers
        } else {
            let filteredId = viewModel.beers.filter { String($0.id) == (searchText) }
            return filteredId.isEmpty ? viewModel.beers : filteredId
        }
    }
    
    var body: some View {
            NavigationView{
                List{
                    ForEach(searchResults, id: \.self) {
                        beer in
                        HStack{
                            URLImage(urlString: beer.image_url)
                            
                            Text("\(beer.name)\nID:\(beer.id)")
                            
                            NavigationLink(destination: HStack{
                                URLImage(urlString: beer.image_url)
                                let testLines =  "Name: \(beer.name)\nDescription:  \(beer.description)\nVolume: \(beer.volume.value) \(beer.volume.unit)\nFood Pairing: \(beer.food_pairing) "
                                Text(testLines)
                                
                            }.padding(10), label: {Text("")})
                        }
                        .padding(5)
                    }
                }
                .navigationTitle("Beer")
                .onAppear{
                    viewModel.fetch()
                }
                .searchable(text: $searchText, prompt: "id")
            }
        }
    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class ViewModel: ObservableObject {
    @Published var beers: [Beer] = []
    
    func fetch(){
        guard let url = URL(string: "https://api.punkapi.com/v2/beers") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _,
            error in
            guard let data = data, error == nil else {
                return
            }
            
            do{
                let beers = try JSONDecoder().decode([Beer].self, from: data)
                DispatchQueue.main.async {
                    self?.beers = beers
                    print(beers[0].name)
                }
            }
            catch {
                print("error")
            }
            
        }
        task.resume()
    }
}


struct Beer: Hashable, Codable {
    var id: Int
    var name: String
    var image_url: String
    var description : String
    var volume: VolumeData
    var food_pairing: [String]
    
    struct VolumeData: Hashable, Codable{
        var value: Int
        var unit: String
    }
}




