//
//  Extension.swift
//  WWDC21_Practice
//
//  Created by yeonBlue on 2022/04/02.
//

import SwiftUI

extension URLSession {
    func decode<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy =  .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate
    ) async throws -> T {
        let (data, _ ) = try await data(from: url)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy
        
        let decodedData = try decoder.decode(T.self, from: data)
        return decodedData
    }
}

