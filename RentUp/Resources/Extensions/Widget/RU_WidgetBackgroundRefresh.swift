//
//  RU_WidgetBackgroundRefresh.swift
//  RentUp
//

import BackgroundTasks
import Foundation

enum RU_WidgetBackgroundRefresh {
	
	static let taskIdentifier = "com.michaelblin.RentUp.widgetRefresh"
	
	static func register() {
		BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
			guard let refreshTask = task as? BGAppRefreshTask else {
				task.setTaskCompleted(success: false)
				return
			}
			handle(refreshTask)
		}
	}
	
	static func schedule() {
		let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
		request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
		do {
			try BGTaskScheduler.shared.submit(request)
		} catch {
			// Déjà planifiée ou quota système atteint.
		}
	}
	
	private static func handle(_ task: BGAppRefreshTask) {
		schedule()
		
		let group = DispatchGroup()
		var success = true
		
		task.expirationHandler = {
			success = false
		}
		
		group.enter()
		RU_Booking.getAll { error, _ in
			if error != nil {
				success = false
			}
			group.leave()
		}
		
		group.enter()
		RU_Classified.getAll { error, _ in
			if error != nil {
				success = false
			}
			group.leave()
		}
		
		group.notify(queue: .main) {
			task.setTaskCompleted(success: success)
		}
	}
}
