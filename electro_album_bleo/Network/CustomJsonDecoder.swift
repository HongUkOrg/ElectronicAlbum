//
//  CustomJsonDecoder.swift
//  electro_album_bleo
//
//  Created by bleo on 15/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit

final class CustomJsonDecoder: JSONDecoder {
    override init() {
        super.init()
        self.dateDecodingStrategy = .secondsSince1970
    }
}
