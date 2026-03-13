//
//  RU_Classifieds_Create_Configuration_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 09/03/2026.
//

import UIKit

public class RU_Classifieds_Create_Configuration_ViewController : RU_Classifieds_Create_ViewController {
    
    public override var classified: RU_Classified? {
        
        didSet {
            
            if let value = classified?.configuration.capacity {
                
                capacityRow.stepper.value = Double(value)
                capacityRow.value = "\(value)"
            }
            
            if let value = classified?.configuration.beds.doubles {
                
                doubleBedsRow.stepper.value = Double(value)
                doubleBedsRow.value = "\(value)"
            }
            
            if let value = classified?.configuration.beds.singles {
                
                singleBedsRow.stepper.value = Double(value)
                singleBedsRow.value = "\(value)"
            }
            
            if let value = classified?.configuration.beds.babies {
                
                babiesBedsRow.stepper.value = Double(value)
                babiesBedsRow.value = "\(value)"
            }
            
            updateSaveButton()
        }
    }
    private lazy var capacityRow:RU_Section_StepperRow_StackView = {
        
        $0.image = UIImage(systemName: "person.2.fill")
        $0.title = String(key: "settings.classified.capacity")
        $0.stepper.minimumValue = 0
        $0.stepper.addAction(.init(handler: { [weak self] _ in
            
            if let value = self?.capacityRow.value, let intValue = Int(value) {
                
                self?.classified?.configuration.capacity = intValue
                self?.updateSaveButton()
            }
            
        }), for: .valueChanged)
        return $0
        
    }(RU_Section_StepperRow_StackView())
    private lazy var doubleBedsRow:RU_Section_StepperRow_StackView = {
        
        $0.image = UIImage(systemName: "bed.double.fill")
        $0.title = String(key: "settings.classified.beds.double")
        $0.stepper.minimumValue = 0
        $0.stepper.addAction(.init(handler: { [weak self] _ in
            
            if let value = self?.doubleBedsRow.value, let intValue = Int(value) {
                
                self?.classified?.configuration.beds.doubles = intValue
                self?.updateSaveButton()
            }
            
        }), for: .valueChanged)
        return $0
        
    }(RU_Section_StepperRow_StackView())
    private lazy var singleBedsRow:RU_Section_StepperRow_StackView = {
        
        $0.image = UIImage(systemName: "bed.double")
        $0.title = String(key: "settings.classified.beds.single")
        $0.stepper.minimumValue = 0
        $0.stepper.addAction(.init(handler: { [weak self] _ in
            
            if let value = self?.singleBedsRow.value, let intValue = Int(value) {
                
                self?.classified?.configuration.beds.singles = intValue
                self?.updateSaveButton()
            }
            
        }), for: .valueChanged)
        return $0
        
    }(RU_Section_StepperRow_StackView())
    private lazy var babiesBedsRow:RU_Section_StepperRow_StackView = {
        
        $0.image = UIImage(systemName: "stroller")
        $0.title = String(key: "settings.classified.beds.baby")
        $0.stepper.minimumValue = 0
        $0.stepper.addAction(.init(handler: { [weak self] _ in
            
            if let value = self?.babiesBedsRow.value, let intValue = Int(value) {
                
                self?.classified?.configuration.beds.babies = intValue
            }
            
        }), for: .valueChanged)
        return $0
        
    }(RU_Section_StepperRow_StackView())
    
    public override func loadView() {
        
        super.loadView()
        
navigationItem.title = String(key: "classified.create.step.2")

        let placeholderView = view.showPlaceholder()
        placeholderView.title = String(key: "classified.create.placeholder.configuration")
        placeholderView.image = UIImage(named: "placeholder_classified_configuration")

        let label:RU_Label = .init(String(key: "classified.create.placeholder.configuration.description"))
        label.textAlignment = .center
        placeholderView.contentStackView.addArrangedSubview(label)
        
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
