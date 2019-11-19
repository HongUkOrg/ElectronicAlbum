//
//  BleoAPIService.swift
//  electro_album_bleo
//
//  Created by bleo on 13/11/2019.
//  Copyright © 2019 bleo. All rights reserved.
//

import UIKit
import Moya
import RxSwift

protocol BleoAPIServiceType {
    var provider: MoyaProvider<BleoAPIEndPoint> { get }
    func getFlickrAlbums() -> Single<AlbumListResponse>
    func getImageFromUrl(_ url: String) -> Observable<Data>
}

class BleoAPIService: BleoAPIServiceType {
    
    let provider: MoyaProvider<BleoAPIEndPoint>
    
    init(provider: MoyaProvider<BleoAPIEndPoint>) {
        self.provider = provider
    }
    
    func getFlickrAlbums() -> Single<AlbumListResponse> {
        return provider.rx
            .request(.newsFeed)
            .map(AlbumListResponse.self, using: CustomJsonDecoder())
            .do(onSuccess: { (response) in
                AlbumList.album.accept(response.items)
            }, onError: { (error) in
                print("Moya :: request error :: \(error)")
            })
    }
    
    func getImageFromUrl(_ url: String) -> Observable<Data> {
        
        return Single.just(url)
                .map { URL(string: $0)}
                .filter { $0 != nil }
                .map { $0! }
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .default))
                .map { try Data(contentsOf: $0)}
                .asObservable()
    }

}
