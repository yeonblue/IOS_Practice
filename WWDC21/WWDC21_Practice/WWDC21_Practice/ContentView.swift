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
    @State private var messages = [SampleMessage]()
    @State private var sent =  [SampleMessage]()
    @State private var selectItem = "Messages"
    
    let selectItemList = ["Messages", "Sent"]
    var message: [SampleMessage] {
        if selectItem == "Messages" {
            return messages
        } else {
            return sent
        }
    }
    
    var body: some View {
        NavigationView {
            List(message) {message in
                VStack(alignment: .leading) {
                    Text("\(message.user)").bold()
                    Text(message.text)
                }
            }
            .navigationTitle(selectItem)
            .toolbar {
                Picker("Select Messages or Sent", selection: $selectItem) {
                    ForEach(selectItemList, id: \.self, content: Text.init)
                }.pickerStyle(.segmented)
            }
            
        }.task {
            do {
                
                // async, await
                // messages = try await fetchMessage()
                // sent = try await fetchSent()
                
                // 대기하지 않고 넘어감
                async let asyncMessage = fetchMessage()
                async let asyncSent = fetchSent()
                
                // await를 만났으므로 결과 대기
                messages = try await asyncMessage
                sent = try await asyncSent
                
                // 기존방식 36분 56초부터 보기
                fetchMessageNonAsync { result in
                    if case .success(let message) = result {
                        print(message)
                    }
                }
                
                // with continuation
                let messageWithContinuation = try await fetchMessageWithContinuation()
                print(messageWithContinuation)
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fetchMessage() async throws -> [SampleMessage] {
        let url = URL(string: "https://hws.dev/inbox.json")!
        return try await URLSession.shared.decode([SampleMessage].self, from: url)
    }
    
    func fetchSent() async throws -> [SampleMessage] {
        let url = URL(string: "https://hws.dev/sent.json")!
        return try await URLSession.shared.decode([SampleMessage].self, from: url)
    }
    
    /// non-async, jusing completion
    func fetchMessageNonAsync(
        completion: (@escaping (Result<[SampleMessage], Error>) -> Void)) {
        let url = URL(string: "https://hws.dev/inbox.json")!
        URLSession.shared.dataTask(with: url) { data, response, err in
            if let data = data {
                if let message = try? JSONDecoder().decode([SampleMessage].self,
                                                           from: data) {
                    completion(.success(message))
                    return
                } else if let err = err {
                    completion(.failure(err))
                    return
                }
            }
            completion(.success([]))
        }.resume()
    }
    
    func fetchMessageWithContinuation() async throws -> [SampleMessage] {
        // 오직 한번실행을 보장, 중간에 throw 구문이 실행되면 resume 부분이 실행되지 않음
        try await withCheckedThrowingContinuation { continuation in
            fetchMessageNonAsync { result in
                switch result {
                case .success(let message):
                    continuation.resume(with: .success(message))
                case .failure(let error):
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }

}

// sync, async
// Thread가 작업을 Block하는지 여부, async는 await가 필요
// await를 만나면 해당작업은 중지, 다른 작업 시작. await작업이 끝나면 다시 이후 실행.
// sync는 현재 쓰레드 내 작업을 멈추고 다른 작업을 시작할 수 없음.
// body는 async가 아님, task 함수를 사용해야 함. 남발은 하지말아야 함(Context Switch 참고)
// let은 var와 달리 concurrency-safe함
