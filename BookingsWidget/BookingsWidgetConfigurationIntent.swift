//
//  BookingsWidgetConfigurationIntent.swift
//  BookingsWidget
//

import AppIntents
import WidgetKit

struct WidgetClassifiedEntity: AppEntity, Identifiable, Hashable {
	
	var id: String
	var displayName: String
	
	static var typeDisplayRepresentation: TypeDisplayRepresentation {
		TypeDisplayRepresentation(name: "Bien")
	}
	
	var displayRepresentation: DisplayRepresentation {
		DisplayRepresentation(title: LocalizedStringResource(stringLiteral: displayName))
	}
	
	static var defaultQuery = WidgetClassifiedEntityQuery()
	
	init(id: String, displayName: String) {
		self.id = id
		self.displayName = displayName
	}
	
	init(item: WidgetClassifiedItem) {
		self.id = item.id
		self.displayName = item.name
	}
}

struct WidgetClassifiedEntityQuery: EntityQuery, EntityStringQuery {
	
	func entities(for identifiers: [WidgetClassifiedEntity.ID]) async throws -> [WidgetClassifiedEntity] {
		WidgetClassifiedCatalog.allItems()
			.filter { identifiers.contains($0.id) }
			.map(WidgetClassifiedEntity.init(item:))
	}
	
	func suggestedEntities() async throws -> [WidgetClassifiedEntity] {
		WidgetClassifiedCatalog.allItems().map(WidgetClassifiedEntity.init(item:))
	}
	
	func entities(matching string: String) async throws -> [WidgetClassifiedEntity] {
		let all = WidgetClassifiedCatalog.allItems().map(WidgetClassifiedEntity.init(item:))
		guard !string.isEmpty else { return all }
		return all.filter { $0.displayName.localizedCaseInsensitiveContains(string) }
	}
	
	func defaultResult() async -> WidgetClassifiedEntity? {
		WidgetClassifiedCatalog.allItems().first.map(WidgetClassifiedEntity.init(item:))
	}
}

struct WidgetClassifiedOptionsProvider: DynamicOptionsProvider {
	
	func results() async throws -> [WidgetClassifiedEntity] {
		WidgetClassifiedCatalog.allItems().map(WidgetClassifiedEntity.init(item:))
	}
	
	func defaultResult() async -> WidgetClassifiedEntity? {
		WidgetClassifiedCatalog.allItems().first.map(WidgetClassifiedEntity.init(item:))
	}
}

struct BookingsWidgetConfigurationIntent: WidgetConfigurationIntent {
	
	static var title: LocalizedStringResource = "BienGéré"
	static var description = IntentDescription("Choisissez le bien dont afficher les réservations.")
	
	@Parameter(
		title: "Bien",
		description: "Le bien affiché dans ce widget",
		optionsProvider: WidgetClassifiedOptionsProvider()
	)
	var classified: WidgetClassifiedEntity?
	
	static var parameterSummary: some ParameterSummary {
		Summary("Afficher \(\.$classified)")
	}
}
