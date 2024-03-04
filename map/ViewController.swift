//
//  ViewController.swift


import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Background Image
    @IBOutlet var backgroundImage: UIImageView!
    
    // App title View
    @IBOutlet var titleLabelView: UIView!
    
    // Start trip Button View
    @IBOutlet var startTripButton: UIButton!
    
    // Stop trip Button View
    @IBOutlet var stopTripButton: UIButton!
    
    // Map View
    @IBOutlet var myMapView: MKMapView!
    
    // My current speed LabelView
    @IBOutlet var myCurrentSpeedLabelView: UILabel!
    
    // My maximum speed LabelView
    @IBOutlet var myMaximumSpeedLabelView: UILabel!
    
    // My average speed LabelView
    @IBOutlet var myAverageSpeedLabelView: UILabel!
    
    // My Travel distance LabelView
    @IBOutlet var myTravelDistanceLabelView: UILabel!
    
    // My Safe Travel distance LabelView
    @IBOutlet var mySafeTravelDistanceLabelView: UILabel!
    
    // My maximum acceleration LabelView
    @IBOutlet var maximumAccelerationLabelView: UILabel!
    
    // My top bar LabelView
    @IBOutlet var topBarLabelView: UILabel!
    
    // Map ZoomIn Button
    @IBOutlet var zoonInButton: UIButton!
    
    // Map ZoomOut Button
    @IBOutlet var zoonOutButton: UIButton!
    
    // My bottom bar LabelView
    @IBOutlet var bottomBarLabelView: UILabel!
    
    
    let grayColor = UIColor(red: 130/255, green: 130/255, blue: 130/255, alpha: 1).cgColor
    
    // Required variable declaration
    let myLocationManager = CLLocationManager()       // Variable for Location service
    var isMyTripStarted = false                       // It show's my trip is ongoing or not
    var startTime: Date?                              // It can store trip start time
    var myStartLocation: CLLocation?                  // It can store trip start location
    var myPreviousLocation: CLLocation?               // It can store last trip location
    var myMaximumSpeed: CLLocationSpeed = 0           // It can store last trip location
    var myTotalTravelDistance: CLLocationDistance = 0 // It can store total travel distance
    var myMaximumAcceleration: Double = 0             // It can store maximum acceleration
    var additionOfEverySpeed: CLLocationSpeed = 0     // It can add each speed
    var numberOfSpeedUpdatesCount = 0                 // It can store number of each speed updates
    var latLngMeters = 500                            // Zoom in/out meter
    var safeTravelDistance = 0
    var myCordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0) // It can store coordinate of location defalt is zero

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---------- Initialization for location service
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.distanceFilter = kCLDistanceFilterNone
        myMapView.showsUserLocation = true
        
        //---------- Background Imageview with opacity
        backgroundImage.layer.opacity = 0.15
        
        //---------- Set UI for Top/Bottom bar
        topBarLabelView.layer.backgroundColor = grayColor
        bottomBarLabelView.layer.backgroundColor = grayColor
        topBarLabelView.text = "Waiting to start trip"
        bottomBarLabelView.text = "Waiting to start trip"
        topBarLabelView.layer.cornerRadius = 7
        bottomBarLabelView.layer.cornerRadius = 7
        
        
        //---------- Set UI for Top/Bottom bar
        zoonInButton.layer.cornerRadius = 7
        zoonOutButton.layer.cornerRadius = 7
        zoonInButton.layer.backgroundColor = UIColor.black.withAlphaComponent(0).cgColor
        zoonInButton.setTitleColor(UIColor.white.withAlphaComponent(0), for: .normal)
        zoonOutButton.layer.backgroundColor = UIColor.black.withAlphaComponent(0).cgColor
        zoonOutButton.setTitleColor(UIColor.white.withAlphaComponent(0), for: .normal)
        
        
        //---------- Title View, Start/Stop Button
        titleLabelView.layer.cornerRadius = 7
        startTripButton.layer.cornerRadius = 7
        stopTripButton.layer.cornerRadius = 7
        
       
        //---------- MapView
        myMapView.layer.cornerRadius = 10
        myMapView.layer.borderColor = UIColor.black.cgColor
        myMapView.layer.borderWidth = 0.5
        
    }

    
    // Function for start trip
    @IBAction func startTripButtonPressed(_ sender: UIButton) {
        
        // Reset all variable
        isMyTripStarted = true
        startTime = Date()
        myStartLocation = nil
        myPreviousLocation = nil
        myMaximumSpeed = 0
        myTotalTravelDistance = 0
        myMaximumAcceleration = 0
        additionOfEverySpeed = 0
        numberOfSpeedUpdatesCount = 0
        
        // Update UI for Top/Bottom bar
        topBarLabelView.layer.backgroundColor = UIColor.green.cgColor
        bottomBarLabelView.layer.backgroundColor = UIColor.green.cgColor
        topBarLabelView.text = "Trip Started"
        bottomBarLabelView.text = "Trip Started"
        mySafeTravelDistanceLabelView.layer.backgroundColor = UIColor.white.withAlphaComponent(0).cgColor
        mySafeTravelDistanceLabelView.text = "0.00 km"
        
        // Update UI for Zoom In/Out button
        zoonInButton.layer.backgroundColor = UIColor.black.cgColor
        zoonOutButton.layer.backgroundColor = UIColor.black.cgColor
        zoonInButton.setTitleColor(UIColor.white, for: .normal)
        zoonInButton.setTitleColor(UIColor.white, for: .normal)

        
        // Start location service
        myLocationManager.startUpdatingLocation()
        myMapView.showsUserLocation = true
    }

    
    // Function for Stop trip
    @IBAction func stopTripButtonPressed(_ sender: UIButton) {
        
        // Stop location service
        myLocationManager.stopUpdatingLocation()
        myMapView.showsUserLocation = false
        latLngMeters = 300
        let region = MKCoordinateRegion(center: myCordinates, latitudinalMeters: Double(latLngMeters), longitudinalMeters: Double(latLngMeters))
        myMapView.setRegion(region, animated: true)
        
        
        isMyTripStarted = false
        
        
        // Update UI for Top/Bottom bar
        topBarLabelView.layer.backgroundColor = grayColor
        bottomBarLabelView.layer.backgroundColor = grayColor
        topBarLabelView.text = "Trip Stoped"
        bottomBarLabelView.text = "Trip Stoped"
        
        
        // Update UI for Zoom In/Out button
        zoonInButton.layer.backgroundColor = UIColor.black.withAlphaComponent(0).cgColor
        zoonInButton.setTitleColor(UIColor.white.withAlphaComponent(0), for: .normal)
        zoonOutButton.layer.backgroundColor = UIColor.black.withAlphaComponent(0).cgColor
        zoonOutButton.setTitleColor(UIColor.white.withAlphaComponent(0), for: .normal)
    
    }

    
    // Function for User Location Service
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Store last location on starting point
        let myLastlocation = locations.last!

        if ( isMyTripStarted == true ) {
            if let startTime = startTime {
                
                // return time duration from start to end
                let timeDifference = myLastlocation.timestamp.timeIntervalSince(startTime)
                
                
                // return total travel distance from starting point
                let myTravelDistance = myLastlocation.distance(from: myStartLocation ?? myLastlocation)
                
                
                // return speed in m/s ( 1 m/s to 1 km/h = speed * 3.6 )
                let myRunningSpeed = myLastlocation.speed
                
                
                // Calculate my current speed in km/h
                let myCurrentSpeed = myRunningSpeed * 3.6
                myCurrentSpeedLabelView.text = "\(String(format : "%.2f", myCurrentSpeed)) km/h"

                
                // Calculate my maximum speed in km/h
                if ( myRunningSpeed * 3.6 > myMaximumSpeed ) {
                    myMaximumSpeed = myRunningSpeed * 3.6
                    myMaximumSpeedLabelView.text = "\(String(format : "%.2f", myMaximumSpeed)) km/h"
                }

                
                // Calculate my average speed in km/h
                additionOfEverySpeed = additionOfEverySpeed + myRunningSpeed
                numberOfSpeedUpdatesCount = numberOfSpeedUpdatesCount + 1
                let averageSpeed = ( additionOfEverySpeed / Double(numberOfSpeedUpdatesCount)) * 3.6
                myAverageSpeedLabelView.text = "\(String(format : "%.2f", averageSpeed)) km/h"

                
                // Calculate total travel distance in km
                myTotalTravelDistance = ( myTotalTravelDistance + myTravelDistance ) / 1000
                myTravelDistanceLabelView.text = "\(String(format : "%.2f", myTotalTravelDistance)) km"
                
                
                // Calculate my maximum acceleration in m/s^2
                if let previousLocation = myPreviousLocation {
                    let timeInterval = myLastlocation.timestamp.timeIntervalSince(previousLocation.timestamp)
                    let acceleration = abs((myLastlocation.speed - previousLocation.speed) / timeInterval)

                    if ( acceleration > myMaximumAcceleration ) {
                        myMaximumAcceleration = acceleration
                        maximumAccelerationLabelView.text = "\(String(format : "%.2f", myMaximumAcceleration)) m/s^2"
                    }
                }
                

                if ( myRunningSpeed * 3.6 > 115 ) {
                    topBarLabelView.layer.backgroundColor = UIColor.red.cgColor
                    if(mySafeTravelDistanceLabelView.text == "0.00 km"){
                        mySafeTravelDistanceLabelView.text = "\(String(format : "%.2f", myTotalTravelDistance)) km"
                        mySafeTravelDistanceLabelView.layer.backgroundColor = UIColor.green.cgColor
                    }
                    
                }else{
                    topBarLabelView.layer.backgroundColor = UIColor.green.cgColor
                   
                }

                // Display Location with appropriate meters
                myCordinates = myLastlocation.coordinate
                let region = MKCoordinateRegion(center: myCordinates, latitudinalMeters: Double(latLngMeters), longitudinalMeters: Double(latLngMeters))
                myMapView.setRegion(region, animated: true)

                myStartLocation = myStartLocation ?? myLastlocation
                myPreviousLocation = myLastlocation
            }
        }
    }
    
    
    // Function for Zoom In Map
    @IBAction func zoomInMap(_ sender: Any) {
        if ( isMyTripStarted == true ) {
            if(latLngMeters >= 50){
                latLngMeters = latLngMeters - 50
            }
            let region = MKCoordinateRegion(center: myCordinates, latitudinalMeters: Double(latLngMeters), longitudinalMeters: Double(latLngMeters))
            myMapView.setRegion(region, animated: true)
        }
     }
    
    
    // Function for Zoom Out Map
    @IBAction func zoomOutMap(_ sender: Any) {
        if ( isMyTripStarted == true ) {
            if(latLngMeters <= 2000){
                latLngMeters = latLngMeters + 50
            }
            let region = MKCoordinateRegion(center: myCordinates, latitudinalMeters: Double(latLngMeters), longitudinalMeters: Double(latLngMeters))
            myMapView.setRegion(region, animated: true)
        }
    }
    
}
