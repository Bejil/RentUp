//
//  RU_Classified_Platform_Alert_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit
import SnapKit

public class RU_Classified_Platform_Alert_ViewController : RU_Alert_ViewController {
    
    public var completion:(()->Void)?
    public override var isEditing: Bool {
        
        didSet {
            
            priceTextFieldRowStack.textField.isEnabled = isEditing
            cleaningTextFieldRowStack.textField.isEnabled = isEditing
            travelersIncludedTextFieldRowStack.stepper.isEnabled = isEditing
            travelersExtraTextFieldRowStack.textField.isEnabled = isEditing
            offerWeekTextFieldRowStack.textField.isEnabled = isEditing
            offerMonthTextFieldRowStack.textField.isEnabled = isEditing
        }
    }
    public var classified:RU_Classified?
    public var platform:RU_Platform? {
        
        didSet {
            
            titleLabel.textColor = platform?.type?.backgroundColor
            title = platform?.type?.name
            
            imageView.image = platform?.type?.icon
            imageView.tintColor = platform?.type?.backgroundColor
            
            if let type = platform?.type {
                
                let travelerTipLabel:RU_Label = .init([String(key: "settings.platform.tip.content.traveler"),type.priceFormulaTraveler].joined(separator: " "))
                travelerTipLabel.set(font: Fonts.Content.Text.Bold, string:String(key: "settings.platform.tip.content.traveler"))
                tipStackView.add(travelerTipLabel)
                
                let hostTipLabel:RU_Label = .init([String(key: "settings.platform.tip.content.host"),type.priceFormulaHost].joined(separator: " "))
                hostTipLabel.set(font: Fonts.Content.Text.Bold, string:String(key: "settings.platform.tip.content.host"))
                tipStackView.add(hostTipLabel)
            }
            
            let tarification = classified?.tarification.first(where: { $0.platform == platform })
            
            if let price = tarification?.price {
                priceTextFieldRowStack.textField.text = "\(price)"
            }
            
            if let cleaning = tarification?.cleaning {
                cleaningTextFieldRowStack.textField.text = "\(cleaning)"
            }
            
            if let travelersIncluded = tarification?.travelers.included, let travelersExtra = tarification?.travelers.extraPrice {
                
                travelersIncludedTextFieldRowStack.stepper.value = Double(travelersIncluded)
                travelersIncludedTextFieldRowStack.value = "\(travelersIncluded)"
                
                travelersExtraTextFieldRowStack.textField.text = "\(travelersExtra)"
            }
            
            if let weekPercent = tarification?.offers.first(where: { $0.reductiontype == .week })?.percent {
                offerWeekTextFieldRowStack.textField.text = "\(weekPercent)"
            }
            
            if let monthPercent = tarification?.offers.first(where: { $0.reductiontype == .month })?.percent {
                offerMonthTextFieldRowStack.textField.text = "\(monthPercent)"
            }
            
            updateSaveButton()
        }
    }
    private lazy var imageView:UIImageView = {
        
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints { make in
            make.size.equalTo(3*UI.Margins)
        }
        return $0
        
    }(UIImageView())
    private lazy var tipStackView:RU_Tip_StackView = {
        
        $0.title = String(key: "settings.platform.tip.title")
        return $0
        
    }(RU_Tip_StackView())
    private lazy var priceTextFieldRowStack:RU_Section_TextFieldRow_StackView = {
        
        $0.backgroundColor = Colors.Background.View
        $0.title = String(key: "settings.classified.platform.tarification.price")
        $0.image = UIImage(systemName: "eurosign")
        $0.suffix = String(key: "settings.platform.value.amount")
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins.bottom = UI.Margins/2
        $0.textField.addAction(.init(handler: { [weak self] _ in
            
            self?.updateSaveButton()
            
        }), for: .editingChanged)
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
    private lazy var travelersIncludedTextFieldRowStack:RU_Section_StepperRow_StackView = {
        
        $0.image = UIImage(systemName: "person.2.fill")
        $0.title = String(key: "settings.classified.platform.tarification.travelers.included")
        $0.stepper.minimumValue = 0
        $0.stepper.addAction(.init(handler: { [weak self] _ in
            
            self?.updateSaveButton()
            
        }), for: .valueChanged)
        return $0
        
    }(RU_Section_StepperRow_StackView())
    private lazy var travelersExtraTextFieldRowStack:RU_Section_TextFieldRow_StackView = {
        
        $0.backgroundColor = Colors.Background.View
        $0.title = String(key: "settings.classified.platform.tarification.travelers.extra")
        $0.image = UIImage(systemName: "person.badge.plus")
        $0.suffix = String(key: "settings.platform.value.amount")
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins.bottom = UI.Margins/2
        $0.textField.addAction(.init(handler: { [weak self] _ in
            
            self?.updateSaveButton()
            
        }), for: .editingChanged)
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
    private var saveButton:RU_Button?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let titleStackView:RU_StackView = .init(arrangedSubviews: [imageView,titleLabel])
        titleStackView.axis = .horizontal
        titleStackView.spacing = UI.Margins
        titleStackView.alignment = .center
        
        let titleContainerStackView:RU_StackView = .init(arrangedSubviews: [titleStackView])
        titleContainerStackView.axis = .vertical
        titleContainerStackView.alignment = .center
        contentStackView.insertArrangedSubview(titleContainerStackView, at: 0)
    }
    
    @MainActor required public init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        
        super.loadView()
        
        add(tipStackView)
        
        let pricesSectionStackView:RU_Section_StackView = .init()
        pricesSectionStackView.title = String(key: "settings.classified.platform.tarification.prices.section.title")
        pricesSectionStackView.subtitle = String(key: "settings.classified.platform.tarification.prices.section.subtitle")
        pricesSectionStackView.addArrangedSubview(priceTextFieldRowStack)
        pricesSectionStackView.addArrangedSubview(cleaningTextFieldRowStack)
        add(pricesSectionStackView)
        
        let travelersSectionStackView:RU_Section_StackView = .init()
        travelersSectionStackView.subtitle = String(key: "settings.classified.platform.tarification.travelers.section.subtitle")
        travelersSectionStackView.addArrangedSubview(travelersIncludedTextFieldRowStack)
        travelersSectionStackView.addArrangedSubview(travelersExtraTextFieldRowStack)
        add(travelersSectionStackView)
        
        let offersSectionStackView:RU_Section_StackView = .init()
        offersSectionStackView.title = String(key: "settings.classified.platform.tarification.offers.section.title")
        offersSectionStackView.subtitle = String(key: "settings.classified.platform.tarification.offers.section.subtitle")
        offersSectionStackView.addArrangedSubview(offerWeekTextFieldRowStack)
        offersSectionStackView.addArrangedSubview(offerMonthTextFieldRowStack)
        add(offersSectionStackView)
        
        saveButton = addButton(title: String(key: "Valider")) { [weak self] _ in
            
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
                
                if let value = self?.travelersIncludedTextFieldRowStack.value, let intValue = Int(value) {
                    
                    self?.classified?.tarification.first(where: { $0.platform == platform })?.travelers.included = intValue
                    
                    if let value = self?.travelersExtraTextFieldRowStack.textField.text, let intValue = Int(value) {
                        
                        self?.classified?.tarification.first(where: { $0.platform == platform })?.travelers.extraPrice = intValue
                    }
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
            
            self?.close()
            self?.completion?()
        }
        
        addCancelButton()
    }
    
    private func updateSaveButton() {
        
        let travelersIncluded = Int(travelersIncludedTextFieldRowStack.value ?? "0") ?? 0
        let travelersExtra = Int(travelersExtraTextFieldRowStack.textField.text ?? "0") ?? 0
        
        saveButton?.isEnabled = !(priceTextFieldRowStack.textField.text?.isEmpty ?? true) && (travelersIncluded == 0 || (travelersIncluded > 0 && travelersExtra > 0))
    }
}
