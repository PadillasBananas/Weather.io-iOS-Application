//
//  ViewController.swift
//  Weather.io
//
//  Created by Aaron on 2/12/15.
//  Copyright © 2019 Team 35. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation
import Foundation

var CurrLat:Double = 0
var CurrLong:Double = 0
var Lat:Double = 32.733999
var Long:Double = -117.193293

var SearchFlag: Bool = false

class ViewController: UIViewController, CLLocationManagerDelegate {
    var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    //LONG AND LAT DISPLAY
    @IBOutlet weak var Latitude: UILabel!
    @IBOutlet weak var Longitude: UILabel!
    
    //GOOGLE PLACES
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    @IBAction func ToTime(_ sender: Any) {
        //WRTIE LAT AND LONG TO FILE
        let file = "Location.txt"
        let LatSym = "lat="
        let LongSym = "lon="
        let LatStr:String = String(format:"%.4f", Lat)
        let LongStr:String = String(format:"%.4f", Long)
        let Thisthing = LatSym + LatStr +  LongSym + LongStr
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            do {
                try Thisthing.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
        print("Choose time button")
        
        self.performSegue(withIdentifier: "TimeScreenTransition", sender: self)
        }
    }
    @IBAction func OurTeam(_ sender: Any) {
        self.performSegue(withIdentifier: "OurTeam", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.Latitude.text = ""
        self.Longitude.text = ""
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        MapSetup()
        
        //SEARCHBAR
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let subView = UIView(frame: CGRect(x: 0, y: 75.0, width: 350.0, height: 35.0))
        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        resultsViewController?.tableCellBackgroundColor = UIColor.darkGray
        resultsViewController?.tableCellSeparatorColor = UIColor.white
        resultsViewController?.secondaryTextColor = UIColor.white;
        resultsViewController?.primaryTextColor = UIColor.white;
        
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        resultsViewController?.autocompleteFilter = filter
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))!
        resultsViewController?.placeFields = fields
    }
    //LOCATION MANAGER DELEGATES
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        CurrLat = locValue.latitude
        CurrLong = locValue.longitude
        print("locations = \(Lat) \(Long)")
        self.locationManager.stopUpdatingLocation()
    }
    
    //MAP SETUP
    func MapSetup()
    {
        //MAP VIEW SETUP
        let camera = GMSCameraPosition.camera(withLatitude:Lat ,longitude:Long, zoom: 12)
        mapView = GMSMapView.map(withFrame: CGRect(x: 100, y: 100, width: 370, height: 400), camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        let marker = GMSMarker()
        marker.position = camera.target
        marker.map = mapView
        
        //STYLIZING MAP
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        //CREATE SUBVIEW
        mapView.center = self.view.center
        self.view.addSubview(mapView)
        //WRITE THE LAT AND LONG
        self.Latitude.text = "Latitude: \(Lat)"
        self.Longitude.text = "Longitude: \(Long)"
    }
    
    func CoordinateChange()
    {
        //MOVE THE CAMEREA
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: Lat, longitude: Long))
        //CLEAR MARKERS
        mapView.clear()
        //ADD NEW MARKER AT SEARCHED LOCATION
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Lat, longitude: Long)
        marker.map = mapView
        //REARRANGE LAT AND LONG
        self.Latitude.text = "Latitude: \(Lat)"
        self.Longitude.text = "Longitude: \(Long)"
    }
}

extension ViewController: GMSMapViewDelegate, GMSAutocompleteResultsViewControllerDelegate {
    //TAPPING FOR COORDINATES
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
        //CLEARS MAPVIEW
        mapView.clear()
        //MARKER
        let marker = GMSMarker()
        marker.position = coordinate
        marker.map = mapView
        //REARRANGE LAT AND LONG
        Lat = coordinate.latitude
        Long = coordinate.longitude
        self.Latitude.text = "Latitude: \(Lat)"
        self.Longitude.text = "Longitude: \(Long)"
    }
    
    //MTLOCATION BUTTON
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool{
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: CurrLat, longitude: CurrLong))
        //CLEARS MAPVIEW
        mapView.clear()
        //MARKER
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: CurrLat, longitude: CurrLong)
        marker.map = mapView
        //REARRANGE LAT AND LONG
        Lat = CurrLat
        Long = CurrLong
        self.Latitude.text = "Latitude: \(Lat)"
        self.Longitude.text = "Longitude: \(Long)"
        return true
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // PRINT SOME SHIT AND REASSIGN LONG AND LAT
        print("Place name: \(place.name)")
        print("Place address: \(place.coordinate)")
        Lat = place.coordinate.latitude
        Long = place.coordinate.longitude
        CoordinateChange()
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
