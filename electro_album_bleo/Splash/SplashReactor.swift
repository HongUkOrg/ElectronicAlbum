//
//  SplashReactor.swift
//  electro_album_bleo
//
//  Created by bleo on 13/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import ReactorKit
import RxFlow
import RxSwift
import RxCocoa

final class SplashReactor: Reactor, Stepper {
    
    private let bleoServices: BleoServicesType
    
    enum Action {
        case didViewAppearCompleted
    }
    
    enum Mutation {
        case normal
        case apiFailure
        case serverDown
    }
    
    struct State {
        var errorState: Bool = false
    }
    
    let initialState: SplashReactor.State = State()
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    var initialStep: Step = RxFlowStep.home
    
    init(services: BleoServicesType) {
        self.bleoServices = services
    }
    
    func readyToEmitSteps() {
        steps.accept(BleoNavigateStep.splash)
    }
    
    func mutate(action: SplashReactor.Action) -> Observable<Mutation> {
        print("SplashReactor :: action = \(action)")
        switch action {
        case .didViewAppearCompleted:
            return .concat([
                .just(.normal)])
        }
    }
    
    func reduce(state: SplashReactor.State, mutation: SplashReactor.Mutation) -> SplashReactor.State {
        print("SplashReactor :: mutation = \(mutation)")
        var state = state
        switch mutation {
        case .apiFailure, .serverDown:
            state.errorState = true
        case .normal:
            steps.accept(BleoNavigateStep.album)
        }
        return state
    }
}
