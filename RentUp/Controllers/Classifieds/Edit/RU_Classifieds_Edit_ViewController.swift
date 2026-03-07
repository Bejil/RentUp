//
//  RU_Classifieds_Edit_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 24/01/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_Edit_ViewController : RU_ViewController {
	
	public var classified:RU_Classified? {
		
		didSet {
            
            nameRow.textField.text = classified?.name
            
            if let value = classified?.fees {
                
                feesRow.textField.text = "\(value)"
            }
			
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
			
			tarificationTableView.reloadData()
			
			deleteButton.isHidden = false
			
			updateSaveButton()
		}
	}
	private lazy var nameRow:RU_Section_TextFieldRow_StackView = {
		
		$0.image = UIImage(systemName: "house.fill")
		$0.title = String(key: "settings.classified.name")
		$0.textField.placeholder = String(key: "settings.classified.name.placeholder")
		$0.textField.keyboardType = .alphabet
		$0.textField.autocapitalizationType = .words
		$0.textField.addAction(.init(handler: { [weak self] _ in
			
			self?.classified?.name = self?.nameRow.textField.text
			self?.updateSaveButton()
			
		}), for: .editingChanged)
		return $0
		
	}(RU_Section_TextFieldRow_StackView())
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
	private lazy var tarificationTableView:RU_TableView = {
		
		$0.isHeightDynamic = true
		$0.register(RU_Platform_TableViewCell.self, forCellReuseIdentifier: RU_Platform_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	private lazy var deleteButton:RU_Button = {
		
		$0.isHidden = true
		$0.type = .delete
		$0.image = UIImage(systemName: "trash")
		return $0
		
	}(RU_Button(String(key: "settings.classified.delete.button")){ [weak self] button in
		
		let alertController:RU_Classified_Delete_Alert_ViewController = .init()
		alertController.classified = self?.classified
		alertController.deleteCompletion = { [weak self] in
			
			self?.dismiss()
		}
		alertController.present()
	})
	private lazy var saveButton:RU_Button = {
		
		$0.isEnabled = false
		$0.image = UIImage(systemName: "square.and.arrow.down")
		return $0
		
	}(RU_Button(String(key: "settings.classified.save.button")) { [weak self] button in
		
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
	})
    private lazy var contentScrollView:RU_ScrollView = .init()
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
        
        title = String(key: "settings.classified.title.update")
        
        if classified == nil {
        
            classified = .init()
            title = String(key: "settings.classified.title.create")
        }
		
		let contentStackView:RU_StackView = .init()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(UI.Margins)
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
		}
		
		let generalSectionStackView:RU_Section_StackView = .init()
		generalSectionStackView.title = String(key: "settings.classified.general.section.title")
		generalSectionStackView.subtitle = String(key: "settings.classified.general.section.subtitle")
		generalSectionStackView.addArrangedSubview(nameRow)
        
        let feesTipStackView:RU_Tip_StackView = .init()
        feesTipStackView.title = String(key: "settings.classified.fees.tip.title")
        feesTipStackView.add(String(key: "settings.classified.fees.tip.content"))
        generalSectionStackView.addArrangedSubview(feesTipStackView)
        
        generalSectionStackView.addArrangedSubview(feesRow)
		contentStackView.addArrangedSubview(generalSectionStackView)
		
		let configurationSectionStackView:RU_Section_StackView = .init()
		configurationSectionStackView.title = String(key: "settings.classified.configuration.section.title")
		configurationSectionStackView.subtitle = String(key: "settings.classified.configuration.section.subtitle")
        configurationSectionStackView.addArrangedSubview(capacityRow)
		configurationSectionStackView.addArrangedSubview(doubleBedsRow)
		configurationSectionStackView.addArrangedSubview(singleBedsRow)
		configurationSectionStackView.addArrangedSubview(babiesBedsRow)
		contentStackView.addArrangedSubview(configurationSectionStackView)
		
		let tarificationSectionStackView:RU_Section_StackView = .init()
		tarificationSectionStackView.title = String(key: "settings.classified.tarification.section.title")
		tarificationSectionStackView.subtitle = String(key: "settings.classified.tarification.section.subtitle")
		tarificationSectionStackView.addArrangedSubview(tarificationTableView)
		contentStackView.addArrangedSubview(tarificationSectionStackView)
        
        contentStackView.addArrangedSubview(deleteButton)
		
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
		
		saveButton.isEnabled = classified?.canSave ?? false
	}
}

extension RU_Classifieds_Edit_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return RU_Platform.all?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let platform = RU_Platform.all?[indexPath.row]
		
		let cell: RU_Platform_TableViewCell = tableView.dequeueReusableCell(withIdentifier: RU_Platform_TableViewCell.identifier) as! RU_Platform_TableViewCell
		cell.platform = platform
		
		var details:[String] = []
		
		let tarification = classified?.tarification.first(where: { $0.platform == platform })
		
		if let price = tarification?.price {
			
			details.append(String(format: String(key: "settings.classified.price"), price))
		}
		
		if let cleaning = tarification?.cleaning {
			
			details.append(String(format: String(key: "settings.classified.cleaning"), cleaning))
		}
        
        if let travelersIncluded = tarification?.travelers.included, let travelersExtra = tarification?.travelers.extraPrice {
            
            details.append(String(format: String(key: "settings.classified.travelers"), travelersExtra, travelersIncluded))
        }
		
		if let weekPercent = tarification?.offers.first(where: { $0.reductiontype == .week })?.percent {
			
			details.append(String(format: String(key: "settings.classified.offer.week"), weekPercent))
		}
		
		if let monthPercent = tarification?.offers.first(where: { $0.reductiontype == .month })?.percent {
			
			details.append(String(format: String(key: "settings.classified.offer.month"), monthPercent))
		}
		
		cell.detailsLabel.text = details.joined(separator: " • ")
		
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let platform = RU_Platform.all?[indexPath.row]
		
		let viewController:RU_Classifieds_Edit_Platform_ViewController = .init()
		viewController.classified = classified
		viewController.platform = platform
		viewController.completion = { [weak self] in
			
			self?.tarificationTableView.reloadData()
			self?.updateSaveButton()
		}
		navigationController?.pushViewController(viewController, animated: true)
	}
}
