//
//  Task_practice2.swift
//  WWDC21_Practice
//
//  Created by yeonBlue on 2022/04/10.
//

import SwiftUI

struct NewsStory: Identifiable, Decodable {
    let id: Int
    let title: String
    let strap: String
    let url: URL
}

struct Task_practice2: View {
    @State private var stories = [NewsStory]()

    var body: some View {
        NavigationView {
            List(stories) { story in
                VStack(alignment: .leading) {
                    Text(story.title)
                        .font(.headline)

                    Text(story.strap)
                }
            }
            .navigationTitle("Latest News")
        }
        .task {
            do {
                try? await loadStories()
            } catch  {
                print(error)
            }
        }
    }

    func loadStories() async {
        do {
            try await withThrowingTaskGroup(of: [NewsStory].self) { group -> Void in
                for i in 1...5 {
                    group.addTask {
                        let url = URL(string: "https://hws.dev/news-\(i).json")!
                        let (data, _) = try await URLSession.shared.data(from: url)
                        try Task.checkCancellation()
                        return try JSONDecoder().decode([NewsStory].self, from: data)
                    }
                }

                for try await result in group {
                    stories.append(contentsOf: result)
                }

                stories.sort { $0.id > $1.id }
            }
        } catch {
            print("Failed to load stories: \(error.localizedDescription)")
        }
    }
}

struct Task_practice2_Previews: PreviewProvider {
    static var previews: some View {
        Task_practice2()
    }
}
