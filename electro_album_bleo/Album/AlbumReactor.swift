//
//  AlbumReactor.swift
//  electro_album_bleo
//
//  Created by bleo on 14/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import ReactorKit
import RxFlow
import RxSwift
import RxCocoa
import Reachability

final class AlbumReactor: Reactor, Stepper {
    
    private let bleoServices: BleoServicesType
    
    enum Action {
        case slideBtnClicked
        case showAlbum
        case showNextAlbum
        case stopShowAlbum
        case updateAlbum
        case stepperChanged(Int)
        case getNetworkState(Bool)
        case updateInitalState
        case orientationChanged
        case updateImage(String)
    }
    
    enum Mutation {
        case slideBtnClicked
        case startSlideShow(AlbumListResponse)
        case nextSlideShow(AlbumListResponse)
        case stopSlideShow
        case updateAlbumIndex
        case updateInterval(Int)
        case updateNetworkState(Bool)
        case updateImage(Data)
        case readyForNextSlide
        case updateOrientation
        case networkFailure
    }
    
    struct State {
        var isShowing: Bool = false
        var reachablity: Bool = false
        var interval: Int = 1
        var btnText: String = "Start"
        var albums: [AlbumResponse] = []
        var albumCount = 0
        var albumIamgeUrl: String = ""
        var currentAlbumIndex = -1
        var btnImageColor = UIColor(red: 60/255, green: 159/255, blue: 226/255, alpha: 1)
        var currentAlbumImage = UIImage(named: "album_default")
        var orientation: UIDeviceOrientation = UIDevice.current.orientation
    }
    
    let initialState: AlbumReactor.State = State()
    
    var steps: PublishRelay<Step> = PublishRelay<Step>()
    var initialStep: Step = RxFlowStep.home
    var disposeBag: DisposeBag = DisposeBag()
    
    init(services: BleoServicesType) {
        defer { _ = self.state }
        self.bleoServices = services
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        print("AlbumReactor :: action - \(action)")
        
        switch action {
        case .slideBtnClicked:
            return .concat([
                .just(.slideBtnClicked)
            ])
        case .showAlbum:
            return .concat([
                bleoServices.apiService
                    .getFlickrAlbums()
                    .map(Mutation.startSlideShow)
                    .catchErrorJustReturn(.networkFailure)
                    .asObservable(),
                .just(.updateAlbumIndex),
                .just(.readyForNextSlide)
            ])
        case .showNextAlbum:
            return .concat([
                bleoServices.apiService
                    .getFlickrAlbums()
                    .map(Mutation.nextSlideShow)
                    .catchErrorJustReturn(.networkFailure)
                    .asObservable()
            ])
        case .stopShowAlbum:
            return .concat([
                .just(.stopSlideShow)
            ])
        case .updateAlbum:
            return .concat([
                .just(.updateAlbumIndex),
                .just(.readyForNextSlide)
            ])
        case .stepperChanged(let interval):
            return .concat([
                .just(.updateInterval(interval))
            ])
        case .getNetworkState(let reachablity):
            return .concat([
                .just(.updateNetworkState(reachablity))
            ])
        case .updateInitalState:
            let networkAvailable = Reachability()!.connection != Reachability.Connection.none
            return .concat([
                .just(.updateNetworkState(networkAvailable))
            ])
        case .updateImage(let url):
            return .concat([
                bleoServices.apiService
                    .getImageFromUrl(url)
                    .map(Mutation.updateImage)
                    .catchErrorJustReturn(.networkFailure)
                    .asObservable()
            ])
        case .orientationChanged:
            return .concat([
                .just(.updateOrientation)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        print("AlbumReactor mutation :: \(mutation)")
        
        var state = state
        switch mutation {
        case .slideBtnClicked:
            state.isShowing = !state.isShowing
            
        case .startSlideShow(let response):
            state.albums = response.items
            state.albumCount = state.albums.count
            state.btnText = "Stop"
            state.btnImageColor = UIColor(red: 243/255, green: 131/255, blue: 146/255, alpha: 1)
            
        case .nextSlideShow(let response):
            state.albums += response.items
            state.albumCount = state.albums.count
            
        case .stopSlideShow:
            state.btnText = "Start"
            state.btnImageColor = UIColor(red: 60/255, green: 159/255, blue: 226/255, alpha: 1)
            
        case .updateAlbumIndex:
            
            if !state.isShowing {
                return state
            }

            state.currentAlbumIndex += 1
            state.albumIamgeUrl = state.albums[state.currentAlbumIndex].media.m!

            if state.currentAlbumIndex == state.albumCount - 3 {
                print("updateAlbumIndex :: get next Albums..")
                Observable.just(Action.showNextAlbum)
                    .observeOn(MainScheduler.asyncInstance)
                    .bind(to: action)
                    .disposed(by: disposeBag)
            } else if state.currentAlbumIndex == state.albumCount - 1 {
                print("updateAlbumIndex :: failed to get new album..")
                state.currentAlbumIndex = 0
            }
            
        case .readyForNextSlide:
            
            Observable.just(state.isShowing)
                .filter { $0 == true }
                .map { (_) in state.interval }
                .do(onNext: { (interval) in
                    print("readyForNextSlide :: current album index = \(state.currentAlbumIndex) :: delay = \(interval)s")
                })
                .flatMap { (interval) in
                    return Observable.just(AlbumReactor.Action.updateAlbum)
                        .delay(RxTimeInterval.seconds(interval), scheduler: MainScheduler.asyncInstance)}
                
                .bind(to: self.action)
                .disposed(by: disposeBag)
            
        case .updateInterval(let interval):
            state.interval = interval
            
        case .updateNetworkState(let reachablity):
            state.reachablity = reachablity
            
        case .networkFailure:
            state.isShowing = false
            print("networkFailure :: stop showing albums")
            
        case .updateImage(let data):
            state.currentAlbumImage = UIImage(data: data)
        
        case .updateOrientation:
            state.orientation = UIDevice.current.orientation
        }
        
        return state

    }
}
