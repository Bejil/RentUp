//
//  RU_Classifieds_Create_Fees_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit

public class RU_Classifieds_Create_Fees_ViewController : RU_Classifieds_Create_ViewController {
    
    public override var classified: RU_Classified? {
        
        didSet {
            
            if let value = classified?.fees {
                
                feesRow.textField.text = "\(value)"
            }
        }
    }
    private lazy var feesRow:RU_Section_TextFieldRow_StackView = {
        
        $0.image = UIImage(systemName: "eurosign")
        $0.title = String(key: "settings.classified.fees")
        $0.textField.placeholder = String(key: "section.textField.placeholder")
        $0.suffix = String(key: "settings.platform.value.amount")
        $0.textField.addAction(.init(handler: { [weak self] _ in
            
            if let value = self?.feesRow.textField.text {
                
                self?.classified?.fees = Int(value)
            }
            
        }), for: .editingChanged)
        return $0
        
    }(RU_Section_TextFieldRow_StackView())
    public override func loadView() {
        
        super.loadView()
        
navigationItem.title = String(key: "classified.create.step.4")

        let placeholderView = view.showPlaceholder()
        placeholderView.title = String(key: "classified.create.placeholder.profitability")
        placeholderView.image = UIImage(named: "placeholder_classified_fees")
        
        let label:RU_Label = .init(String(key: "settings.classified.fees.tip.content"))
        label.textAlignment = .center
        placeholderView.contentStackView.addArrangedSubview(label)
        
        placeholderView.contentStackView.addArrangedSubview(feesRow)
        placeholderView.contentStackView.setCustomSpacing(placeholderView.contentStackView.spacing * 2, after: feesRow)
        
        let button:RU_Button = .init(String(key: "classified.create.button.create")) { [weak self] button in
            
            button?.isLoading = true
            
            self?.classified?.save { error in
                
                button?.isLoading = false
                
                if let error {
                    
                    RU_Alert_ViewController.present(error)
                }
                else {
                    
                    self?.dismiss {
                        
                        NotificationCenter.post(.updateClassifieds)
                    }
                }
            }
        }
        button.image = UIImage(systemName: "square.and.arrow.down")
        placeholderView.contentStackView.addArrangedSubview(button)
    }
}
