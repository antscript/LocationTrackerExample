//
//  BackgroundTaskManager.swift
//  LocationTracker
//
//  Created by AntScript on 2018/10/22.
//  Copyright © 2018 AntScript. All rights reserved.
//

import Foundation
import UIKit

final class BackgroundTaskManager: NSObject {

	static let shared = BackgroundTaskManager()

	fileprivate var bgTaskList: [UIBackgroundTaskIdentifier]
	fileprivate var masterTask: UIBackgroundTaskIdentifier

	private override init() {
		bgTaskList = []
		masterTask = .invalid
		super.init()
	}

	func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier {
		var bgTask = UIBackgroundTaskIdentifier.invalid
		bgTask = UIApplication.shared.beginBackgroundTask {[weak self] in
			self?.bgTaskList.removeAll(where: { (task) -> Bool in
				return task == bgTask
			})
			UIApplication.shared.endBackgroundTask(bgTask)
			bgTask = .invalid
		}
		if masterTask == .invalid {
			masterTask = bgTask
		} else {
			bgTaskList.append(bgTask)
			endBackgroundTasks()
		}
		return bgTask
	}

	fileprivate func endBackgroundTasks() {
		drainBackgroundTasks(endAll: false)
	}

	fileprivate func endAllBackgroundTasks() {
		drainBackgroundTasks(endAll: true)
	}

	fileprivate func drainBackgroundTasks(endAll: Bool) {
		let count = bgTaskList.count
		for _ in (endAll ? 0 : 1)..<count {
			print("ending background task : \(bgTaskList[0].rawValue)")
			UIApplication.shared.endBackgroundTask(bgTaskList[0])
			bgTaskList.remove(at: 0)
		}
		if bgTaskList.count > 0 {
			print("kept background task : \(bgTaskList[0].rawValue)")
		}
		if endAll {
			print("no more background tasks running")
			UIApplication.shared.endBackgroundTask(masterTask)
			masterTask = .invalid
		} else {
			print("kept master background task id \(masterTask.rawValue)")
		}
	}
}
