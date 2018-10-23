//
//  AppDelegate.swift
//  LocationTracker
//
//  Created by AntScript on 2018/10/22.
//  Copyright © 2018 AntScript. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	fileprivate let locationTracker = LocationTracker()
	fileprivate let launchDate = Date()

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		locationTracker.startLocationTracking()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

		var dates: [Date] = []
		for i in 0..<locationTracker.locations.count {
			guard (locationTracker.locations.count - i - 1) % 20 == 0 else {
				continue
			}
			guard dates.count < 10 && dates.count < locationTracker.locations.count else {
				break
			}
			dates.insert(locationTracker.locations[locationTracker.locations.count - i - 1].timestamp, at: 0)
		}
		if let lastLocation = locationTracker.locations.last {
			dates.append(lastLocation.timestamp)
		}
		let message = dates.reduce("") { (result, date) -> String in
			return result + "\(date.dateString())\n"
		}
		let alert = UIAlertController(
			title: "\(launchDate.dateString()) \(locationTracker.locations.count)",
			message: message,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction.init(title: "Close", style: .cancel, handler: nil))

		if let rootController = window?.rootViewController {
			rootController.present(alert, animated: true, completion: nil)
		}
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

extension Date {
	public func dateString() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .short
		dateFormatter.dateStyle = .short
		return dateFormatter.string(from: self)
	}
}

