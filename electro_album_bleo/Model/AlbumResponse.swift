//
//  NewsFeedAlbumResponse.swift
//  electro_album_bleo
//
//  Created by bleo on 14/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import Foundation

struct AlbumResponse: Codable {
    
    var title: String?
    var link: String?
    var media: MediaResponse
    var date_taken: String?
    var description: String?
    var published: String?
    var author: String?
    var author_id: String?
    var tags: String?
    
    init(title: String?, link: String?, media: MediaResponse, date_taken: String?,
         description: String?, published: String?, author: String?, author_id: String?, tags: String?) {
        
        self.title = title
        self.link = link
        self.media = media
        self.date_taken = date_taken
        self.description = description
        self.published = published
        self.author = author
        self.author_id = author_id
        self.tags = tags
    }

    enum CodingKeys: String, CodingKey {
        case title
        case link
        case media
        case date_taken
        case description
        case published
        case author
        case author_id
        case tags
    }
}

struct MediaResponse: Codable {
    
    var m: String?
    init(m: String?) {
        self.m = m
    }
    
    enum CodingKeys: CodingKey {
        case m
    }
}
