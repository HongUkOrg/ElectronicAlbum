//
//  SplashFlow.swift
//  electro_album_bleo
//
//  Created by bleo on 13/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import RxFlow
import RxSwift
import RxCocoa
import Then

class SplashFlow: Flow {
  
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController().then {
        $0.setNavigationBarHidden(true, animated: false)
    }
    
    private let services: BleoServicesType
    private let reactor: SplashReactor
    
    init(services: BleoServicesType, reactor: SplashReactor) {
        self.services = services
        self.reactor = reactor
        
        let splashViewController = SplashViewController(reactor: reactor)
        self.rootViewController.setViewControllers([splashViewController], animated: false)
    }
    
    func navigate(to step: Step) -> FlowContributors {
        print("splashFlow step : \(step)")
        guard let step = step as? BleoNavigateStep else { return .none }
        switch step {
        case .splash:
            return .none
        default:
            return FlowContributors.end(forwardToParentFlowWithStep: step)
        }
    }
    
}
