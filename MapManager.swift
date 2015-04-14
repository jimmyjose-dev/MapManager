//
//  MapManager.swift
//
//
//  Created by Jimmy Jose on 14/08/14.
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
import CoreLocation
import MapKit


typealias DirectionsCompletionHandler = ((route:MKPolyline?, directionInformation:NSDictionary?, boundingRegion:MKMapRect?, error:String?)->())?

// TODO: Documentation

class MapManager: NSObject{
    
    
    private var directionsCompletionHandler:DirectionsCompletionHandler
    private let errorNoRoutesAvailable = "No routes available"// add more error handling
    
    private let errorDictionary = ["NOT_FOUND" : "At least one of the locations specified in the request's origin, destination, or waypoints could not be geocoded",
        "ZERO_RESULTS":"No route could be found between the origin and destination",
        "MAX_WAYPOINTS_EXCEEDED":"Too many waypointss were provided in the request The maximum allowed waypoints is 8, plus the origin, and destination",
        "INVALID_REQUEST":"The provided request was invalid. Common causes of this status include an invalid parameter or parameter value",
        "OVER_QUERY_LIMIT":"Service has received too many requests from your application within the allowed time period",
        "REQUEST_DENIED":"Service denied use of the directions service by your application",
        "UNKNOWN_ERROR":"Directions request could not be processed due to a server error. Please try again"]
    
    
    override init(){
        
        super.init()
        
    }
    
    func directions(#from:CLLocationCoordinate2D,to:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        
        self.directionsCompletionHandler = directionCompletionHandler
        
        var geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(to as String, completionHandler: { (placemarksObject, error) -> Void in
            
            if(error != nil){
                
                self.directionsCompletionHandler!(route: nil,directionInformation:nil, boundingRegion: nil, error: error.localizedDescription)
                
            }else{
                
                
                var placemarks = placemarksObject as NSArray
                var placemark = placemarks.lastObject as! CLPlacemark
                
                
                var placemarkSource = MKPlacemark(coordinate: from, addressDictionary: nil)
                
                var source = MKMapItem(placemark: placemarkSource)
                var placemarkDestination = MKPlacemark(placemark: placemark)
                var destination = MKMapItem(placemark: placemarkDestination)
                
                self.directionsFor(source: source, destination: destination, directionCompletionHandler: directionCompletionHandler)
                
                
            }
        })
        
    }
    
    
    func directionsFromCurrentLocation(#to:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        
        self.directionsCompletionHandler = directionCompletionHandler
        
        var geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(to as String, completionHandler: { (placemarksObject, error) -> Void in
            
            if(error != nil){
                
                self.directionsCompletionHandler!(route: nil,directionInformation:nil, boundingRegion: nil, error: error.localizedDescription)
                
            }else{
                
                var placemarks = placemarksObject as NSArray
                var placemark = placemarks.lastObject as! CLPlacemark
                
                var source = MKMapItem.mapItemForCurrentLocation()
                
                var placemarkDestination = MKPlacemark(placemark: placemark)
                var destination = MKMapItem(placemark: placemarkDestination)
                
                self.directionsFor(source: source, destination: destination, directionCompletionHandler: directionCompletionHandler)
                
                
            }
        })
        
    }
    
    
    func directionsFromCurrentLocation(#to:CLLocationCoordinate2D,directionCompletionHandler:DirectionsCompletionHandler){
        
        var directionRequest = MKDirectionsRequest()
        
        var source = MKMapItem.mapItemForCurrentLocation()
        var placemarkDestination = MKPlacemark(coordinate: to, addressDictionary: nil)
        
        var destination = MKMapItem(placemark: placemarkDestination)
        
        directionsFor(source: source, destination: destination, directionCompletionHandler: directionCompletionHandler)
        
    }
    
