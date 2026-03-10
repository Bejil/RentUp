//
//  RU_Classifieds_Create_Name_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit

public class RU_Classifieds_Create_Name_ViewController : RU_Classifieds_Create_ViewController {
    
    private lazy var textField:RU_TextField = {
        
        $0.font = Fonts.Content.Title.H2
        $0.textColor = Colors.Secondary
        $0.textAlignment = .center
        $0.placeholder = String(key: "settings.classified.name.placeholder")
        $0.keyboardType = .alphabet
        $0.autocapitalizationType = .words
        $0.addAction(.init(handler: { [weak self] _ in
            
            self?.classified?.name = self?.textField.text
            self?.updateSaveButton()
            
        }), for: .editingChanged)
        return $0
        
    }(RU_TextField())
    public override func loadView() {
        
        super.loadView()
        
        classified = .init()
        
        navigationItem.title = String(key: "Étape 1/4")
        
        let placeholderView = view.showPlaceholder()
        placeholderView.title = String(key: "Votre annonce")
        placeholderView.image = UIImage(named: "placeholder_classified_name")
        
        let label:RU_Label = .init(String(key: "Donnez un nom à votre annonce pour l'dentifier simplement et rapidement"))
        label.textAlignment = .center
        placeholderView.contentStackView.addArrangedSubview(label)
        
        placeholderView.contentStackView.addArrangedSubview(textField)
        placeholderView.contentStackView.setCustomSpacing(placeholderView.contentStackView.spacing * 2, after: textField)
        
        saveButton.action = { [weak self] _ in
            
            let viewController:RU_Classifieds_Create_Configuration_ViewController = .init()
            viewController.classified = self?.classified
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        placeholderView.contentStackView.addArrangedSubview(saveButton)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    private func updateSaveButton() {
        
        saveButton.isEnabled = !(classified?.name?.isEmpty ?? true)
    }
}
