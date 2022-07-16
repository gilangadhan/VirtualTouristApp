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

  func addAlbum(
    from album: AlbumModel,
    by location: LocationEntity,
    completion: @escaping() -> Void
  ) {
    self.locale.addAlbum(location: location, albumModel: album) {
      
      completion()
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

  func loadAlbums(
    location: LocationEntity,
    isFirst: Bool,
    completion: @escaping(Result<[AlbumModel], Error>) -> Void
  ) {
    self.locale.getAllAlbum(by: location) { albumEntity in
      let albumModels = AlbumMapper.mapAlbumEntitiesToModels(input: albumEntity)

      self.network.getAllPhotos(latitude: location.latitude, longitude: location.longitude) { result in
        switch result {
        case .failure(let error):
          if albumModels.isEmpty {
            completion(.failure(error))
          } else {
            completion(.success(albumModels))
          }
        case .success(let photos):
          let photosModel = AlbumMapper.mapAlbumResponsesToModels(input: photos).shuffled()

          if albumModels.isEmpty {
            completion(.success(photosModel))
          } else if isFirst {
            completion(.success(albumModels))
          } else {
            self.deleteAlbums(from: albumModels, by: location) {
              completion(.success(photosModel))
            }
          }
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

  func deleteLocation(
    from location: LocationEntity,
    completion: @escaping() -> Void
  ) {
    locale.deleteLocation(from: location) {
      completion()
    }
  }

  func deleteAlbums(
    from albums: [AlbumModel],
    by location: LocationEntity,
    completion: @escaping() -> Void
  ) {
    var isSuccess = false
    for album in albums {
      locale.deleteAlbum(from: album, by: location) {
        isSuccess = true
      }
    }
    if isSuccess {
      completion()
    }
  }

}
