//
//  AlbumList.swift
//  electro_album_bleo
//
//  Created by bleo on 14/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct AlbumList {
    static let album = BehaviorRelay<[AlbumResponse]>(value: [])
}
