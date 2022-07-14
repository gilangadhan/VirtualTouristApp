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
  private let spacing: CGFloat = 4

  @IBOutlet var mapView: MKMapView!
  @IBOutlet var buttonAddCollection: UIButton!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var flowLayout: UICollectionViewFlowLayout!
  @IBOutlet var indicatorLoading: UIActivityIndicatorView!

  var idLocation: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    let dimension = (self.view.frame.size.width - (3 * 8)) / 3.0

    flowLayout.minimumInteritemSpacing = spacing
    flowLayout.minimumLineSpacing = spacing
    flowLayout.itemSize = CGSize(width: dimension, height: dimension)

    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.allowsMultipleSelection = true

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateView()
  }

  @IBAction func addCollection(_ sender: Any) {
    self.indicatorLoading.isHidden = false
    self.indicatorLoading.startAnimating()

    var favoriteAlbums: [AlbumModel] = []
    for album in albums where album.isFavorite {
      favoriteAlbums.append(album)
    }

    if !favoriteAlbums.isEmpty {
      repository.addCollection(from: favoriteAlbums, by: self.location!) {
        self.updateCollectionView()
      }
    } else {
      self.indicatorLoading.isHidden = false
      self.indicatorLoading.startAnimating()
      let alert = UIAlertController(
        title: "Warning!",
        message: "Please select your favorite Image before adding Collection.",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
        self.navigationController?.popViewController(animated: true)
      })
      self.present(alert, animated: true, completion: nil)

    }
  }

  @IBAction func removeLocation(_ sender: Any) {
    self.indicatorLoading.isHidden = false
    self.indicatorLoading.startAnimating()

    guard let thisLocation = location else { return }
    repository.deleteLocation(from: thisLocation) {
      self.navigationController?.popViewController(animated: true)
      self.indicatorLoading.isHidden = true
      self.indicatorLoading.stopAnimating()
    }
  }

  private func updateView() {
    self.indicatorLoading.isHidden = false
    self.indicatorLoading.startAnimating()
    self.buttonAddCollection.isEnabled = false

    if let id = idLocation {
      repository.loadLocation(by: id) { location in
        self.location = location
        self.updateMap()
        self.updateCollectionView()
      }
    }
  }

  private func updateCollectionView() {
    guard let location = self.location else { return }

    self.repository.loadOnlyFromNetwork(location: location) { result in
      switch result {
      case .failure(let error):
        print(error.localizedDescription)
        self.indicatorLoading.isHidden = true
        self.indicatorLoading.stopAnimating()
      case .success(let photos):
        self.albums = photos
        DispatchQueue.main.async {
          self.collectionView.reloadData()
          self.indicatorLoading.isHidden = true
          self.indicatorLoading.stopAnimating()
          self.buttonAddCollection.isEnabled = true
        }
      }
    }
  }

  private func updateMap() {
    guard let result = location else { return }
    let annotation = CustomPointAnnotation()
    annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)

    let dest = annotation.coordinate
    let span = MKCoordinateSpan.init(latitudeDelta: 1, longitudeDelta: 1)
    let region = MKCoordinateRegion(center: dest, span: span)
    mapView.setRegion(region, animated: true)

    self.mapView.addAnnotation(annotation)
  }
}

extension AlbumViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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

    cell.isSelected = self.albums[indexPath.row].isFavorite

    updateViewCell(cell: cell, isFavorite: self.albums[indexPath.row].isFavorite)

    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = UIScreen.main.bounds.width / 3 - spacing
    let height = width
    return CGSize(width: width, height: height)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {

    return spacing
  }
}

extension AlbumViewController: UICollectionViewDelegate {

  func collectionView(
    _ collectionView: UICollectionView,
    didSelectItemAt indexPath: IndexPath
  ) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? AlbumCollectionViewCell else { return }
    self.albums[indexPath.row].isFavorite = true
    updateViewCell(cell: cell, isFavorite: true)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    didDeselectItemAt indexPath: IndexPath
  ) {
    guard let cell = collectionView.cellForItem(at: indexPath) as? AlbumCollectionViewCell else { return }
    self.albums[indexPath.row].isFavorite = false
    updateViewCell(cell: cell, isFavorite: false)
  }

  func updateViewCell(cell: AlbumCollectionViewCell, isFavorite: Bool) {

    if isFavorite {
      cell.imageFavorite.isHidden = false
      cell.imageFavorite.image = UIImage(systemName: "bookmark.fill")
    } else {
      cell.imageFavorite.isHidden = true
      cell.imageFavorite.image = UIImage(systemName: "bookmark")
    }

  }

}
