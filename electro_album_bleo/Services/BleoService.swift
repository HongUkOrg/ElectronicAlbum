//
//  BleoService.swift
//  electro_album_bleo
//
//  Created by bleo on 13/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit

protocol BleoServicesType {
    var apiService: BleoAPIServiceType { get }
}

struct BleoServices: BleoServicesType {
    let apiService: BleoAPIServiceType
}
