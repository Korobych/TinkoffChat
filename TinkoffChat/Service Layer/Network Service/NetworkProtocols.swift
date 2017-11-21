//
//  ParserProtocol.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 21.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol ParserProtocol {
    associatedtype Model
    func parse(data: Data) -> Model?
}

protocol RequestProtocol {
    var urlRequest: URLRequest? {get set}
}

enum Result<T> {
    case success(T)
    case error(String)
}
