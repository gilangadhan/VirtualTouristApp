//
//  VirtualTouristRepository.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 13/07/22.
//

import Foundation

protocol VirtualToursitRepositoryProtocol {

}

final class VirtualToursitRepository: NSObject {

  typealias RepoInstance = (LocaleProvider, NetworkProvider) -> VirtualToursitRepository

  fileprivate let network: NetworkProvider
  fileprivate let locale: LocaleProvider

  private init(locale: LocaleProvider, network: NetworkProvider) {
    self.network = network
    self.locale = locale
  }

  static let sharedInstance: RepoInstance = { locale, network in
    return VirtualToursitRepository(locale: locale, network: network)
  }

}

extension VirtualToursitRepository: VirtualToursitRepositoryProtocol {

  func getAllLocations(completion: @escaping(_ locations: [LocationEntity]) -> Void) {
    self.locale.getAllLocations { result in
      completion(result)
    }
  }

  func addLocation(
    longitude: Double,
    latitude: Double,
    completion: @escaping(_ idLocation: Int) -> Void
  ) {
    self.locale.addLocation(longitude: longitude, latitude: latitude) { result in
      completion(result)
    }
  }

  func addCollection(
    from albums: [AlbumModel],
    by location: LocationEntity,
    completion: @escaping() -> Void
  ) {
    var isSuccess = false
    for album in albums where album.isFavorite {
      locale.addAlbum(location: location, albumModel: album) {
        isSuccess = true
      }
    }
    if isSuccess {
      completion()
    }
  }

  func loadOnlyFromNetwork(
    location: LocationEntity,
    completion: @escaping(Result<[AlbumModel], Error>) -> Void
  ) {
    self.locale.getAllAlbum(by: location) { albums in
      var albumModels = AlbumMapper.mapAlbumEntitiesToModels(input: albums)
      self.network.getAllPhotos(latitude: location.latitude, longitude: location.longitude) { result in
        switch result {
        case .failure(let error):
          completion(.failure(error))
        case .success(let photos):
          var photosModel = AlbumMapper.mapAlbumResponsesToModels(input: photos)

          for album in albumModels {
            for (indexPhoto, photo) in photosModel.enumerated() where album.id == photo.id {
              photosModel.remove(at: indexPhoto)
            }
          }
          albumModels += photosModel
          completion(.success(albumModels))
        }
      }
    }
  }

  func downloadImage(
    url: String,
    completion: @escaping(Result<Data, Error>) -> Void
  ) {
    network.downloadImage(url: url) { result in
    switch result {
    case .failure(let error):
      completion(.failure(error))
    case .success(let photo):
      completion(.success(photo))
    }
    }
  }
  func loadLocation(
    by idLocation: String,
    completion: @escaping(_ location: LocationEntity) -> Void
  ) {
    self.locale.getLocation(by: idLocation) { location in
      completion(location)
    }
  }
}
