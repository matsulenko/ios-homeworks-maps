//
//  ViewController.swift
//  Maps
//
//  Created by Matsulenko on 11.10.2023.
//

import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    var destinationAnnotation: MKPointAnnotation?
    
    @IBOutlet weak var removeAnnotationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocation()
        setupMaps()
    }

    private func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupMaps() {
        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        mapView.addGestureRecognizer(longPress)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.addGestureRecognizer(longPress)
        mapView.showsCompass = true
        
        if #available(iOS 17.0, *) {
            mapView.pitchButtonVisibility = .visible
            mapView.showsUserTrackingButton = true
        }
    }
    
    @objc
    func longPress(sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: mapView)
        let coordinates = mapView.convert(point, toCoordinateFrom: mapView)
        
        addAnnotation(coordinates: coordinates)
    }
    
    func addAnnotation(coordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        removeAnnotation()
        
        annotation.title = "Destination"
        destinationAnnotation = annotation
        mapView.addAnnotation(annotation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationAnnotation!.coordinate))
        request.transportType = .walking
        
        let direction = MKDirections(request: request)
        direction.calculate { [self] response, error in
            if let response, let route = response.routes.first {
                removeRoute()
                mapView.addOverlay(route.polyline)
            }
        }
    }
    
    func removeAnnotation() {
        if destinationAnnotation != nil {
            mapView.removeAnnotation(destinationAnnotation!)
        }
    }
    
    func removeRoute() {
        if let _ = self.mapView.overlays.last {
            mapView.removeOverlay(self.mapView.overlays.last!)
        }
    }
    
    
    @IBAction func removeAnnotationAndRoute(_ sender: Any) {
        if destinationAnnotation != nil {
            removeRoute()
            removeAnnotation()
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let render = MKPolylineRenderer(overlay: overlay)
            render.strokeColor = .systemBlue
            render.lineWidth = 4
            
            return render
        }
        
        return MKOverlayRenderer()
    }
}
