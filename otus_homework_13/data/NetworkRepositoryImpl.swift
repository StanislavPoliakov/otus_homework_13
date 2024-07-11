//
//  repository.swift
//  otus_homework_13
//
//  Created by Поляков Станислав Денисович on 09.07.2024.
//

import Foundation

class NetworkRepositoryImpl : NetworkRepository {
    private let service = NetworkServiceImpl()
    
    func getCurrencies() async throws -> [CurrencyResponse] {
        return try await service.getCurrencies()
    }
    
    func getPoints(currencyCode: String) async throws -> [Double] {
        return try await service.getMarketData(for: currencyCode)
    }
    
    func getChart(points: [Double]) async throws -> Data {
        return try await service.getChart(values: points)
    }
}
