//
//  ContentView.swift
//  WWDC21_Practice
//
//  Created by yeonBlue on 2022/04/02.
//

import SwiftUI

struct SampleMessage: Codable, Identifiable {
    let id: Int
    let user: String
    let text: String
}

struct ContentView: View {
    
    // 메인쓰레드에서 UI Update를 보장함(@State), DispatchQueue 필요없음
    @State private var messages = [SampleMessage]() //
    
    var body: some View {
        NavigationView {
            List(messages) {message in
                VStack(alignment: .leading) {
                    Text("\(message.user)").bold()
                    Text(message.text)
                }
            }.navigationTitle("Messages")
        }.task {
            do {
                messages = try await fetchMessage()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchMessage() async throws -> [SampleMessage] {
        let url = URL(string: "https://hws.dev/inbox.json")!
        return try await URLSession.shared.decode([SampleMessage].self, from: url)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
