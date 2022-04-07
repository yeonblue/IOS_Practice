//
//  Task_practice.swift
//  WWDC21_Practice
//
//  Created by yeonBlue on 2022/04/07.
//

import SwiftUI

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
    }
    
    return result
}

struct Task_practice: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Task_practice_Previews: PreviewProvider {
    static var previews: some View {
        Task_practice()
    }
}
