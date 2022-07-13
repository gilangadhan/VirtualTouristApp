//
//  CollectionPhotosViewController.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 11/07/22.
//

import Foundation
import UIKit
import MapKit

class AlbumViewController: UIViewController {
  private lazy var dataProvider: LocaleProvider = { return LocaleProvider() }()

  private var location: LocationEntity?
  private var albums: [AlbumEntity] = []
  private var photos: [Photo] = []

  @IBOutlet var mapView: MKMapView!

  var idLocation: String?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let id = idLocation {
      dataProvider.getAllAlbum(by: id) { location, albums in
        self.albums = albums
        self.location = location
        self.getPhotos()
        self.updateMap()
      }
    }
  }

  func getPhotos() {
    let networkProvider = NetworkProvider()
    guard let result = location else { return }
    networkProvider.getAllPhotos(latitude: result.latitude, longitude: result.longitude) { result in
      switch result {
      case .failure(let error):
        print(error)
      case .success(let photos):
        self.photos = photos
        print(self.photos.count)
      }
    }
  }

  func updateMap() {
    guard let result = location else { return }
    let annotation = CustomPointAnnotation()
    annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
    self.mapView.addAnnotation(annotation)
  }
}
