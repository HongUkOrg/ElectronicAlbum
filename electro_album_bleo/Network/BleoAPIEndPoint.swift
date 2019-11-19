//
//  BleoAPIEndPoint.swift
//  electro_album_bleo
//
//  Created by bleo on 14/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit
import Moya

enum BleoAPIEndPoint {
    case newsFeed
    case github
}

extension BleoAPIEndPoint: TargetType {
    
    enum ServerAddress: String {
        case newsFeed = "https://api.flickr.com"
        case github = "https://api.github.com"
    }
    
    var serverAddress: ServerAddress {
        switch self {
        case .newsFeed:
            return .newsFeed
        case .github:
            return .github
        }
    }
    
    var baseURL: URL {
        return URL(string: serverAddress.rawValue)!
    }
    
    var path: String {
        switch self {
        case .newsFeed:
            return "/services/feeds/photos_public.gne"
        case .github:
            return "/users/hongukorg/repos"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .newsFeed:
            return .get
        case .github:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .newsFeed:
            let encoding = URLEncoding(destination: .queryString, arrayEncoding: .brackets, boolEncoding: .literal)
            return .requestParameters(
                parameters : [
                    "format": "json",
                    "tags": "portrait, landscape",
                    "tagmod": "any",
                    "nojsoncallback": 1
                ],
                encoding: encoding)
        case .github:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        let header: [String: String] = [
        "Content-Type": "application/json"
        ]
        return header
    }

}
