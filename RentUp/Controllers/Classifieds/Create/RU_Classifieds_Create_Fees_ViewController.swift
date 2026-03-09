//
//  RU_Classifieds_Create_Fees_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit

public class RU_Classifieds_Create_Fees_ViewController : RU_Classifieds_Create_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        navigationItem.title = String(key: "Étape 4/4")
        
        let placeholderView = view.showPlaceholder()
        placeholderView.title = String(key: "Rentabilité")
        placeholderView.image = UIImage(named: "placeholder_classified_fees")
        
        let label:RU_Label = .init(String(key: "settings.classified.fees.tip.content"))
        label.textAlignment = .center
        placeholderView.contentStackView.addArrangedSubview(label)
        
        let button:RU_Button = .init(String(key: "Créer")) { [weak self] _ in
            
            
        }
        button.image = UIImage(systemName: "square.and.arrow.down")
        placeholderView.contentStackView.addArrangedSubview(button)
    }
}
