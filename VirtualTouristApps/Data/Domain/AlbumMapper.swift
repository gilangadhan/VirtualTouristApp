//
//  AlbumMapper.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 14/07/22.
//

import Foundation

final class AlbumMapper {

  static func mapAlbumResponsesToModels(
    input albumResponse: [Photo]
  ) -> [AlbumModel] {
    return albumResponse.map { result in

      return AlbumModel(
        id: result.id,
        owner: result.owner,
        secret: result.secret,
        server: result.server,
        farm: result.farm,
        title: result.title,
        ispublic: result.ispublic,
        isfriend: result.isfriend,
        isfamily: result.isfamily,
        image: nil
      )
    }
  }

  static func mapAlbumEntitiesToModels(
    input albumResponse: [AlbumEntity]
  ) -> [AlbumModel] {
    return albumResponse.map { result in

      return AlbumModel(
        id: result.idAlbum!,
        owner: result.owner!,
        secret: result.secret!,
        server: result.server!,
        farm: Int(result.farm),
        title: result.title!,
        ispublic: Int(result.ispublic),
        isfriend: Int(result.isfriend),
        isfamily: Int(result.isfamily),
        image: result.image
      )
    }
  }
}
