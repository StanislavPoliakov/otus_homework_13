//
//  NetworkService.swift
//  otus_homework_13
//
//  Created by Поляков Станислав Денисович on 11.07.2024.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol HttpUrlConvertible {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var queryParameters: [String: String] { get }
    var headers: [String: String] { get }
    var body: [String: Any] { get }
    var method: HttpMethod { get }
    
    func asRequest() throws -> URLRequest
}

extension HttpUrlConvertible {
    var scheme: String { "https" }
    var headers: [String: String] { [:] }
    var body: [String: Any] { [:] }
    var method: HttpMethod { .get }
    
    func asRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = queryParameters.map { parameter in URLQueryItem(name: parameter.key, value: parameter.value)}
        
        guard let url = components.url else { throw NetworkError.invalidUrl }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        if !body.isEmpty {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw NetworkError.invalidBodySerialization
            }
        }
        
        return request
    }
}

enum ServiceEndpoints: HttpUrlConvertible {
    case currencies(queryParameters: [String: String])
    case marketData(queryParameters: [String: String])
    case chart(queryParameters: [String: String])
    
    var host: String {
        switch self {
            case .currencies, .marketData: "cbr.ru"
            case .chart: "image-charts.com"
        }
    }
    
    var path: String {
        switch self {
            case .currencies: "/scripts/XML_val.asp"
            case .marketData: "/scripts/XML_dynamic.asp"
            case .chart: "/chart"
        }
    }
    
    var queryParameters: [String : String] {
        switch self {
            case .currencies(let queryParameters),
                    .chart(let queryParameters),
                    .marketData(let queryParameters): queryParameters
        }
    }
}

protocol NetworkService {
    func getCurrencies() async throws -> [CurrencyResponse]
    func getMarketData(for currencyCode: String) async throws -> [Double]
    func getChart(values: [Double]) async throws -> Data
}

class NetworkServiceImpl: NetworkService {
    private let urlSession: URLSession = URLSession.shared
    
    func getCurrencies() async throws -> [CurrencyResponse] {
        let queryParameters: [String: String] = ["d": "0"]
        
        let request = try ServiceEndpoints.currencies(queryParameters: queryParameters).asRequest()
        
        guard let (data, response) = try? await urlSession.data(for: request) else {
            throw NetworkError.networkError
        }
            
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.networkError
        }
        
        let parser = XMLParser(data: data)
        let delegate = CurrencyParserDelegate()
        parser.delegate = delegate
        
        if parser.parse() {
            return delegate.currencies
        } else {
            throw NetworkError.invalidResult
        }
    }
    
    func getMarketData(for currencyCode: String) async throws -> [Double] {
        let currentDate = Date()
        let startDate = Calendar.current.date(byAdding: .year, value: -2, to: currentDate)!
        let queryParameters: [String: String] = [
            "date_req1" : startDate.formatted(),
            "date_req2" : currentDate.formatted(),
            "VAL_NM_RQ" : currencyCode
        ]
        
        let request = try ServiceEndpoints.marketData(queryParameters: queryParameters).asRequest()
        
        guard let (data, response) = try? await urlSession.data(for: request) else {
            throw NetworkError.networkError
        }
            
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.networkError
        }
        
        let parser = XMLParser(data: data)
        let delegate = MarketDataParserDelegate()
        parser.delegate = delegate
        
        if parser.parse() {
            return delegate.values
        } else {
            throw NetworkError.invalidResult
        }
    }
    
    func getChart(values: [Double]) async throws -> Data {
        let points = values
            .enumerated()
            .compactMap { index, element in
                index % 7 == 0 ? String(describing: element) : nil
            }
            .prefix(100)
            .joined(separator: ",")
        
        let queryParameters: [String: String] = [
            "chs" : "700x190",
            "cht" : "lc",
            "chd" : "t:\(points)"
        ]
        
        let request = try ServiceEndpoints.chart(queryParameters: queryParameters).asRequest()
        
        guard let (data, response) = try? await urlSession.data(for: request) else {
            throw NetworkError.networkError
        }
            
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.networkError
        }
        
        return data
    }
}

extension Date {
    func formatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: self)
    }
}
