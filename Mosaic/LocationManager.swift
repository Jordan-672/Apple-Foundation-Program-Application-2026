//
//  LocationManager.swift
//  Mosaic
//
//  Created by Gahyeon Kim on 20/7/2026.
//

import Combine
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<String, Error>?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestCurrentLocation() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                continuation.resume(throwing: NSError(
                    domain: "LocationManager",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Location access denied. Enable it in Settings to use this."]
                ))
                self.continuation = nil
            default:
                manager.requestLocation()
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            continuation?.resume(throwing: NSError(
                domain: "LocationManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Location access denied. Enable it in Settings to use this."]
            ))
            continuation = nil
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first, let continuation else { return }
        self.continuation = nil
        Task {
            do {
                let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
                let placemark = placemarks.first
                let result = [placemark?.locality, placemark?.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
                continuation.resume(returning: result.isEmpty ? "Unknown location" : result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
