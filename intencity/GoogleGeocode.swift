//
//  GoogleGeocode.swift
//  Intencity
//
//  Created by Greg Dalfonso on 4/23/17.
//  Copyright © 2017 Nick Piscopio. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class GoogleGeocode: NSObject, ServiceDelegate, CLLocationManagerDelegate {
    
    
    // Service end-point
    let GOOGLE_GEOCODE_ENDPOINT = "https://maps.googleapis.com/maps/api/geocode/json"
    
    // Parameters
    let PARAMETER_LAT_LONG = "?latlng=";
    let PARAMETER_ADDRESS = "?address=";
    let PARAMETER_KEY = "&key=";
    let PARAMETER_SENSOR = "&sensor=true";
    
    // Error codes
    public static let GEO_AUTH_UNDETERMINED = 10
    public static let GEO_AUTH_DENIED = 20
    public static let GEO_GENERAL_FAILURE = 30
    
    let locationManager = CLLocationManager()
    
    weak var delegate:GeocodeDelegate?
    
    /**
     *  This attempts to retrieve the users current location. If a failure occurs, it is handled by the
     *  delegate function.
     */
    func getLocation()
    {
        // Request location access if the permission for Intencity was never set.
        if CLLocationManager.authorizationStatus() == .notDetermined
        {
            locationManager.requestWhenInUseAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .denied
        {
            delegate?.onLocationFailure(errorCode: GoogleGeocode.GEO_AUTH_DENIED)
        }
        else
        {
            let currentLoc = locationManager.location
            
            var lat: Double?
            var long: Double?
            
            if let x = currentLoc?.coordinate.latitude
            {
                lat = x
            }
            
            if let y = currentLoc?.coordinate.longitude
            {
                long = y
            }
            
            if lat == nil || long == nil
            {
                delegate?.onLocationFailure(errorCode: GoogleGeocode.GEO_GENERAL_FAILURE)
            }
            else
            {
                getAddress(lat: String(lat!), long: String(long!))
            }
        }
    }
    
    /**
     * We use the lattitude and longitude we retrieved to get the address at said location.
     */
    func getAddress(lat: String, long: String)
    {
        
        _ = ServiceTask(event: ServiceEvent.GET_ADDRESS,
                        delegate: self,
                        serviceURL: GOOGLE_GEOCODE_ENDPOINT + PARAMETER_LAT_LONG + lat + "," + long,
                        params: "")
    }
    
    /**
     *  Executes when retrieving a result from Google Geocode API fails.
     */
    func onRetrievalFailed(_ event: Int)
    {
        delegate?.onLocationFailure(errorCode: GoogleGeocode.GEO_GENERAL_FAILURE)
    }
    
    /**
     *  Executes when the result is returned from Google Geocode API successfully.
     */
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        // This gets saved as NSDictionary, so there is no order
        let json: Dictionary<String,AnyObject> = result.parseJSONString as! Dictionary<String,AnyObject>
        
        guard let results = json["results"] as? NSArray else
        {
            delegate?.onLocationFailure(errorCode: GoogleGeocode.GEO_GENERAL_FAILURE)
            return
        }
        
        guard let resultDict = results[0] as? Dictionary<String,AnyObject> else
        {
            delegate?.onLocationFailure(errorCode: GoogleGeocode.GEO_GENERAL_FAILURE)
            return
        }
        
        if let address = resultDict["formatted_address"] as? String {
            delegate?.onLocationSuccess(address: address)
        }
        else
        {
            delegate?.onLocationFailure(errorCode: GoogleGeocode.GEO_GENERAL_FAILURE)
        }
        
    }
    
}
