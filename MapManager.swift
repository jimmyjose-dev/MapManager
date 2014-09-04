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


typealias DirectionsCompletionHandler = ((route:MKPolyline?, boundingRegion:MKMapRect?, error:String?)->())?

class MapManager: NSObject{
    
    
    private var directionsCompletionHandler:DirectionsCompletionHandler
    
    override init(){
        
        super.init()
        
    }
    
    
    func directionsFor(#origin:CLLocationCoordinate2D, destination:CLLocationCoordinate2D,directionCompletionHandler:DirectionsCompletionHandler){
        
        self.directionsCompletionHandler = directionCompletionHandler
        
        var directionRequest = MKDirectionsRequest()
        var placemarkSource = MKPlacemark(coordinate: origin, addressDictionary: nil)
        var source = MKMapItem(placemark: placemarkSource)//MKMapItem.mapItemForCurrentLocation()
        var placemarkDestination = MKPlacemark(coordinate: destination, addressDictionary: nil)
        
        var dest = MKMapItem(placemark: placemarkDestination)
        
        directionRequest.setSource(source)
        directionRequest.setDestination(dest)
        directionRequest.transportType = MKDirectionsTransportType.Any
        directionRequest.requestsAlternateRoutes = true
        
        var directions = MKDirections(request: directionRequest)
        
        directions.calculateDirectionsWithCompletionHandler({
            (response:MKDirectionsResponse!, error:NSError!) -> Void in
            
            if (error? != nil) {
                
                self.directionsCompletionHandler!(route: nil, boundingRegion: nil, error: error.localizedDescription)
            }else if(response.routes.isEmpty){
                
                self.directionsCompletionHandler!(route: nil, boundingRegion: nil, error: "no route available")
            }else{
                
                let route: MKRoute = response.routes[0] as MKRoute
                
                self.directionsCompletionHandler!(route: route.polyline, boundingRegion: route.polyline.boundingMapRect, error: nil)
            }
            
        })
    }
    
    
    func directionsUsingGoogleFor(#origin:NSString, destination:NSString,directionCompletionHandler:DirectionsCompletionHandler){
        
        self.directionsCompletionHandler = directionCompletionHandler
        
        var path = "http://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)"
        performOperationForURL(path)
        
    }
    
    
    private func performOperationForURL(urlString:NSString){
        
        let url:NSURL = NSURL(string:urlString)
        
        let request:NSURLRequest = NSURLRequest(URL:url)
        
        let queue:NSOperationQueue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(request,queue:queue,completionHandler:{response,data,error in
            
            if(error != nil){
                
                println(error.localizedDescription)
                
                self.directionsCompletionHandler!(route: nil, boundingRegion: nil, error: error.localizedDescription)
                
                
            }else{
                
                let dataAsString: NSString = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                var err: NSError
                let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                
                let routes = jsonResult.objectForKey("routes") as NSArray
                let route = routes.lastObject as NSDictionary //first object?
                
                if(route.allKeys.count>0){
                    
                    let overviewPolyline = route.objectForKey("overview_polyline") as NSDictionary
                    let points = overviewPolyline.objectForKey("points") as NSString
                    
                    var locations = self.decodePolyLine(points) as Array
                    
                    var coordinates = locations.map({ (location: CLLocation) ->
                        CLLocationCoordinate2D in
                        return location.coordinate
                    })
                    var polyline = MKPolyline(coordinates: &coordinates,
                        count: locations.count)
                    
                    self.directionsCompletionHandler!(route: polyline, boundingRegion: polyline.boundingMapRect, error: nil)
                    
                }
            }
            }
        )
        
    }
    
    
    func decodePolyLine(encodedStr:NSString)->Array<CLLocation>{
        
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
                b = strpolyline.characterAtIndex(index++)  - 63
                result |= (b & 0x1f) << shift
                shift += 5
            }while(b >= 0x20)
            
            var dlat = 0
            
            if((result & 1) == true){
                
                dlat = ~(result >> 1)
            }else{
                
                dlat = (result >> 1)
            }
            
            lat += dlat
            
            shift = 0
            result = 0
            
            do{
                b = strpolyline.characterAtIndex(index++)  - 63
                result |= (b & 0x1f) << shift
                shift += 5
                
            }while(b >= 0x20)
            
            var dlng = 0
            
            if((result & 1) == true){
                
                dlng = ~(result >> 1)
            }else{
                
                dlng = (result >> 1)
                
            }
            lng += dlng
            
            
            var latitude = NSNumber.numberWithInt(lat).doubleValue * 1e-5
            var longitude = NSNumber.numberWithInt(lng).doubleValue * 1e-5
            
            var location = CLLocation(latitude: latitude, longitude: longitude)
            
            array.append(location)
            
        }
        
        return array
        
    }
    
}

