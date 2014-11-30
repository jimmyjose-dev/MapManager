//
//  ViewController.swift
//  Maptest
//
//  Created by Jimmy Jose on 18/08/14.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import UIKit
import MapKit


class ViewController: UIViewController,UITextFieldDelegate,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate{
    
    @IBOutlet var mapView:MKMapView? = MKMapView()
    @IBOutlet var textfieldTo:UITextField? = UITextField()
    @IBOutlet var textfieldFrom:UITextField? = UITextField()
    @IBOutlet var textfieldToCurrentLocation:UITextField? = UITextField()
    @IBOutlet var textView:UITextView? = UITextView()
    @IBOutlet var tableView:UITableView? = UITableView()
    
    
    var tableData = NSArray()
    
    var mapManager = MapManager()
    
    var locationManager: CLLocationManager!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        
        //[CLLocationManager requestWhenInUseAuthorization];
        //[CLLocationManager requestAlwaysAuthorization]
        
        let address = "1 Infinite Loop, CA, USA"
        
        textfieldTo?.delegate = self
        textfieldFrom?.delegate = self
        
        self.mapView?.delegate = self
        
    }
    
    func mapViewWillStartLocatingUser(mapView: MKMapView!) {
        
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            println("done")
            return polylineRenderer
        }
        
        return nil
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        
        return 1
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        
        return tableData.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "direction")
        
        var idx:Int = indexPath.row
        
        
        var dictTable:NSDictionary = tableData[idx] as NSDictionary
        var instruction = dictTable["instructions"] as NSString
        var distance = dictTable["distance"] as NSString
        var duration = dictTable["duration"] as NSString
        var detail = "distance:\(distance) duration:\(duration)"
        
        
        cell.textLabel.text = instruction
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel.font = UIFont(name: "Helvetica Neue Light", size: 15.0)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        //cell.textLabel.font=  [UIFont fontWithName:"Helvetica Neue-Light" size:15];
        cell.detailTextLabel!.text = detail
        
        
        return cell
    }
    
    @IBAction func usingGoogleButtonPressed(sender:UIButton){
        
        var origin = textfieldFrom?.text
        var destination =  textfieldTo?.text
        origin = origin?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        destination = destination?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if(origin == nil || (countElements(origin!) == 0) || destination == nil || countElements(destination!) == 0)
        {
            
            println("enter to and from")
            return
        }
        self.view.endEditing(true)
        
        mapManager.directionsUsingGoogle(from: origin!, to: destination!) { (route,directionInformation, boundingRegion, error) -> () in
            
            if(error != nil){
                
                println(error)
            }else{
                
                var pointOfOrigin = MKPointAnnotation()
                pointOfOrigin.coordinate = route!.coordinate
                pointOfOrigin.title = directionInformation?.objectForKey("start_address") as NSString
                pointOfOrigin.subtitle = directionInformation?.objectForKey("duration") as NSString
                
                var pointOfDestination = MKPointAnnotation()
                pointOfDestination.coordinate = route!.coordinate
                pointOfDestination.title = directionInformation?.objectForKey("end_address") as NSString
                pointOfDestination.subtitle = directionInformation?.objectForKey("distance") as NSString
                
                var start_location = directionInformation?.objectForKey("start_location") as NSDictionary
                var originLat = start_location.objectForKey("lat")?.doubleValue
                var originLng = start_location.objectForKey("lng")?.doubleValue
                
                var end_location = directionInformation?.objectForKey("end_location") as NSDictionary
                var destLat = end_location.objectForKey("lat")?.doubleValue
                var destLng = end_location.objectForKey("lng")?.doubleValue
                
                var coordOrigin = CLLocationCoordinate2D(latitude: originLat!, longitude: originLng!)
                var coordDesitination = CLLocationCoordinate2D(latitude: destLat!, longitude: destLng!)
                
                pointOfOrigin.coordinate = coordOrigin
                pointOfDestination.coordinate = coordDesitination
                if let web = self.mapView?{
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        web.addOverlay(route!)
                        web.addAnnotation(pointOfOrigin)
                        web.addAnnotation(pointOfDestination)
                        web.setVisibleMapRect(boundingRegion!, animated: true)
                        self.tableView?.delegate = self
                        self.tableView?.dataSource = self
                        self.tableData = directionInformation?.objectForKey("steps") as NSArray
                        self.tableView?.reloadData()
                        
                    }
                    
                }
                
            }
        }
        
        
        
    }
    
    @IBAction func usingAppleButtonPressed(sender:UIButton){
        
        var destination =  textfieldToCurrentLocation?.text
        
        if(destination == nil || countElements(destination!) == 0)
        {
            
            println("enter to and from")
            return
        }
        
        self.view.endEditing(true)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // locationManager.locationServicesEnabled
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        if (locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization"))) {
            
            //locationManager.requestAlwaysAuthorization() // add in plist NSLocationAlwaysUsageDescription
            locationManager.requestWhenInUseAuthorization() // add in plist NSLocationWhenInUseUsageDescription
            
        }
        
        //var location = self.mapView?.userLocation
        
        //var from = location?.coordinate
        
        
        
        
        
    }
    
    func getDirectionsUsingApple() {
        
        var destination =  textfieldToCurrentLocation?.text
        mapManager.directionsFromCurrentLocation(to: destination!) { (route, directionInformation, boundingRegion, error) -> () in
            
            if (error? != nil) {
                
                println(error!)
            }else{
                
                if let web = self.mapView?{
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        web.addOverlay(route!)
                        web.setVisibleMapRect(boundingRegion!, animated: true)
                        
                        self.tableView?.delegate = self
                        self.tableView?.dataSource = self
                        self.tableData = directionInformation?.objectForKey("steps") as NSArray
                        self.tableView?.reloadData()
                        
                    }
                    
                }
            }
            
        }
        
        
    }
    
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var hasAuthorised = false
            var locationStatus:NSString = ""
            var verboseKey = status
            switch status {
            case CLAuthorizationStatus.Restricted:
                locationStatus = "Restricted Access"
            case CLAuthorizationStatus.Denied:
                locationStatus = "Denied access"
            case CLAuthorizationStatus.NotDetermined:
                locationStatus = "Not determined"
            default:
                locationStatus = "Allowed access"
                hasAuthorised = true
            }
            
            
            
            if(hasAuthorised == true){
                
                getDirectionsUsingApple()
                
            }else {
                
                println("locationStatus \(locationStatus)")
                
            }
            
    }
    
}

