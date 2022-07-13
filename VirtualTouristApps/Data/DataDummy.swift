//
//  DataDummy.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 13/07/22.
//

import UIKit

var albumDummies: [AlbumModel] = [
  AlbumModel(image: imageToData("Ahmad Arif Faizin")),
  AlbumModel(image: imageToData("Gilang Ramadhan")),
  AlbumModel(image: imageToData("Widyarso Joko Purnomo"))
]

func imageToData(_ title: String) -> Data? {
    guard let img = UIImage(named: title) else { return nil }
    return img.jpegData(compressionQuality: 1)
}

struct AlbumModel {
    var idAlbum: Int32?
    var image: Data?
}
