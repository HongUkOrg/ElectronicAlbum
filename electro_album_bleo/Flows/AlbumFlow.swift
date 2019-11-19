//
//  AlbumFlow.swift
//  electro_album_bleo
//
//  Created by bleo on 14/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit
import RxFlow
import Then

class AlbumFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController().then {
        $0.setNavigationBarHidden(true, animated: false)
    }
    
    private let services: BleoServicesType
    private let reactor: AlbumReactor
    
    func navigate(to step: Step) -> FlowContributors {
        print("Album navigate :: step - \(step)")
        return .none
    }
    
    init(services: BleoServicesType, reactor: AlbumReactor) {
        self.services = services
        self.reactor = reactor
        
        let albumViewController = AlbumViewController(reactor: reactor)
        self.rootViewController.setViewControllers([albumViewController], animated: false)
    }
    
}
