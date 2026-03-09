//
//  RU_Classifieds_Create_Configuration_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit

public class RU_Classifieds_Create_Configuration_ViewController : RU_Classifieds_Create_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        navigationItem.title = String(key: "Étape 2/4")
        
        let placeholderView = view.showPlaceholder()
        placeholderView.title = String(key: "Configuration")
        placeholderView.image = UIImage(named: "placeholder_classified_configuration")
        
        let label:RU_Label = .init(String(key: "Décrivez la configuration de votre logement. Combien de personnes maximum peuvent y séjourner et combien de lits ?"))
        label.textAlignment = .center
        placeholderView.contentStackView.addArrangedSubview(label)
        
        let capacityRow:RU_Section_StepperRow_StackView = .init()
        capacityRow.image = UIImage(systemName: "person.2.fill")
        capacityRow.title = String(key: "settings.classified.capacity")
        capacityRow.stepper.minimumValue = 0
        capacityRow.stepper.addAction(.init(handler: { [weak self] _ in
            
            if let value = capacityRow.value, let intValue = Int(value) {
                
                self?.classified?.configuration.capacity = intValue
                self?.updateSaveButton()
            }
            
        }), for: .valueChanged)
        
        let doubleBedsRow:RU_Section_StepperRow_StackView = .init()
        doubleBedsRow.image = UIImage(systemName: "bed.double.fill")
        doubleBedsRow.title = String(key: "settings.classified.beds.double")
        doubleBedsRow.stepper.minimumValue = 0
        doubleBedsRow.stepper.addAction(.init(handler: { [weak self] _ in
            
            if let value = doubleBedsRow.value, let intValue = Int(value) {
                
                self?.classified?.configuration.beds.doubles = intValue
                self?.updateSaveButton()
            }
            
        }), for: .valueChanged)
        
        let singleBedsRow:RU_Section_StepperRow_StackView = .init()
        singleBedsRow.image = UIImage(systemName: "bed.double")
        singleBedsRow.title = String(key: "settings.classified.beds.single")
        singleBedsRow.stepper.minimumValue = 0
        singleBedsRow.stepper.addAction(.init(handler: { [weak self] _ in
            
            if let value = singleBedsRow.value, let intValue = Int(value) {
                
                self?.classified?.configuration.beds.singles = intValue
                self?.updateSaveButton()
            }
            
        }), for: .valueChanged)
        
        let babiesBedsRow:RU_Section_StepperRow_StackView = .init()
        babiesBedsRow.image = UIImage(systemName: "stroller")
        babiesBedsRow.title = String(key: "settings.classified.beds.baby")
        babiesBedsRow.stepper.minimumValue = 0
        babiesBedsRow.stepper.addAction(.init(handler: { [weak self] _ in
            
            if let value = babiesBedsRow.value, let intValue = Int(value) {
                
                self?.classified?.configuration.beds.babies = intValue
            }
            
        }), for: .valueChanged)
        
        let rowsStackView:RU_StackView = .init(arrangedSubviews: [capacityRow,doubleBedsRow,singleBedsRow,babiesBedsRow])
        rowsStackView.axis = .vertical
        rowsStackView.spacing = UI.Margins/2
        placeholderView.contentStackView.addArrangedSubview(rowsStackView)
        placeholderView.contentStackView.setCustomSpacing(placeholderView.contentStackView.spacing * 2, after: rowsStackView)
        
        saveButton.action = { [weak self] _ in
            
            let viewController:RU_Classifieds_Create_Tarification_ViewController = .init()
            viewController.classified = self?.classified
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
        placeholderView.contentStackView.addArrangedSubview(saveButton)
    }
    
    private func updateSaveButton() {
        
        saveButton.isEnabled = classified?.configuration.capacity ?? 0 >= 1 && (classified?.configuration.beds.doubles ?? 0 >= 1 || classified?.configuration.beds.singles ?? 0 >= 1)
    }
}
