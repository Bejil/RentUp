//
//  RU_Classifieds_Comparator_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 12/03/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_Comparator_ViewController : RU_ViewController {
	
	public var classified: RU_Classified? {
		
		didSet {
			
			if isViewLoaded {
				
				updateContent()
			}
		}
	}
	private lazy var scrollView: UIScrollView = {
		
		$0.showsVerticalScrollIndicator = false
		return $0
		
	}(UIScrollView())
	private lazy var contentStackView: RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins
		return $0
		
	}(RU_StackView())
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		navigationItem.title = classified?.name ?? String(key: "classifieds.comparator.title")
		
		view.addSubview(scrollView)
		scrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		scrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.width.equalToSuperview().inset(UI.Margins)
		}
		
		updateContent()
	}
	
	private struct PlatformResult {
		let platform: RU_Platform
		let hostTotal1: Double
		let hostTotal7: Double?
		let hostTotal30: Double?
	}

	private func updateContent() {
		
		contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		
		guard let classified else { return }
		
		let platforms = RU_Platform.all ?? []
		var results: [PlatformResult] = []
		
		for type in classified.tarification.compactMap(\.platform?.type) {
			guard let platform = platforms.first(where: { $0.type == type }) else { continue }
			let booking1 = makeSimulationBooking(for: classified, nights: 1, platform: platform)
			guard let calc1 = platform.calculatePrice(for: booking1)?.hostTotal else { continue }
			let booking7 = makeSimulationBooking(for: classified, nights: 7, platform: platform)
			let calc7 = platform.calculatePrice(for: booking7)?.hostTotal
			let booking30 = makeSimulationBooking(for: classified, nights: 30, platform: platform)
			let calc30 = platform.calculatePrice(for: booking30)?.hostTotal
			results.append(PlatformResult(platform: platform, hostTotal1: calc1, hostTotal7: calc7, hostTotal30: calc30))
		}
		
		guard !results.isEmpty else { return }
		
		// Tip view avec conseils personnalisés
		let tipsView = makeTipsView(classified: classified, results: results)
		contentStackView.addArrangedSubview(tipsView)
		
		let nightTitle = String(key: "classifieds.comparator.result.metric.night")
		let weekTitle = String(key: "classifieds.comparator.result.metric.week")
		let monthTitle = String(key: "classifieds.comparator.result.metric.month")
		
		// Une carte par plateforme : titre plateforme + 3 lignes (1 nuit, 1 semaine, 1 mois)
		for r in results {
			let platformLabel = RU_Platform_Label()
			platformLabel.platform = r.platform
			let sectionStackView = RU_Section_StackView()
			sectionStackView.title = String(key: "classifieds.comparator.result.header")
			sectionStackView.accessoryView = platformLabel
			let cardStack = RU_StackView(arrangedSubviews: [sectionStackView])
			cardStack.axis = .vertical
			cardStack.spacing = UI.Margins / 2
			let rowData: [(String, String, Double?)] = [
				("1.calendar", nightTitle, r.hostTotal1),
				("7.calendar", weekTitle, r.hostTotal7),
				("30.calendar", monthTitle, r.hostTotal30)
			]
			for (iconName, title, value) in rowData {
				let row = RU_Section_TextFieldRow_StackView()
				row.image = UIImage(systemName: iconName)
				row.title = title
				row.textField.isEnabled = false
				row.textField.text = value.map { String(format: "%.2f", $0) } ?? "—"
                row.suffix = String(key: "settings.platform.value.amount")
				cardStack.addArrangedSubview(row)
			}
			contentStackView.addArrangedSubview(cardStack)
		}
	}
	
	private func makeTipsView(classified: RU_Classified, results: [PlatformResult]) -> RU_Tip_StackView {
		let tip = RU_Tip_StackView()
		tip.icon = UIImage(systemName: "lightbulb.fill")
		tip.title = String(key: "classifieds.comparator.tips.title")
		
		if results.count == 1 {
			tip.add(String(key: "classifieds.comparator.tips.single"))
		} else if let best = results.max(by: { $0.hostTotal1 < $1.hostTotal1 }) {
			let refName = best.platform.type?.name ?? ""
			var hasGap = false
			for r in results where r.platform.uuid != best.platform.uuid {
				let diff = best.hostTotal1 - r.hostTotal1
				if diff > 0.5 {
					hasGap = true
					let name = r.platform.type?.name ?? ""
					tip.add(String(format: String(key: "classifieds.comparator.tips.increase"), name, diff, refName))
					if let tarification = classified.tarification.first(where: { $0.platform?.type == r.platform.type }),
					   let cleaning = tarification.cleaning, cleaning > 0 {
						tip.add(String(format: String(key: "classifieds.comparator.tips.cleaning"), name, Double(cleaning)))
					}
				} else if diff < -0.5 {
					hasGap = true
					let name = r.platform.type?.name ?? ""
					tip.add(String(format: String(key: "classifieds.comparator.tips.decrease"), name, -diff, refName))
				}
			}
			if !hasGap {
				tip.add(String(key: "classifieds.comparator.tips.aligned"))
			}
		}
		tip.contentStackView.arrangedSubviews.forEach { ($0 as? RU_Label)?.numberOfLines = 0 }
		return tip
	}
	
	private func makeSimulationBooking(for classified: RU_Classified, nights: Int, platform: RU_Platform) -> RU_Booking {
		
		let booking = RU_Booking()
		booking.classified = classified
		booking.platform = platform
		booking.dates.start = Calendar.current.startOfDay(for: Date())
		booking.dates.end = Calendar.current.date(byAdding: .day, value: nights, to: booking.dates.start) ?? booking.dates.start
		booking.travelers.adults = 1
		booking.travelers.children = 0
		booking.travelers.babies = 0
		booking.costs.cleaning = 0
		booking.costs.compensation = 0
		return booking
	}
}
