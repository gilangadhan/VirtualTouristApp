//
//  ViewController.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 10/07/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
  private lazy var dataProvider: LocaleProvider = { return LocaleProvider() }()
  private var locations: [LocationEntity] = []
  private let newPin = MKPointAnnotation()

  @IBOutlet var mapView: MKMapView!

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
    dataProvider.getAllLocations { results in
      self.locations = results
      let annotations = results.map { location -> CustomPointAnnotation in
        let annotation = CustomPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        annotation.tag = "\(location.idLocation)"
        return annotation
      }
      self.mapView.addAnnotations(annotations)
    }
  }

  private func addLocation(by coordinate: CLLocationCoordinate2D) {
    dataProvider.addLocation(longitude: coordinate.longitude, latitude: coordinate.latitude) { idLocation in
      let annotation = CustomPointAnnotation()
      annotation.coordinate = coordinate
      annotation.tag = "\(idLocation)"
      self.mapView.addAnnotation(annotation)

      DispatchQueue.main.async {
        let alert = UIAlertController(title: "Successful", message: "Member updated.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
          self.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true, completion: nil)
      }
    }
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
