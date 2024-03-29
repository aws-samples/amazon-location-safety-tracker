// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import AWSCore
// import Mapbox
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    var overlays: [MKPolygon]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true

        mapView.delegate = context.coordinator

        return mapView
    }

    func updateUIView(_ view: MKMapView, context _: Context) {
        print("updating")

        if overlays.count > 0 {
            view.addOverlays(overlays, level: .aboveLabels)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
        }

        func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = .red
            return polygonView
        }

        func mapView(_ mapView: MKMapView, didUpdate _: MKUserLocation) {
            mapView.userTrackingMode = .follow
        }
    }
}
