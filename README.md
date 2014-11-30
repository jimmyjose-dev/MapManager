MapManager
=====================

Map manager is a MapKit wrapper to provide route direction drawing written entirely in Swift
----------------------------------

**Updated for XCode 6.1 and iOS8.1.1**

**Features:**
>  1) Closure support 
>  
>  2) Get directions using Apple service 
>  
>  3) Get directions using Google service 


----------


**Try this too:**
https://github.com/varshylmobile/LocationManager


----------


Screenshot
==========
**Currently these methods are available**

![Screenshot](http://imgur.com/qhytrPs.png)

----------

![Screenshot](http://imgur.com/BpZ8XPx.png)



Sample code
-----------

**Directions using Apple service**

    var latOrigin = 37.331789
    var lngOrigin = -122.029620
    var coordinateOrigin = CLLocationCoordinate2D(latitude: latOrigin, longitude: lngOrigin)
    var latDestination = 37.231789
    var lngDestination = -122.029620
    var coordinateDestination = CLLocationCoordinate2D(latitude: latDestination, longitude: lngDestination)
        
    mapManager.directions(from: coordinateOrigin, to: coordinateDestination) { (route, directionInformation, boundingRegion, error) -> () in
            
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
        
    mapManager.directionsUsingGoogle(from: origin, to: destination) { (route, directionInformation, boundingRegion, error) -> () in
            
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

Contributors 
---------------
***All contributors will receive virtual high fives from me and for the heck of it lets forget you are a south paw***

![enter image description here](https://dl.dropbox.com/s/n32dq4fle8fh7l4/internet-high-five.jpg)



----------

Other Repos you might like
--------------------------

1) https://github.com/varshylmobile/LocationManager

> CLLocationManager wrapper in Swift, performs location update,
> geocoding and reverse geocoding using Apple and Google service
> 

2) https://github.com/varshylmobile/VMXMLParser

> NSXMLParser wrapper in Swift

3) https://github.com/varshylmobile/RateMyApp

> RateMyApp is a Swift class to provide gentle reminders to app user to
> rate your app

4) https://github.com/varshylmobile/TableViewCellFlip

> Vertical and Horizontal flip animation for table view cell


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

