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
  private lazy var repository: VirtualToursitRepository = { return Injection().provideRepository() }()

  private var location: LocationEntity?
  private var albums: [AlbumModel] = []

  @IBOutlet var mapView: MKMapView!
  @IBOutlet var buttonAddCollection: UIButton!
  @IBOutlet var collectionView: UICollectionView!

  var idLocation: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.allowsMultipleSelection = true

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let id = idLocation {
      repository.loadLocation(by: id) { location in
        self.location = location
        self.updateMap()
        self.repository.loadOnlyFromNetwork(location: location) { result in
          switch result {
          case .failure(let error):
            print(error.localizedDescription)
          case .success(let photos):
            self.albums = photos
            DispatchQueue.main.async {
              self.unselectAllSelectedCollectionViewCell()
              self.collectionView.reloadData()
            }
          }
        }
      }
    }
  }

  @IBAction func addCollection(_ sender: Any) {
    repository.addCollection(from: albums, by: location!) {

    }
  }

  @IBAction func removeLocation(_ sender: Any) {

  }

  func updateMap() {
    guard let result = location else { return }
    let annotation = CustomPointAnnotation()
    annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
    self.mapView.addAnnotation(annotation)
  }

  func unselectAllSelectedCollectionViewCell() {
    for indexPath in collectionView.indexPathsForSelectedItems! {
      collectionView.deselectItem(at: indexPath, animated: false)
      collectionView.cellForItem(at: indexPath)?.contentView.alpha = 1
    }
  }
}

extension AlbumViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    print(albums.count)
    return albums.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "AlbumCell",
      for: indexPath
    ) as? AlbumCollectionViewCell else {
      return UICollectionViewCell()
    }
    cell.loadImage(url: albums[indexPath.row].imageUrl()) { data in
      self.albums[indexPath.row].image = data
    }

    return cell
  }
}

extension AlbumViewController: UICollectionViewDelegate {

  func selectedToDeleteFromIndexPath(_ indexPathArray: [IndexPath]) -> [Int] {
    var selected: [Int] = []
    for indexPath in indexPathArray {
      selected.append(indexPath.row)
    }
    return selected
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath)

    DispatchQueue.main.async {
      cell?.contentView.alpha = 0.5
    }
  }

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath)
    DispatchQueue.main.async {
      cell?.contentView.alpha = 1
    }
  }
}
