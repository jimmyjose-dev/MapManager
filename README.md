MapManager
=====================

Map manager is a MapKit wrapper to provide route direction drawing written entirely in Swift
----------------------------------
**Features:**
>  1) Closure support 
>  
>  2) Get directions using Apple service 
>  
>  3) Get directions using Google service 

Screenshot
==========

![Screenshot](http://imgur.com/SlRsKUZ.png)



Sample code
-----------

**Directions using Apple service**

    var latOrigin = 37.331789
    var lngOrigin = -122.029620
    var coordinateOrigin = CLLocationCoordinate2D(latitude: latOrigin, longitude: lngOrigin)
    var latDestination = 37.231789
    var lngDestination = -122.029620
    var coordinateDestination = CLLocationCoordinate2D(latitude: latDestination, longitude: lngDestination)
        
    mapManager.directionsFor(origin: coordinateOrigin, destination: coordinateDestination) { (route, boundingRegion, error) -> () in
            
        if (error? != nil) {
                
            println(error!)
        }else{
                
            if let web = self.mapView?{
                    
                dispatch_async(dispatch_get_main_queue()) {
                        
                    web.addOverlay(route!)
                    web.setVisibleMapRect(boundingRegion!, animated: true)
                        
                    }
                    
                }
            }
            
        }
            

**Directions using Google service**

    var origin = "Toronto"
    var destination =  "Montreal"
        
    mapManager.directionsUsingGoogleFor(origin: origin, destination: destination) { (route, boundingRegion, error) -> () in
            
        if(error != nil){
                
            println(error!)
        }else{
                
            if let web = self.mapView?{
                    
                dispatch_async(dispatch_get_main_queue()) {
                    web.addOverlay(route!)
                    web.setVisibleMapRect(boundingRegion!, animated: true)
                	}
                    
            	}
                
        	}
    	}

----------

Roadmap
---------------

 - Refactor code and use MKGeodesicPolyline
 - Add few more features

----------
Contact Us
---------------

Have any questions or suggestions feel free to write at jimmy@varshyl.com (Jimmy Jose)
http://www.varshylmobile.com/

----------
## License

The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
