//
//  AlbumResponse.swift
//  electro_album_bleo
//
//  Created by bleo on 14/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit

struct AlbumListResponse: Codable {

    var title: String?
    var link: String?
    var description: String?
    var modified: String?
    var generator: String?
    var items: [AlbumResponse]
    
    init(title: String?, link: String?, description: String?, modified: String?, generator: String?, items: [AlbumResponse]) {
        self.title = title
        self.link = link
        self.description = description
        self.modified = modified
        self.generator = generator
        self.items = items
        print("AlbumList initializng :: title : \(String(describing: title)), generator : \(String(describing: generator))")
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case link
        case description
        case modified
        case generator
        case items
    }
}
