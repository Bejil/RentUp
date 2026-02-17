//
//  RU_Classifieds_Edit_Platform_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 01/02/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_Edit_Platform_ViewController : RU_ViewController {
	
	public var completion:(()->Void)?
	public var classified:RU_Classified? {
		
		didSet {
			
			updateData()
		}
	}
	public var platform:RU_Platform? {
		
		didSet {
			
			title = platform?.type?.name
			
			updateData()
		}
	}
	private lazy var priceTextFieldRowStack:RU_Section_TextFieldRow_StackView = {
		
		$0.backgroundColor = Colors.Background.View
		$0.title = String(key: "settings.classified.platform.tarification.price")
		$0.image = UIImage(systemName: "eurosign")
		$0.suffix = String(key: "settings.platform.value.amount")
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins.bottom = UI.Margins/2
		$0.textField.addAction(.init(handler: { [weak self] _ in
			
			self?.updateSaveButton()
			
		}), for: .editingDidEnd)
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private lazy var cleaningTextFieldRowStack:RU_Section_TextFieldRow_StackView = {
		
		$0.backgroundColor = Colors.Background.View
		$0.title = String(key: "settings.classified.platform.tarification.cleaning")
		$0.image = UIImage(systemName: "sparkles")
		$0.suffix = String(key: "settings.platform.value.amount")
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins.bottom = UI.Margins/2
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private lazy var offerWeekTextFieldRowStack:RU_Section_TextFieldRow_StackView = {
		
		$0.backgroundColor = Colors.Background.View
		$0.title = String(key: "settings.classified.platform.tarification.offer.week")
		$0.image = UIImage(systemName: "calendar")
		$0.suffix = String(key: "settings.platform.value.percentage")
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins.bottom = UI.Margins/2
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private lazy var offerMonthTextFieldRowStack:RU_Section_TextFieldRow_StackView = {
		
		$0.backgroundColor = Colors.Background.View
		$0.title = String(key: "settings.classified.platform.tarification.offer.month")
		$0.image = UIImage(systemName: "calendar")
		$0.suffix = String(key: "settings.platform.value.percentage")
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins.bottom = UI.Margins/2
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private lazy var saveButton:RU_Button = {
		
		$0.isEnabled = true
		$0.image = UIImage(systemName: "square.and.arrow.down")
		return $0
		
	}(RU_Button(String(key: "settings.classified.platform.tarification.save.button")) { [weak self] button in
		
		if let platform = self?.platform {
			
			if self?.classified?.tarification.first(where: { $0.platform == platform }) == nil {
				
				let tarification:RU_Classified.Tarification = .init()
				tarification.platform = platform
				self?.classified?.tarification.append(tarification)
			}
			
			if let value = self?.priceTextFieldRowStack.textField.text, let intValue = Int(value) {
				
				self?.classified?.tarification.first(where: { $0.platform == platform })?.price = intValue
			}
			
			if let value = self?.cleaningTextFieldRowStack.textField.text, let intValue = Int(value) {
				
				self?.classified?.tarification.first(where: { $0.platform == platform })?.cleaning = intValue
			}
			
			if let value = self?.offerWeekTextFieldRowStack.textField.text, let intValue = Int(value) {
				
				if let offer = self?.classified?.tarification.first(where: { $0.platform == platform })?.offers.first(where: { $0.reductiontype == .week }) {
					
					offer.percent = intValue
				}
				else {
					
					let offer:RU_Classified.Tarification.Offer = .init()
					offer.reductiontype = .week
					offer.percent = intValue
					self?.classified?.tarification.first(where: { $0.platform == platform })?.offers.append(offer)
				}
			}
			
			if let value = self?.offerMonthTextFieldRowStack.textField.text, let intValue = Int(value) {
				
				if let offer = self?.classified?.tarification.first(where: { $0.platform == platform })?.offers.first(where: { $0.reductiontype == .month }) {
					
					offer.percent = intValue
				}
				else {
					
					let offer:RU_Classified.Tarification.Offer = .init()
					offer.reductiontype = .month
					offer.percent = intValue
					self?.classified?.tarification.first(where: { $0.platform == platform })?.offers.append(offer)
				}
			}
		}
		
		self?.dismiss(self?.completion)
	})
    private lazy var contentScrollView:RU_ScrollView = .init()
	
	public override func loadView() {
		
		super.loadView()
		
		let contentStackView:RU_StackView = .init()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(UI.Margins)
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
		}
		
		let tipStackView:RU_Tip_StackView = .init()
		tipStackView.title = String(key: "settings.platform.tip.title")
		if let type = platform?.type {
			
			let travelerTipLabel:RU_Label = .init([String(key: "settings.platform.tip.content.traveler"),type.priceFormulaTraveler].joined(separator: " "))
			travelerTipLabel.set(font: Fonts.Content.Text.Bold, string:String(key: "settings.platform.tip.content.traveler"))
			tipStackView.add(travelerTipLabel)
			
			let hostTipLabel:RU_Label = .init([String(key: "settings.platform.tip.content.host"),type.priceFormulaHost].joined(separator: " "))
			hostTipLabel.set(font: Fonts.Content.Text.Bold, string:String(key: "settings.platform.tip.content.host"))
			tipStackView.add(hostTipLabel)
		}
		contentStackView.addArrangedSubview(tipStackView)
		
		let pricesSectionStackView:RU_Section_StackView = .init()
		pricesSectionStackView.title = String(key: "settings.classified.platform.tarification.prices.section.title")
		pricesSectionStackView.subtitle = String(key: "settings.classified.platform.tarification.prices.section.subtitle")
		pricesSectionStackView.addArrangedSubview(priceTextFieldRowStack)
		pricesSectionStackView.addArrangedSubview(cleaningTextFieldRowStack)
		contentStackView.addArrangedSubview(pricesSectionStackView)
		
		let offersSectionStackView:RU_Section_StackView = .init()
		offersSectionStackView.title = String(key: "settings.classified.platform.tarification.offers.section.title")
		offersSectionStackView.subtitle = String(key: "settings.classified.platform.tarification.offers.section.subtitle")
		offersSectionStackView.addArrangedSubview(offerWeekTextFieldRowStack)
		offersSectionStackView.addArrangedSubview(offerMonthTextFieldRowStack)
		contentStackView.addArrangedSubview(offersSectionStackView)
		
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(1.5 * UI.Margins)
        }
	}
    
    public override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        
        view.layoutIfNeeded()
        
        let bottomInset = saveButton.bounds.height + 2 * UI.Margins
        contentScrollView.contentInset.bottom = bottomInset
        contentScrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
	
	private func updateSaveButton() {
		
		saveButton.isEnabled = !priceTextFieldRowStack.textField.text!.isEmpty
	}
	
	private func updateData() {
		
		let tarification = classified?.tarification.first(where: { $0.platform == platform })
		
		if let price = tarification?.price {
			priceTextFieldRowStack.textField.text = "\(price)"
			updateSaveButton()
		}
		
		if let cleaning = tarification?.cleaning {
			cleaningTextFieldRowStack.textField.text = "\(cleaning)"
		}
		
		if let weekPercent = tarification?.offers.first(where: { $0.reductiontype == .week })?.percent {
			offerWeekTextFieldRowStack.textField.text = "\(weekPercent)"
		}
		
		if let monthPercent = tarification?.offers.first(where: { $0.reductiontype == .month })?.percent {
			offerMonthTextFieldRowStack.textField.text = "\(monthPercent)"
		}
	}
}
