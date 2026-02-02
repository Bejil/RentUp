//
//  NotificationCenter_Extension.swift
//  BarcodeBattler
//
//  Created by BLIN Michael on 08/06/2022.
//

import Foundation

extension NotificationCenter {
	
	public static func post(_ name:Notification.Name, _ object:Any? = nil) {
		
		NotificationCenter.default.post(name: name, object: object)
	}
	
	public static func add(_ name:Notification.Name, _ handler:@escaping ((Notification)->Void)) {
		
		NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: handler)
	}
	
	public static func remove(_ name:Notification.Name) {
		
		NotificationCenter.default.removeObserver(self, name: name, object: nil)
	}
}
