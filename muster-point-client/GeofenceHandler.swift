// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0
import AWSLocation
import AWSMobileClient
import SwiftUI
import MapKit

class GeofenceHandler : ObservableObject {
    
    @Published var overlays = [MKPolygon]()
    
//    init() {
//        listGeofences()
//    }
    
    func listGeofences() {
        let request = AWSLocationListGeofencesRequest()!
        request.collectionName = Bundle.main.object(forInfoDictionaryKey: "GeofencesName") as? String

        let result = AWSLocation.default().listGeofences(request)
        result.continueWith { (task) -> Any? in
            if let error = task.error {
                print("error \(error)")
            } else if let taskResult = task.result {
                var overlays = [MKPolygon]()
                
                for entry in taskResult.entries! {
                    let polygonEntry = entry.geometry?.polygon![0]
                    
                    var polygons = [CLLocationCoordinate2D]()
                    for polygon in polygonEntry! {
                        let lon = polygon[0] as! Double
                        let lat = polygon[1] as! Double
                        polygons.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    }
                    
                    let polygon = MKPolygon(coordinates: polygons, count: polygons.count)
                    overlays.append(polygon)
                }
                DispatchQueue.main.async {
                    self.overlays = overlays
                }
            }
            return nil
        }
    }
}
