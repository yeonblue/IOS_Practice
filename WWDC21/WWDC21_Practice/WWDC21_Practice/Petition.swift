//
//  Petition.swift
//  WWDC21_Practice
//
//  Created by yeonBlue on 2022/04/02.
//

import SwiftUI

struct PetitionModel: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    
    let signatureCount: Int
    let signatureThreshold: Int
}

struct PetitionDetailView: View {
    let petition: PetitionModel
    
    var body: some View {
        ScrollView {
            Text(petition.title)
                .font(.title)
            
            Text(petition.body)
                .padding()
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline) // autoamtic 앞의 뷰를 그대로 상속
        
    }
}

struct PetitionView: View {
    
    @State var petitions = [PetitionModel]()
    
    var body: some View {
        NavigationView {
            List(petitions) { petition in
                NavigationLink(destination: PetitionDetailView(petition: petition)) {
                    VStack(alignment: .leading) {
                        Text(petition.title)
                        HStack {
                            Spacer()
                            Text("\(petition.signatureCount)/\(petition.signatureThreshold)")
                                .font(.caption)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Petitions")
            .task {
                do {
                    let url = URL(string: "https://hws.dev/petitions.json")!
                    let data = try await URLSession.shared.decode([PetitionModel].self, from: url)
                    petitions = data.sorted { $0.signatureCount < $1.signatureCount }
                } catch  {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct Petition_Previews: PreviewProvider {
    @State var petitions = [PetitionModel]()
    
    static var previews: some View {
        PetitionView()
    }
}
