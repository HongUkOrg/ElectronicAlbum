//
//  BleoFlow.swift
//  electro_album_bleo
//
//  Created by bleo on 13/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit
import RxFlow

class BleoFlow: Flow {
 
    var root: Presentable {
        return self.rootWindow
    }
    
    private let rootWindow: UIWindow
    private let splashReactor: SplashReactor
    private let albumReactor: AlbumReactor
    private let bleoServices: BleoServicesType
    
    init(initWindow window: UIWindow, andServices services: BleoServicesType) {
        self.rootWindow = window
        self.splashReactor = SplashReactor(services: services)
        self.albumReactor = AlbumReactor(services: services)
        self.bleoServices = services
    }
    
    func navigate(to step: Step) -> FlowContributors {
        print("bleo flow step : \(step)")
        guard let step = step as? BleoNavigateStep else { return FlowContributors.none }
        switch step {
        case .splash:
            return navigateToSplash()
        case .album:
            return navigateToAlbumShow()
        }
     }
    
    private func navigateToSplash() -> FlowContributors {
        let splashFlow = SplashFlow(services: bleoServices, reactor: splashReactor)
        Flows.whenReady(flow1: splashFlow) { [weak self] (root) in
            
            print("Flows whenReady -> splashFlow")
            self?.rootWindow.rootViewController = root
        }
        return .one(flowContributor:
            FlowContributor.contribute(
                withNextPresentable: splashFlow,
                withNextStepper: splashReactor))
    }
    
    private func navigateToAlbumShow() -> FlowContributors {
        let albumFlow = AlbumFlow(services: bleoServices, reactor: albumReactor)
        Flows.whenReady(flow1: albumFlow) { [weak self] (root) in
            self?.rootWindow.rootViewController = root
        }
        
        return .one(flowContributor:
            FlowContributor.contribute(
                withNextPresentable: albumFlow,
                withNextStepper: albumReactor))
        
    }
}
