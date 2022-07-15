//
//  ViewController.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 10/07/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
  private lazy var repository: VirtualToursitRepository = { return Injection().provideRepository() }()

  private var locations: [LocationEntity] = []
  private let newPin = MKPointAnnotation()

  @IBOutlet var mapView: MKMapView!
  @IBOutlet var indicatorLoading: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()

    mapView.delegate = self
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPress(_:)))
    longPress.minimumPressDuration = 1.0
    mapView.addGestureRecognizer(longPress)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadLocations()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "moveToDetail", let idLocation = sender as? String {
      let viewController = segue.destination as? AlbumViewController
      viewController?.idLocation = idLocation
    }
  }

  @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
    if recognizer.state != .began { return }
    let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
    let touchedAtCoordinate = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates
    addLocation(by: touchedAtCoordinate)
  }

  private func loadLocations() {
    self.indicatorLoading.isHidden = false
    self.indicatorLoading.startAnimating()
    repository.getAllLocations { results in
      self.locations = results
      let annotations = results.map { location -> CustomPointAnnotation in
        let annotation = CustomPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        annotation.tag = "\(location.idLocation)"

        return annotation
      }
      DispatchQueue.main.async {
        for annotation in self.mapView.annotations {
          self.mapView.removeAnnotation(annotation)
        }
        self.mapView.addAnnotations(annotations)
        if let lastLocation = annotations.last {
          let dest = lastLocation.coordinate
          let span = MKCoordinateSpan.init(latitudeDelta: 1, longitudeDelta: 1)
          let region = MKCoordinateRegion(center: dest, span: span)
          self.mapView.setRegion(region, animated: true)
        }


        self.indicatorLoading.isHidden = true
        self.indicatorLoading.stopAnimating()
      }
    }
  }

  private func addLocation(by coordinate: CLLocationCoordinate2D) {
    self.indicatorLoading.isHidden = false
    self.indicatorLoading.startAnimating()
    repository.addLocation(longitude: coordinate.longitude, latitude: coordinate.latitude) { idLocation in
      let annotation = CustomPointAnnotation()
      annotation.coordinate = coordinate
      annotation.tag = "\(idLocation)"
      self.mapView.addAnnotation(annotation)

      DispatchQueue.main.async {
        let alert = UIAlertController(title: "Successful", message: "Location added.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
          self.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true, completion: nil)
      }
    }
    self.indicatorLoading.isHidden = true
    self.indicatorLoading.stopAnimating()
  }

}

extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let annotation = view.annotation as? CustomPointAnnotation {
      performSegue(withIdentifier: "moveToDetail", sender: annotation.tag)
    }
  }
}

class CustomPointAnnotation: MKPointAnnotation {
  var tag: String!
}
