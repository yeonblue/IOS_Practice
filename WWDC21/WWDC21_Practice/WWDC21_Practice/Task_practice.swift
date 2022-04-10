//
//  Task_practice.swift
//  WWDC21_Practice
//
//  Created by yeonBlue on 2022/04/07.
//

import SwiftUI

func fetchImage() async throws -> UIImage? {
    let imageTask = Task { () -> UIImage? in
        let imageURL = URL(string: "https://source.unsplash.com/random")!
        let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        try Task.checkCancellation()
        return UIImage(data: imageData)
    }
    // Cancel the image request right away:
    imageTask.cancel()
    return try await imageTask.value
}

func printMessage() async -> String{
    // 각각 Task들은 String을 return을 의미
    let string = await withTaskGroup(of: String.self, body: { group -> String in
        group.addTask {
            do {
                try await Task.sleep(nanoseconds: 1)
            } catch {
                
            }
            return "Hello"
        }
        group.addTask { "World"}
        group.addTask { "Test"}
        
        var collected = [String]()
        
        for await value in group { // group은 AsyncSequence
            collected.append(value)
        }
        
        return collected.joined(separator: " ")
    })
    
    return string
}

extension Task where Success == String {
    func getCount() async throws -> Int {
        try await self.value.count
    }
}

func factor(number: Int) async -> [Int] {
    var result = [Int]()
    // Task.yield()
    // Suspends the current task and allows other tasks to execute
    // Task.suspend()는 deprecated, 다른 예약된 Task 에게 처리 과정을 양보.
    
    for check in 1...number {
        if number.isMultiple(of: check) {
            result.append(check)
        } else {
            await Task.yield()
        }
        
        if Task.isCancelled {
            return []
        } 
    }
    
    return result //33분 45초
}

struct Task_practice: View {
    @State private var messages = [SampleMessage]()
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }.task {
            
            do {
                messages = try await withThrowingTaskGroup(of: [SampleMessage].self) { group -> [SampleMessage] in
                    for i in 1...3 {
                        group.addTask {
                            let url = URL(string: "https://hws.dev/inbox-\(i).json")!
                            let (data, _) = try await URLSession.shared.data(from: url)
                            return try JSONDecoder().decode([SampleMessage].self, from: data)
                        }
                    }
                    
                    let allMessages = try await group.reduce(into: [SampleMessage]()) {
                        $0 += $1
                    }
                    // try await group.waitForAll()
                    return allMessages.sorted { $0.id < $1.id}
                }
            } catch  {
                
            }
        }
    }
}

struct Task_practice_Previews: PreviewProvider {
    static var previews: some View {
        Task_practice()
    }
}
