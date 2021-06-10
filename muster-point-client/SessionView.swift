// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Amplify
import MapKit
import SwiftUI

struct SessionView: View {
    @EnvironmentObject var auth: AuthService

    let locationManager = LocationManager()
    @ObservedObject var geofenceHandler = GeofenceHandler()

    @State private var centerCoordinate = CLLocationCoordinate2D()

    var body: some View {
        VStack {
            Spacer()
            // Creates map view and adds the geofences created on Amazon Location Service
            MapView(centerCoordinate: $centerCoordinate, overlays: geofenceHandler.overlays)
                .edgesIgnoringSafeArea(.all)
            Spacer()
            Button("Sign Out", action: auth.signOut)
        }
    }

    init() {
        geofenceHandler.listGeofences()
    }
}
