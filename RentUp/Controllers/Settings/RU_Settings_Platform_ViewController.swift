//
//  RU_Bookings_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_Settings_Platform_ViewController: RU_ViewController {
	
	public var platform:RU_Platform? {
		
		didSet {
			
			title = platform?.type?.name
			
			if let type = platform?.type {
				
				let travelerTipLabel:RU_Label = .init([String(key: "settings.platform.tip.content.traveler"),type.priceFormulaTraveler].joined(separator: " "))
				travelerTipLabel.set(font: Fonts.Content.Text.Bold, string:String(key: "settings.platform.tip.content.traveler"))
				tipStackView.add(travelerTipLabel)
				
				let hostTipLabel:RU_Label = .init([String(key: "settings.platform.tip.content.host"),type.priceFormulaHost].joined(separator: " "))
				hostTipLabel.set(font: Fonts.Content.Text.Bold, string:String(key: "settings.platform.tip.content.host"))
				tipStackView.add(hostTipLabel)
			}
			
			commissionTouristTaxRow.isHidden = platform?.commission.touristTax == nil
			
			if let commissionTouristTax = platform?.commission.touristTax?.amount {
				
				commissionTouristTaxRow.suffix = String(key: platform?.commission.touristTax?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
				commissionTouristTaxRow.textField.text = "\(commissionTouristTax)"
			}
			
			commissionHostRow.isHidden = platform?.commission.host == nil
			
			if let commissionHost = platform?.commission.host?.amount {
				
				commissionHostRow.suffix = String(key: platform?.commission.host?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
				commissionHostRow.textField.text = "\(commissionHost)"
			}
			
			commissionTravelerRow.isHidden = platform?.commission.traveler == nil
			
			if let commissionTraveler = platform?.commission.traveler?.amount {
				
				commissionTravelerRow.suffix = String(key: platform?.commission.traveler?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
				commissionTravelerRow.textField.text = "\(commissionTraveler)"
			}
			
			commissionPlatformRow.isHidden = platform?.commission.platform == nil
			
			if let commissionPlatform = platform?.commission.platform?.amount {
				
				commissionPlatformRow.suffix = String(key: platform?.commission.platform?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
				commissionPlatformRow.textField.text = "\(commissionPlatform)"
			}
			
			commissionBankRow.isHidden = platform?.commission.bank == nil
			
			if let commissionBank = platform?.commission.bank?.amount {
				
				commissionBankRow.suffix = String(key: platform?.commission.bank?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
				commissionBankRow.textField.text = "\(commissionBank)"
			}
			
			commissionVatRow.isHidden = platform?.commission.vat == nil
			
			if let commissionVat = platform?.commission.vat?.amount {
				
				commissionVatRow.suffix = String(key: platform?.commission.vat?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
				commissionVatRow.textField.text = "\(commissionVat)"
			}
		}
	}
	private lazy var tipStackView:RU_Tip_StackView = {
		
		$0.title = String(key: "settings.platform.tip.title")
		return $0
		
	}(RU_Tip_StackView())
	private lazy var commissionTouristTaxRow:RU_Section_TextFieldRow_StackView = {
		
		$0.image = UIImage(systemName: "building.columns.fill")
		$0.title = String(key: "settings.platform.commission.touristTax")
		$0.textField.keyboardType = .decimalPad
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private lazy var commissionHostRow:RU_Section_TextFieldRow_StackView = {
		
		$0.image = UIImage(systemName: "house.fill")
		$0.title = String(key: "settings.platform.commission.host")
		$0.textField.keyboardType = .decimalPad
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private lazy var commissionTravelerRow:RU_Section_TextFieldRow_StackView = {
		
		$0.image = UIImage(systemName: "figure.walk")
		$0.title = String(key: "settings.platform.commission.traveler")
		$0.textField.keyboardType = .decimalPad
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private lazy var commissionPlatformRow:RU_Section_TextFieldRow_StackView = {
		
		$0.image = UIImage(systemName: "app.badge.fill")
		$0.title = String(key: "settings.platform.commission.platform")
		$0.textField.keyboardType = .decimalPad
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private lazy var commissionBankRow:RU_Section_TextFieldRow_StackView = {
		
		$0.image = UIImage(systemName: "creditcard.fill")
		$0.title = String(key: "settings.platform.commission.bank")
		$0.textField.keyboardType = .decimalPad
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	private lazy var commissionVatRow:RU_Section_TextFieldRow_StackView = {
		
		$0.image = UIImage(systemName: "percent")
		$0.title = String(key: "settings.platform.commission.vat")
		$0.textField.keyboardType = .decimalPad
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
	
	public override func loadView() {
		
		super.loadView()
		
		let contentScrollView:RU_ScrollView = .init()
        view.addSubview(contentScrollView)
		
		let contentStackView:RU_StackView = .init()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(UI.Margins)
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
		}
		
        let commissionFeesSectionTitleStackView:RU_Section_StackView = .init()
		commissionFeesSectionTitleStackView.title = String(key: "settings.platform.commissionFees.section.title")
		commissionFeesSectionTitleStackView.subtitle = String(key: "settings.platform.commissionFees.section.subtitle")
		commissionFeesSectionTitleStackView.addArrangedSubview(commissionTouristTaxRow)
		commissionFeesSectionTitleStackView.addArrangedSubview(commissionHostRow)
		commissionFeesSectionTitleStackView.addArrangedSubview(commissionTravelerRow)
		commissionFeesSectionTitleStackView.addArrangedSubview(commissionPlatformRow)
		commissionFeesSectionTitleStackView.addArrangedSubview(commissionBankRow)
		commissionFeesSectionTitleStackView.addArrangedSubview(commissionVatRow)
		contentStackView.addArrangedSubview(commissionFeesSectionTitleStackView)
		
		let addButton:RU_Button = .init(String(key: "settings.platform.save.button")) { [weak self] button in
			
			guard let self else { return }
			
			button?.isLoading = true
			
			if let amount = Double(commissionTouristTaxRow.textField.text ?? "") {
				platform?.commission.touristTax?.amount = amount
			}
			
			if let amount = Double(commissionHostRow.textField.text ?? "") {
				platform?.commission.host?.amount = amount
			}
			
			if let amount = Double(commissionTravelerRow.textField.text ?? "") {
				platform?.commission.traveler?.amount = amount
			}
			
			if let amount = Double(commissionPlatformRow.textField.text ?? "") {
				platform?.commission.platform?.amount = amount
			}
			
			if let amount = Double(commissionBankRow.textField.text ?? "") {
				platform?.commission.bank?.amount = amount
			}
			
			if let amount = Double(commissionVatRow.textField.text ?? "") {
				platform?.commission.vat?.amount = amount
			}
			
			platform?.save { error in
				
				button?.isLoading = false
				
				if let error {
					
					RU_Alert_ViewController.present(error)
				}
				else {
					
					NotificationCenter.post(.updatePlatforms)
					self.navigationController?.popViewController(animated: true)
				}
			}
		}
		addButton.image = UIImage(systemName: "square.and.arrow.down")
		
        let bottomButtonsVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .light))
        bottomButtonsVisualEffectView.contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.edges.equalTo(bottomButtonsVisualEffectView.safeAreaLayoutGuide).inset(UI.Margins)
        }
        bottomButtonsVisualEffectView.contentView.addLine(position: .top)
        view.addSubview(bottomButtonsVisualEffectView)
        
        contentScrollView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(bottomButtonsVisualEffectView.snp.top).offset(-UI.Margins)
        }
        
        bottomButtonsVisualEffectView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(UI.Margins)
            make.right.left.equalToSuperview()
            make.top.equalTo(contentScrollView.snp.bottom).inset(UI.Margins)
        }
	}
	
	private func createTextFieldRow(icon: String, title: String, textField:RU_Section_TextField, value: RU_Platform.Value?) -> RU_StackView {
		
		let suffixLabel:RU_Label = .init(String(key: value?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount"))
		suffixLabel.font = Fonts.Content.Text.Bold
		suffixLabel.setContentHuggingPriority(.required, for: .horizontal)
		suffixLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		
		let textFieldStackView:RU_StackView = .init(arrangedSubviews: [textField,suffixLabel])
		textFieldStackView.axis = .horizontal
		textFieldStackView.spacing = UI.Margins
		textFieldStackView.alignment = .center
		
		let stackView:RU_Section_Row_StackView = .init()
		stackView.image = UIImage(systemName: icon)
		stackView.title = title
		stackView.view = textFieldStackView
		return stackView
	}
}
