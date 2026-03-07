//
//  RU_Classifieds_Detail_Platform_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 24/02/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_Detail_Platform_ViewController: RU_ViewController {

	public var classified: RU_Classified? {
		didSet { updateData() }
	}
	public var platform: RU_Platform? {
		didSet {
			title = platform?.type?.name
			updateData()
		}
	}

	private var tarification: RU_Classified.Tarification? {
		guard let platform else { return nil }
		return classified?.tarification.first { $0.platform == platform }
	}

	private lazy var priceValueLabel: RU_Label = .init()
	private lazy var cleaningValueLabel: RU_Label = .init()
	private lazy var travelersIncludedValueLabel: RU_Label = .init()
	private lazy var travelersExtraValueLabel: RU_Label = .init()
	private lazy var offerWeekValueLabel: RU_Label = .init()
	private lazy var offerMonthValueLabel: RU_Label = .init()
	private lazy var offerWeekSectionRowStackView: RU_Section_Row_StackView = createRow(icon: "calendar", title: String(key: "settings.classified.platform.tarification.offer.week"), view: offerWeekValueLabel)
	private lazy var offerMonthSectionRowStackView: RU_Section_Row_StackView = createRow(icon: "calendar", title: String(key: "settings.classified.platform.tarification.offer.month"), view: offerMonthValueLabel)

	private lazy var tipStackView: RU_Tip_StackView = {
		$0.title = String(key: "settings.platform.tip.title")
		return $0
	}(RU_Tip_StackView())

	private lazy var pricesSectionStackView: RU_Section_StackView = {
		$0.title = String(key: "settings.classified.platform.tarification.prices.section.title")
		$0.subtitle = String(key: "settings.classified.platform.tarification.prices.section.subtitle")
		$0.addArrangedSubview(createRow(icon: "eurosign", title: String(key: "settings.classified.platform.tarification.price"), view: priceValueLabel))
		$0.addArrangedSubview(createRow(icon: "sparkles", title: String(key: "settings.classified.platform.tarification.cleaning"), view: cleaningValueLabel))
		return $0
	}(RU_Section_StackView())

	private lazy var travelersSectionStackView: RU_Section_StackView = {
		$0.subtitle = String(key: "settings.classified.platform.tarification.travelers.section.subtitle")
		$0.addArrangedSubview(createRow(icon: "person.2.fill", title: String(key: "settings.classified.platform.tarification.travelers.included"), view: travelersIncludedValueLabel))
		$0.addArrangedSubview(createRow(icon: "person.badge.plus", title: String(key: "settings.classified.platform.tarification.travelers.extra"), view: travelersExtraValueLabel))
		return $0
	}(RU_Section_StackView())

	private lazy var offersSectionStackView: RU_Section_StackView = {
		$0.title = String(key: "settings.classified.platform.tarification.offers.section.title")
		$0.subtitle = String(key: "settings.classified.platform.tarification.offers.section.subtitle")
		$0.addArrangedSubview(offerWeekSectionRowStackView)
		$0.addArrangedSubview(offerMonthSectionRowStackView)
		return $0
	}(RU_Section_StackView())

	public override func loadView() {
        
		super.loadView()

		let contentScrollView = RU_ScrollView()
		let contentStackView = RU_StackView()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2 * UI.Margins
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = UIEdgeInsets(UI.Margins)
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.width.equalToSuperview()
		}

		view.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		if let type = platform?.type {
			let travelerTipLabel = RU_Label([String(key: "settings.platform.tip.content.traveler"), type.priceFormulaTraveler].joined(separator: " "))
			travelerTipLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "settings.platform.tip.content.traveler"))
			tipStackView.add(travelerTipLabel)
			let hostTipLabel = RU_Label([String(key: "settings.platform.tip.content.host"), type.priceFormulaHost].joined(separator: " "))
			hostTipLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "settings.platform.tip.content.host"))
			tipStackView.add(hostTipLabel)
		}
		contentStackView.addArrangedSubview(tipStackView)
		contentStackView.addArrangedSubview(pricesSectionStackView)
		contentStackView.addArrangedSubview(travelersSectionStackView)
		contentStackView.addArrangedSubview(offersSectionStackView)
	}

    private func createRow(icon: String, title: String, view: UIView, isHighlighted: Bool = false) -> RU_Section_Row_StackView {
        
        let stackView:RU_Section_Row_StackView = .init()
        stackView.image = UIImage(systemName: icon)
        stackView.title = title
        stackView.view = view
        stackView.isHighlighted = isHighlighted
        return stackView
    }

	private func updateData() {
		let t = tarification

		if let price = t?.price {
			priceValueLabel.text = String(format: "%i €", price)
			pricesSectionStackView.isHidden = false
		} else {
			priceValueLabel.text = "—"
		}

		if let cleaning = t?.cleaning {
			cleaningValueLabel.text = String(format: "%i €", cleaning)
		} else {
			cleaningValueLabel.text = "—"
		}

		if let included = t?.travelers.included, let extra = t?.travelers.extraPrice {
			travelersIncludedValueLabel.text = "\(included)"
			travelersExtraValueLabel.text = String(format: "%i €", extra)
			travelersSectionStackView.isHidden = false
		} else {
			travelersSectionStackView.isHidden = true
		}

		if let weekPercent = t?.offers.first(where: { $0.reductiontype == .week })?.percent {
			offerWeekValueLabel.text = String(format: "%i %%", weekPercent)
			offerWeekSectionRowStackView.isHidden = false
		} else {
			offerWeekValueLabel.text = "—"
			offerWeekSectionRowStackView.isHidden = false
		}

		if let monthPercent = t?.offers.first(where: { $0.reductiontype == .month })?.percent {
			offerMonthValueLabel.text = String(format: "%i %%", monthPercent)
			offerMonthSectionRowStackView.isHidden = false
		} else {
			offerMonthValueLabel.text = "—"
			offerMonthSectionRowStackView.isHidden = false
		}
	}
}