    func directions(#from:CLLocationCoordinate2D, to:CLLocationCoordinate2D,directionCompletionHandler:DirectionsCompletionHandler){
        
        var directionRequest = MKDirectionsRequest()
        var placemarkSource = MKPlacemark(coordinate: from, addressDictionary: nil)
        var source = MKMapItem(placemark: placemarkSource)
        var placemarkDestination = MKPlacemark(coordinate: to, addressDictionary: nil)
        
        var destination = MKMapItem(placemark: placemarkDestination)
        
        directionsFor(source: source, destination: destination, directionCompletionHandler: directionCompletionHandler)
        
    }
    
    private func directionsFor(#source:MKMapItem, destination:MKMapItem,directionCompletionHandler:DirectionsCompletionHandler){
        
        self.directionsCompletionHandler = directionCompletionHandler
        
        var directionRequest = MKDirectionsRequest()
        directionRequest.setSource(source)
        directionRequest.setDestination(destination)
        directionRequest.transportType = MKDirectionsTransportType.Any
        directionRequest.requestsAlternateRoutes = true
        
        var directions = MKDirections(request: directionRequest)
        
        directions.calculateDirectionsWithCompletionHandler({
            (response:MKDirectionsResponse!, error:NSError!) -> Void in
            
            if (error != nil) {
                self.directionsCompletionHandler!(route: nil,directionInformation:nil, boundingRegion: nil, error: error.localizedDescription)
            }else if(response.routes.isEmpty){
                
                self.directionsCompletionHandler!(route: nil,directionInformation:nil, boundingRegion: nil, error: self.errorNoRoutesAvailable)
            }else{
                
                let route: MKRoute = response.routes[0] as! MKRoute
                let steps = route.steps as NSArray
                var stop = false
                var end_address = route.name
                var distance = route.distance.description
                var duration = route.expectedTravelTime.description
                
                var source = response.source.placemark.coordinate
                var destination = response.destination.placemark.coordinate
                
                var start_location = ["lat":source.latitude,"lng":source.longitude]
                var end_location = ["lat":destination.latitude,"lng":destination.longitude]
                
                var stepsFinalArray = NSMutableArray()
                
                steps.enumerateObjectsUsingBlock({ (obj, idx, stop) -> Void in
                    
                    var step:MKRouteStep = obj as! MKRouteStep
                    
                    var distance = step.distance.description
                    
                    var instructions = step.instructions
                    
                    var stepsDictionary = NSMutableDictionary()
                    
                    stepsDictionary.setObject(distance, forKey: "distance")
                    stepsDictionary.setObject("", forKey: "duration")
                    stepsDictionary.setObject(instructions, forKey: "instructions")
                    
                    
                    stepsFinalArray.addObject(stepsDictionary)
                    
                })
                
                var stepsDict = NSMutableDictionary()
                stepsDict.setObject(distance, forKey: "distance")
                stepsDict.setObject(duration, forKey: "duration")
                stepsDict.setObject(end_address, forKey: "end_address")
                stepsDict.setObject(end_location, forKey: "end_location")
                stepsDict.setObject("", forKey: "start_address")
                stepsDict.setObject(start_location, forKey: "start_location")
                stepsDict.setObject(stepsFinalArray, forKey: "steps")
                
                
                self.directionsCompletionHandler!(route: route.polyline,directionInformation: stepsDict, boundingRegion: route.polyline.boundingMapRect, error: nil)
            }
            
        })
    }
    
    /**
    Get directions using Google API by passing source and destination as string.
    
    :param: from Starting point of journey
    :param: to Ending point of journey
    :returns: directionCompletionHandler: Completion handler contains polyline,dictionary,maprect and error
    
    */
    
    func directionsUsingGoogle(#from:NSString, to:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        
        getDirectionsUsingGoogle(origin: from, destination: to, directionCompletionHandler: directionCompletionHandler)
        
    }
    
    func directionsUsingGoogle(#from:CLLocationCoordinate2D, to:CLLocationCoordinate2D,directionCompletionHandler:DirectionsCompletionHandler){
        
        var originLatLng = "\(from.latitude),\(from.longitude)"
        var destinationLatLng = "\(to.latitude),\(to.longitude)"
        
        getDirectionsUsingGoogle(origin: originLatLng, destination: destinationLatLng, directionCompletionHandler: directionCompletionHandler)
        
    }
    
