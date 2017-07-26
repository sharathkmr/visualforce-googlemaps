// Google Maps Api call Methods
public class GeoLocation_GoogleMapsApi {
    
    // To find latitude and location from city name
    public static Location findLatLong(String city) {
        
        String url = 'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=';
        
        // create a http
        Http h = new Http();
        // create a http req
        HttpRequest req = new HttpRequest();
        // set req methods, endpoints and header
        req.setMethod('GET');
        req.setEndpoint(url+city);
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        
        // send the req and save the http response
        HttpResponse res = h.send(req);
        
        System.debug(res.getBody());
        // to store the response body which is in json format
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        // get the results
        List<Object> results = (List<Object>) body.get('results');
        Map<String, Object> resultMap = (Map<String, Object>) results.get(0);
  		
        Map<String, Object> geomentry = (Map<String, Object>) resultMap.get('geometry');
        Map<String, Object> locationMap = (Map<String, Object>) geomentry.get('location');
        
        System.debug('********** LOCATION **************');
        System.debug(locationMap);
        
        // save the lat long in new location and return it
        Location loc = Location.newInstance((Decimal) locationMap.get('lat'), 
                                            (Decimal) locationMap.get('lng'));
		
        return loc;
    }
}