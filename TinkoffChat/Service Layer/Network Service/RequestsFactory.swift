//
//  RequestsFactory.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 21.11.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation

// Struct of RequestConfigurator
struct RequestConfig<Model, Parser: ParserProtocol> where Parser.Model == Model {
    let request: RequestProtocol
    let parser: Parser
}

class RequestsFactory {
    //Using Pixabay API structure for getting images
    struct GetPixabayImagesRequests {
        
        static func imagesListConfig(page: Int = 1) -> RequestConfig<[ImagesListModel], ImagesListParser> {
            return RequestConfig(request: ImagesListRequest(apiKey: "7122411-e68a2e68a287471f07447b6cb", page: page), parser: ImagesListParser())
        }
        
        static func imageConfig(url: URL) -> RequestConfig<SingleImageModel, SingleImageParser> {
            return RequestConfig(
                request: SingleImageRequest(url: url), parser: SingleImageParser())
        }
    }
}

