//
//  ViewController.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 10/07/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate{

  @IBOutlet var mapView: MKMapView!
  let newPin = MKPointAnnotation()

  override func viewDidLoad() {
    super.viewDidLoad()

    mapView.delegate = self
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPress(_:))) // colon needs to pass through info
    longPress.minimumPressDuration = 1.0
    mapView.addGestureRecognizer(longPress)
  }

  @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
    if recognizer.state != .began { return }

    print("A long press has been detected.")

    let touchedAt = recognizer.location(in: self.mapView) // adds the location on the view it was pressed
    let touchedAtCoordinate = mapView.convert(touchedAt, toCoordinateFrom: self.mapView) // will get coordinates

    let newPin = MKPointAnnotation()
    newPin.coordinate = touchedAtCoordinate
    mapView.addAnnotation(newPin)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "moveToDetail" {
      _ = segue.destination as! CollectionPhotosViewController
    }
  }
}

extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    performSegue(withIdentifier: "moveToDetail", sender: nil)
  }
}
