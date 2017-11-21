//
//  RequestsSender.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 21.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

protocol RequestSenderProtocol {
    func send<Model, Parser>(config: RequestConfig<Model, Parser>, completionHandler: @escaping (Result<Model>) -> Void )
}

class RequestSender: RequestSenderProtocol {
    
    let session = URLSession.shared
    let queue: DispatchQoS.QoSClass = .userInitiated
    var async: Bool = false
    
    init(async: Bool = false) {
        if async == true {
            self.async = async
        }
    }
    
    func send<ModelType, Parser>(config: RequestConfig<ModelType, Parser>, completionHandler: @escaping (Result<ModelType>) -> Void) {
        
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.error("URL string can't be parsed to URL"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.error(error.localizedDescription))
                return
            }
            guard let data = data, let parsedModel = config.parser.parse(data: data) else {
                completionHandler(Result.error("Received data can not be parsed"))
                return
            }
            
            completionHandler(Result.success(parsedModel))
        }
        
        if async == true {
            let queue = self.queue
            DispatchQueue.global(qos: queue).async {
                task.resume()
            }
        }
        else {
            task.resume()
        }
    }
}

