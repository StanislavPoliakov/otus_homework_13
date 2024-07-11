//
//  NetworkError.swift
//  otus_homework_13
//
//  Created by Поляков Станислав Денисович on 09.07.2024.
//

import Foundation

enum NetworkError : Error {
    case requestProcessingError
    case networkError
    case networkStatusError(code: Int)
    case emptyData
    case invalidUrl
    case invalidBodySerialization
    case requestError
    case invalidResult
}
