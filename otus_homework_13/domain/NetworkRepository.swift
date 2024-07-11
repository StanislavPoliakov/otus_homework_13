//
//  NetworkRepository.swift
//  otus_homework_13
//
//  Created by Поляков Станислав Денисович on 09.07.2024.
//

import Foundation

protocol NetworkRepository {
    func getCurrencies() async throws -> [CurrencyResponse]
    func getPoints(currencyCode: String) async throws -> [Double]
    func getChart(points: [Double]) async throws -> Data
}
