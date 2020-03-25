//
//  ViewController.swift
//  AutoTextFiledDemoGoogle
//
//  Created by apple on 11/23/19.
//  Copyright © 2019 Zerones. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var sourceView: UIView!
    @IBOutlet weak var destinationView: UIView!
    @IBOutlet var txtdestinationlocation: UITextField!
    @IBOutlet var tvData: UITableView!
    @IBOutlet var txtAddress: UITextField!
    @IBOutlet var mapview: MKMapView!
    var autocompleteResults :[GApiResponse.Autocomplete] = []
    var locationTitle : String!
    var latitude : Double!
    var longitude : Double!
    var latitude1 : Double!
    var longitude1 : Double!
    var pickupAddress : String!
    var pickUpCoordinates : CLLocationCoordinate2D!
    var destinationCoordinates : CLLocationCoordinate2D!
    var destinationAddress : String!
    let locationManager = CLLocationManager()
    let myAnnotation: MKPointAnnotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tvData.isHidden = true
        DispatchQueue.main.async {
            self.currentLocation()
        }
        self.destinationView.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func showResults(string:String){
        var input = GInput()
        input.keyword = string
        DispatchQueue.main.async {
            GoogleApi.shared.callApi(input: input) { (response) in
                if response.isValidFor(.autocomplete) {
                    DispatchQueue.main.async {
                        self.tvData.isHidden = false
                        self.autocompleteResults.removeAll()
                        self.autocompleteResults = response.data as! [GApiResponse.Autocomplete]
                        self.tvData.reloadData()
                    }
                } else { print(response.error ?? "ERROR") }
            }
        }
    }
    
    func hideResults(){
        autocompleteResults.removeAll()
        tvData.reloadData()
        tvData.isHidden = true
    }
    
    func currentLocation() {
        
        if CLLocationManager.locationServicesEnabled() == true {
            if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied ||  CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            DispatchQueue.main.async {
                self.locationManager.startUpdatingLocation()
            }
            locationManager.requestWhenInUseAuthorization()
            
            if locationManager.location != nil {
                self.latitude1 = locationManager.location?.coordinate.latitude
                self.longitude1 = locationManager.location?.coordinate.longitude
                
                let geoCoder = CLGeocoder()
                let location = CLLocation(latitude:self.latitude1 , longitude: self.longitude1)
                
                geoCoder.reverseGeocodeLocation(location)
                {
                    (placemarks, error) -> Void in
                    
                    let placeArray = placemarks
                    
                    // Place details
                    var placeMark: CLPlacemark!
                    placeMark = placeArray?[0]
                    
                    if  placeMark != nil {
                        self.myAnnotation.coordinate = CLLocationCoordinate2DMake(self.latitude1, self.longitude1)
                        self.myAnnotation.title = placeMark.locality!
                        self.txtAddress.text = "\(placeMark.name! + " " + placeMark.administrativeArea! + " " + placeMark.locality! + " " + placeMark.country! + " " + placeMark.postalCode!)"
                    }
                }
                
            }
        } else {
            print("Please turn on location services or GPS")
        }
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapview.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapview.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapview.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    func mapPin(){
        if txtAddress.text?.count == 0{
            Toast.showNegativeMessage(message: "Please select pickup address")
        }else if txtdestinationlocation.text?.count == 0 {
            Toast.showNegativeMessage(message: "Please select destination address")
        }else{
            if pickUpCoordinates != nil && destinationCoordinates != nil{
                self.showRouteOnMap(pickupCoordinate: pickUpCoordinates, destinationCoordinate: destinationCoordinates)
            }else{
                self.showRouteOnMap(pickupCoordinate: pickUpCoordinates, destinationCoordinate: destinationCoordinates)
            }
        }
    }
}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        hideResults()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtAddress{
            let text = textField.text! as NSString
            let fullText = text.replacingCharacters(in: range, with: string)
            if fullText.count > 0 {
                DispatchQueue.main.async {
                    self.showResults(string:fullText)
                }
            }else{
                hideResults()
            }
        }
        else if textField == txtdestinationlocation{
            let text = textField.text! as NSString
            let fullText = text.replacingCharacters(in: range, with: string)
            if fullText.count > 0 {
                DispatchQueue.main.async {
                    self.showResults(string:fullText)
                }
            }else{
                hideResults()
            }
        }else{
            
        }
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == txtAddress {
            self.txtAddress.text = self.pickupAddress
        }else if textField == txtdestinationlocation {
            self.txtdestinationlocation.text = self.destinationAddress
            self.mapPin()
        }else{
            
        }
        return true
    }
}

extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        var input = GInput()
        let destination = GLocation.init(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude)
        input.destinationCoordinate = destination
        GoogleApi.shared.callApi(.reverseGeo , input: input) { (response) in
            if let places = response.data as? [GApiResponse.ReverseGio], response.isValidFor(.reverseGeo) {
                DispatchQueue.main.async {
                    print(places)
                }
            } else { print(response.error ?? "ERROR") }
        }
    }
}

extension ViewController : UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : TableViewCell = tvData.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.lblLocation.text = autocompleteResults[indexPath.row].formattedAddress
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.pickupAddress = autocompleteResults[indexPath.row].formattedAddress
        self.destinationAddress = autocompleteResults[indexPath.row].formattedAddress
        self.locationTitle = autocompleteResults[indexPath.row].formattedAddress
        txtAddress.resignFirstResponder()
        txtdestinationlocation.resignFirstResponder()
        if txtAddress.text != nil{
            var input = GInput()
            input.keyword = autocompleteResults[indexPath.row].placeId
            DispatchQueue.main.async {
                GoogleApi.shared.callApi(.placeInformation,input: input) { (response) in
                    print(response)
                    if let place =  response.data as? GApiResponse.PlaceInfo, response.isValidFor(.placeInformation) {
                        DispatchQueue.main.async {
                            
                            if let lat = place.latitude, let lng = place.longitude{
                                print(lat)
                                print(lng)
                                self.latitude = place.latitude
                                self.longitude = place .longitude
                                var currentLocation:CLLocationCoordinate2D!
                                currentLocation = CLLocationCoordinate2D(latitude:self.latitude, longitude: self.longitude)
                                self.pickUpCoordinates = currentLocation
                                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                let region = MKCoordinateRegion(center: currentLocation, span: span)
                                self.mapview.setRegion(region, animated: true)
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = currentLocation
                                annotation.title = self.locationTitle
                                self.mapview.addAnnotation(annotation)
                                self.tvData.isHidden = true
                                self.tvData.reloadData()
                            }
                            else{
                                print("nothing")
                            }
                        }
                    } else { print(response.error ?? "ERROR") }
                }
            }
        }else if txtdestinationlocation.text != nil{
            var input = GInput()
            input.keyword = autocompleteResults[indexPath.row].placeId
            DispatchQueue.main.async {
                GoogleApi.shared.callApi(.placeInformation,input: input) { (response) in
                    print(response)
                    if let place =  response.data as? GApiResponse.PlaceInfo, response.isValidFor(.placeInformation) {
                        DispatchQueue.main.async {
                            
                            if let lat = place.latitude, let lng = place.longitude{
                                print(lat)
                                print(lng)
                                self.latitude = place.latitude
                                self.longitude = place .longitude
                                var currentLocation1:CLLocationCoordinate2D!
                                currentLocation1 = CLLocationCoordinate2D(latitude:self.latitude, longitude: self.longitude)
                                self.destinationCoordinates = currentLocation1
                                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                let region = MKCoordinateRegion(center: currentLocation1, span: span)
                                self.mapview.setRegion(region, animated: true)
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = currentLocation1
                                annotation.title = self.locationTitle
                                self.mapview.addAnnotation(annotation)
                                self.tvData.isHidden = true
                                self.tvData.reloadData()
                            }
                            else{
                                print("nothing")
                            }
                        }
                    } else { print(response.error ?? "ERROR") }
                }
            }
        }else{
            
        }
        
    }
}
