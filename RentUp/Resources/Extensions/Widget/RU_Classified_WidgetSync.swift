//
//  RU_Classified_WidgetSync.swift
//  RentUp
//

import Foundation
import WidgetKit

enum RU_Classified_WidgetSync {
	
	static func updateSnapshot(with classifieds: [RU_Classified]?) {
		let items = (classifieds ?? []).compactMap { classified -> WidgetClassifiedItem? in
			guard !classified.uuid.isEmpty else { return nil }
			let name = classified.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
			guard !name.isEmpty else { return nil }
			return WidgetClassifiedItem(id: classified.uuid, name: name)
		}
		WidgetClassifiedsStore.save(WidgetClassifiedsSnapshot(updatedAt: Date(), classifieds: items))
		WidgetCenter.shared.reloadAllTimelines()
	}
	
	static func upsert(_ classified: RU_Classified) {
		guard !classified.uuid.isEmpty else { return }
		let name = classified.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		guard !name.isEmpty else { return }
		
		var items = WidgetClassifiedsStore.load()?.classifieds ?? []
		let item = WidgetClassifiedItem(id: classified.uuid, name: name)
		if let index = items.firstIndex(where: { $0.id == item.id }) {
			items[index] = item
		} else {
			items.append(item)
		}
		items.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
		WidgetClassifiedsStore.save(WidgetClassifiedsSnapshot(updatedAt: Date(), classifieds: items))
		WidgetCenter.shared.reloadAllTimelines()
	}
}