    func directionsUsingGoogle(#from:CLLocationCoordinate2D, to:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        
        var originLatLng = "\(from.latitude),\(from.longitude)"
        
        getDirectionsUsingGoogle(origin: originLatLng, destination: to, directionCompletionHandler: directionCompletionHandler)
        
    }
    
    private func getDirectionsUsingGoogle(#origin:NSString, destination:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        
        self.directionsCompletionHandler = directionCompletionHandler
        
        var path = "http://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)"
        performOperationForURL(path)
        
    }
    
    
    private func performOperationForURL(urlString:NSString){
        
        let urlEncoded = urlString.stringByReplacingOccurrencesOfString(" ", withString: "%20")
        
        let url:NSURL? = NSURL(string:urlEncoded)
        let request:NSURLRequest = NSURLRequest(URL:url!)
        
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request,queue:queue,completionHandler:{response,data,error in
            
            if(error != nil){
                
                println(error.localizedDescription)
                
                self.directionsCompletionHandler!(route: nil,directionInformation:nil, boundingRegion: nil, error: error.localizedDescription)
                
                
            }else{
                
                let dataAsString: NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
                
                var err: NSError
                let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                
                let routes = jsonResult.objectForKey("routes") as! NSArray
                let status = jsonResult.objectForKey("status") as! NSString
                let route = routes.lastObject as! NSDictionary //first object?
                
                if(status.isEqualToString("OK") && route.allKeys.count>0){
                    
                    let legs = route.objectForKey("legs") as! NSArray
                    let steps = legs.firstObject as! NSDictionary
                    let directionInformation = self.parser(steps) as NSDictionary
                    let overviewPolyline = route.objectForKey("overview_polyline") as! NSDictionary
                    let points = overviewPolyline.objectForKey("points") as! NSString
                    
                    var locations = self.decodePolyLine(points) as Array
                    
                    var coordinates = locations.map({ (location: CLLocation) ->
                        CLLocationCoordinate2D in
                        return location.coordinate
                    })
                    var polyline = MKPolyline(coordinates: &coordinates,
                        count: locations.count)
                    
                    self.directionsCompletionHandler!(route: polyline,directionInformation:directionInformation, boundingRegion: polyline.boundingMapRect, error: nil)
                    
                }else{
                    
                    var errorMsg = self.errorDictionary[status as String]
                    
                    if(errorMsg == nil){
                        
                        errorMsg = self.errorNoRoutesAvailable
                    }
                    
                    self.directionsCompletionHandler!(route: nil,directionInformation:nil, boundingRegion: nil, error: errorMsg)
                    
                }
            }
            }
        )
        
    }
    
    
    
    private func decodePolyLine(encodedStr:NSString)->Array<CLLocation>{
        
        var array = Array<CLLocation>()
        let len = encodedStr.length
        var range = NSMakeRange(0, len)
        var strpolyline = encodedStr
        var index = 0
        var lat = 0 as Int32
        var lng = 0 as Int32
        
        strpolyline = encodedStr.stringByReplacingOccurrencesOfString("\\\\", withString: "\\", options: NSStringCompareOptions.LiteralSearch, range: range)
        
        
        while(index<len){
            
            var b = 0
            var shift = 0
            var result = 0
            
            do{
                var numUnichar = strpolyline.characterAtIndex(index++)
                var num =  NSNumber(unsignedShort: numUnichar)
                var numInt = num.integerValue
                b = numInt - 63
                
                result |= (b & 0x1f) << shift
                shift += 5
            }while(b >= 0x20)
            
            var dlat = 0
            
            if((result & 1) == 1){
                
                dlat = ~(result >> 1)
            }else{
                
                dlat = (result >> 1)
            }
            
            lat += dlat
            
            shift = 0
            result = 0
            
            do{
                var numUnichar = strpolyline.characterAtIndex(index++)
                var num =  NSNumber(unsignedShort: numUnichar)
                var numInt = num.integerValue
                b = numInt - 63
                
                result |= (b & 0x1f) << shift
                shift += 5
                
            }while(b >= 0x20)
            
            var dlng = 0
            
            if((result & 1) == 1){
                
                dlng = ~(result >> 1)
            }else{
                
                dlng = (result >> 1)
                
            }
            lng += dlng
            
            
            var latitude = NSNumber(int:lat).doubleValue * 1e-5
            var longitude = NSNumber(int:lng).doubleValue * 1e-5
            
            var location = CLLocation(latitude: latitude, longitude: longitude)
            
            array.append(location)
            
        }
        
        return array
        
    }
    
    private func parser(data:NSDictionary)->NSDictionary{
        
        var dict = NSMutableDictionary()
        var distance = (data.objectForKey("distance") as! NSDictionary).objectForKey("text") as! NSString
        
        var duration = (data.objectForKey("duration") as! NSDictionary).objectForKey("text") as! NSString
        
        var end_address = data.objectForKey("end_address") as! NSString
        var end_location = data.objectForKey("end_location") as! NSDictionary
        var start_address = data.objectForKey("start_address") as! NSString
        var start_location = data.objectForKey("start_location") as! NSDictionary
        var stepsArray = data.objectForKey("steps") as! NSArray
        
        var stepsDict = NSMutableDictionary()
        var stop = false
        
        var stepsFinalArray = NSMutableArray()
        
        stepsArray.enumerateObjectsUsingBlock { (obj, idx, stop) -> Void in
            
            var stepDict = obj as! NSDictionary
            
            var distance = (stepDict.objectForKey("distance") as! NSDictionary).objectForKey("text") as! NSString
            
            var duration = (stepDict.objectForKey("duration") as! NSDictionary).objectForKey("text") as! NSString
            var html_instructions = stepDict.objectForKey("html_instructions") as! NSString
            var end_location = stepDict.objectForKey("end_location") as! NSDictionary
            var instructions = self.removeHTMLTags((stepDict.objectForKey("html_instructions") as! NSString))
            var start_location = stepDict.objectForKey("start_location") as! NSDictionary
            
            var stepsDictionary = NSMutableDictionary()
            
            stepsDictionary.setObject(distance, forKey: "distance")
            stepsDictionary.setObject(duration, forKey: "duration")
            stepsDictionary.setObject(html_instructions, forKey: "html_instructions")
            stepsDictionary.setObject(end_location, forKey: "end_location")
            stepsDictionary.setObject(instructions, forKey: "instructions")
            stepsDictionary.setObject(start_location, forKey: "start_location")
            
            stepsFinalArray.addObject(stepsDictionary)
            
            
        }
        
        stepsDict.setObject(distance, forKey: "distance")
        stepsDict.setObject(duration, forKey: "duration")
        stepsDict.setObject(end_address, forKey: "end_address")
        stepsDict.setObject(end_location, forKey: "end_location")
        stepsDict.setObject(start_address, forKey: "start_address")
        stepsDict.setObject(start_location, forKey: "start_location")
        stepsDict.setObject(stepsFinalArray, forKey: "steps")
        
        
        return stepsDict
        
    }
    
    private func removeHTMLTags(source:NSString)->NSString{
        
        var range = NSMakeRange(0, 0)
        let HTMLTags = "<[^>]*>"
        
        var sourceString = source
        while( sourceString.rangeOfString(HTMLTags, options: NSStringCompareOptions.RegularExpressionSearch).location != NSNotFound){
            
            range = sourceString.rangeOfString(HTMLTags, options: NSStringCompareOptions.RegularExpressionSearch)
            
            sourceString = sourceString.stringByReplacingCharactersInRange(range, withString: "")
        }
        
        return sourceString;
        
    }
    
}

