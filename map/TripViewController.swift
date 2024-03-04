//
//  TripViewController.swift
//  Jaykumar_Lukhi_8941198_Lab7
//
//  Created by user223434 on 11/11/23.
//
import UIKit
import CoreLocation
import MapKit

class TripViewController: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var startLocation: CLLocation?
    var previousLocation: CLLocation?
    var startTime: Date?
    var distanceTravelled: CLLocationDistance = 0
    var maxSpeed: CLLocationSpeed = 0
    var maxAcceleration: Double = 0
    var totalSpeed: CLLocationSpeed = 0
    var numberOfSpeedUpdates = 0
    var topBar: UIView
    var bottomBar: UIView

    init(topBar: UIView, bottomBar: UIView) {
        self.topBar = topBar
        self.bottomBar = bottomBar
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func startTrip() {
        startTime = Date()
        startLocation = nil
        previousLocation = nil
        distanceTravelled = 0
        maxSpeed = 0
        maxAcceleration = 0
        totalSpeed = 0
        numberOfSpeedUpdates = 0
        topBar.backgroundColor = .green
        bottomBar.backgroundColor = .green
        locationManager.startUpdatingLocation()
    }

    func stopTrip() {
        locationManager.stopUpdatingLocation()
        topBar.backgroundColor = .gray
        bottomBar.backgroundColor = .gray
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        if let startTime = startTime {
            let timeDifference = location.timestamp.timeIntervalSince(startTime)
            let distance = location.distance(from: startLocation ?? location)
            let speed = location.speed

            if let previousLocation = previousLocation {
                let timeInterval = location.timestamp.timeIntervalSince(previousLocation.timestamp)
                let acceleration = abs((location.speed - previousLocation.speed) / timeInterval)

                if acceleration > maxAcceleration {
                    maxAcceleration = acceleration
                }
            }

            if speed > maxSpeed {
                maxSpeed = speed
            }

            totalSpeed += speed
            numberOfSpeedUpdates += 1
            let avgSpeed = totalSpeed / Double(numberOfSpeedUpdates)

            distanceTravelled += distance

            if speed > 31.9444 { // Speed limit in m/s (115 km/h)
                topBar.backgroundColor = .red
            }

            // Update the map here with the new location
            updateMap(location: location)

            startLocation = startLocation ?? location
            previousLocation = location
        }
    }

    func updateMap(location: CLLocation) {
        // Update the map view with the new location
    }
}

class YourViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var currentSpeedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var maxAccelerationLabel: UILabel!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var bottomBar: UIView!


}

