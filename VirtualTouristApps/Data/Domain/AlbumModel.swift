//
//  AlbumModel.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 14/07/22.
//

import Foundation

struct AlbumModel: Codable {
  let id, owner, secret, server: String
  let farm: Int
  let title: String
  let ispublic, isfriend, isfamily: Int
  var image: Data?
  var isFavorite = false

  func imageUrl() -> String {
    return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
  }
}
