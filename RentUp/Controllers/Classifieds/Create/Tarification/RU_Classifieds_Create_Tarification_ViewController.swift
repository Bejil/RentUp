//
//  RU_Classifieds_Create_Tarification_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit

public class RU_Classifieds_Create_Tarification_ViewController : RU_Classifieds_Create_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        navigationItem.title = String(key: "Étape 3/4")
        
        let placeholderView = view.showPlaceholder()
        placeholderView.title = String(key: "Plateformes")
        placeholderView.image = UIImage(named: "placeholder_classified_plateforms")
        
        let label:RU_Label = .init(String(key: "Définissez les plateformes où votre annonce est visible. Vous pourrez ensuite ajouter des réservations pour chacune d'entre elle en fonction de vos besoins"))
        label.textAlignment = .center
        placeholderView.contentStackView.addArrangedSubview(label)
        
        saveButton.action = { [weak self] _ in
            
            let viewController:RU_Classifieds_Create_Fees_ViewController = .init()
            viewController.classified = self?.classified
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        placeholderView.contentStackView.addArrangedSubview(saveButton)
    }
}
