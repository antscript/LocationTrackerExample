//
//  LocationTracker.swift
//  LocationTracker
//
//  Created by AntScript on 2018/10/22.
//  Copyright © 2018 AntScript. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

final class LocationTracker: NSObject {

	static fileprivate let locationManager = CLLocationManager()

	var locations: [CLLocation]
	fileprivate var timer: Timer?
	fileprivate var delayTimer: Timer?
	fileprivate var timeInterval = 150.0
	fileprivate var delayTimeInterval = 5.0

	override init() {
		locations = []
		super.init()
		LocationTracker.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		LocationTracker.locationManager.allowsBackgroundLocationUpdates = true
		LocationTracker.locationManager.pausesLocationUpdatesAutomatically = false
		LocationTracker.locationManager.requestAlwaysAuthorization()
		NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
	}

	func startLocationTracking() {
		print("startLocationTracking")
		startUpdateLocation()
	}

}

//MARK: fileprivate function
extension LocationTracker {
	@objc fileprivate func applicationEnterBackground() {
		startUpdateLocation()
		_ = BackgroundTaskManager.shared.beginNewBackgroundTask()
	}

	@objc fileprivate func restartLocationUpdates() {
		print("restartLocationUpdates")
		if timer != nil {
			timer?.invalidate()
			timer = nil
		}
		startUpdateLocation()
	}

	fileprivate func stopLocationTracking() {
		print("stopLocationTracking")
		if timer != nil {
			timer?.invalidate()
			timer = nil
		}
		LocationTracker.locationManager.stopUpdatingLocation()
	}

	@objc fileprivate func delayStopLocation() {
		print("delayStopLocation")
		LocationTracker.locationManager.stopUpdatingLocation()
	}

	fileprivate func startUpdateLocation() {
		LocationTracker.locationManager.delegate = self
		LocationTracker.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
		LocationTracker.locationManager.distanceFilter = kCLDistanceFilterNone
		LocationTracker.locationManager.startUpdatingLocation()
	}
}

//MARK: CLLocationManagerDelegate
extension LocationTracker: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		print("locationManager didUpdateLocations")
		self.locations.append(contentsOf: locations)
		if timer != nil {
			return
		}
		_ = BackgroundTaskManager.shared.beginNewBackgroundTask()
		timer = Timer.scheduledTimer(
			timeInterval: timeInterval,
			target: self,
			selector: #selector(restartLocationUpdates),
			userInfo: nil,
			repeats: false
		)
		if delayTimer != nil {
			delayTimer?.invalidate()
			delayTimer = nil
		}
		delayTimer = Timer.scheduledTimer(
			timeInterval: delayTimeInterval,
			target: self,
			selector: #selector(delayStopLocation),
			userInfo: nil,
			repeats: false
		)
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		let alert = UIAlertController(
			title: "didFailWithError",
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		if let rootController = UIApplication.shared.keyWindow?.rootViewController {
			alert.show(rootController, sender: nil)
		}
	}
}
