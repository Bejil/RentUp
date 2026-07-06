//
//  RU_Platform_Alert_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit
import SnapKit

public class RU_Platform_Alert_ViewController : RU_Alert_ViewController {
    
    public var completion:(()->Void)?
    public var platform:RU_Platform? {
        
        didSet {
            
            titleLabel.textColor = platform?.type?.backgroundColor
            title = platform?.type?.name
            
            imageView.image = platform?.type?.icon
            imageView.tintColor = platform?.type?.backgroundColor
            
            if let type = platform?.type {
                
                let travelerTipLabel = tipStackView.addLabel([String(key: "settings.platform.tip.content.traveler"),type.priceFormulaTraveler].joined(separator: " "))
                travelerTipLabel.set(font: Fonts.Content.Text.Bold, string:String(key: "settings.platform.tip.content.traveler"))
                
                let hostTipLabel = tipStackView.addLabel([String(key: "settings.platform.tip.content.host"),type.priceFormulaHost].joined(separator: " "))
                hostTipLabel.set(font: Fonts.Content.Text.Bold, string:String(key: "settings.platform.tip.content.host"))
            }
            
            commissionTouristTaxRow.isHidden = platform?.commission?.touristTax == nil
            
            if let commissionTouristTax = platform?.commission?.touristTax?.amount {
                
                commissionTouristTaxRow.suffix = String(key: platform?.commission?.touristTax?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
                commissionTouristTaxRow.textField.text = "\(commissionTouristTax)"
            }
            
            commissionHostRow.isHidden = platform?.commission?.host == nil
            
            if let commissionHost = platform?.commission?.host?.amount {
                
                commissionHostRow.suffix = String(key: platform?.commission?.host?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
                commissionHostRow.textField.text = "\(commissionHost)"
            }
            
            commissionTravelerRow.isHidden = platform?.commission?.traveler == nil
            
            if let commissionTraveler = platform?.commission?.traveler?.amount {
                
                commissionTravelerRow.suffix = String(key: platform?.commission?.traveler?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
                commissionTravelerRow.textField.text = "\(commissionTraveler)"
            }
            
            commissionPlatformRow.isHidden = platform?.commission?.platform == nil
            
            if let commissionPlatform = platform?.commission?.platform?.amount {
                
                commissionPlatformRow.suffix = String(key: platform?.commission?.platform?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
                commissionPlatformRow.textField.text = "\(commissionPlatform)"
            }
            
            commissionBankRow.isHidden = platform?.commission?.bank == nil
            
            if let commissionBank = platform?.commission?.bank?.amount {
                
                commissionBankRow.suffix = String(key: platform?.commission?.bank?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
                commissionBankRow.textField.text = "\(commissionBank)"
            }
            
            commissionVatRow.isHidden = platform?.commission?.vat == nil
            
            if let commissionVat = platform?.commission?.vat?.amount {
                
                commissionVatRow.suffix = String(key: platform?.commission?.vat?.type == .percentage ? "settings.platform.value.percentage" : "settings.platform.value.amount")
                commissionVatRow.textField.text = "\(commissionVat)"
            }
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
    private lazy var commissionTouristTaxRow:RU_Section_TextFieldRow_StackView = {
        
        $0.image = UIImage(systemName: "building.columns.fill")
        $0.title = String(key: "settings.platform.commission.touristTax")
        $0.textField.keyboardType = .decimalPad
        $0.textField.isEnabled = false
        return $0
        
    }(RU_Section_TextFieldRow_StackView())
    private lazy var commissionHostRow:RU_Section_TextFieldRow_StackView = {
        
        $0.image = UIImage(systemName: "house.fill")
        $0.title = String(key: "settings.platform.commission.host")
        $0.textField.keyboardType = .decimalPad
        $0.textField.isEnabled = false
        return $0
        
    }(RU_Section_TextFieldRow_StackView())
    private lazy var commissionTravelerRow:RU_Section_TextFieldRow_StackView = {
        
        $0.image = UIImage(systemName: "figure.walk")
        $0.title = String(key: "settings.platform.commission.traveler")
        $0.textField.keyboardType = .decimalPad
        $0.textField.isEnabled = false
        return $0
        
    }(RU_Section_TextFieldRow_StackView())
    private lazy var commissionPlatformRow:RU_Section_TextFieldRow_StackView = {
        
        $0.image = UIImage(systemName: "app.badge.fill")
        $0.title = String(key: "settings.platform.commission.platform")
        $0.textField.keyboardType = .decimalPad
        $0.textField.isEnabled = false
        return $0
        
    }(RU_Section_TextFieldRow_StackView())
    private lazy var commissionBankRow:RU_Section_TextFieldRow_StackView = {
        
        $0.image = UIImage(systemName: "creditcard.fill")
        $0.title = String(key: "settings.platform.commission.bank")
        $0.textField.keyboardType = .decimalPad
        $0.textField.isEnabled = false
        return $0
        
    }(RU_Section_TextFieldRow_StackView())
    private lazy var commissionVatRow:RU_Section_TextFieldRow_StackView = {
        
        $0.image = UIImage(systemName: "percent")
        $0.title = String(key: "settings.platform.commission.vat")
        $0.textField.keyboardType = .decimalPad
        $0.textField.isEnabled = false
        return $0
        
    }(RU_Section_TextFieldRow_StackView())
    
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
        
        let stackView:RU_StackView = .init(arrangedSubviews: [
            commissionTouristTaxRow,
            commissionHostRow,
            commissionTravelerRow,
            commissionPlatformRow,
            commissionBankRow,
            commissionVatRow
        ])
        stackView.axis = .vertical
        stackView.spacing = UI.Margins/2
        add(stackView)
        
        addDismissButton()
    }
}
