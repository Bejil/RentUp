//
//  RU_Classifieds_Edit_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 24/01/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_Edit_ViewController : RU_ViewController {
	
	private var editingChecklistItemUUID:String?
	private var isCreatingChecklistItem:Bool = false
	private var editingChecklistOriginalTitle:String?
	private var keyboardBottomInset:CGFloat = 0
	private var saveButtonBottomInset:CGFloat = 0
	
	public var classified:RU_Classified? {
		
		didSet {
            
            nameRow.textField.text = classified?.name
            
            if let value = classified?.fees {
                
                feesRow.textField.text = "\(value)"
            }
			
			checkInRow.set(
				hour: classified?.effectiveCheckInHour ?? RU_Classified.defaultCheckInHour,
				minute: classified?.effectiveCheckInMinute ?? 0
			)
			checkOutRow.set(
				hour: classified?.effectiveCheckOutHour ?? RU_Classified.defaultCheckOutHour,
				minute: classified?.effectiveCheckOutMinute ?? 0
			)
			
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
			
			updateChecklistSection()
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
	private lazy var checkInRow:RU_Section_TimeRow_StackView = {
		
		$0.image = UIImage(systemName: "figure.walk.arrival")
		$0.title = String(key: "settings.classified.schedule.checkIn")
		$0.datePicker.addAction(.init(handler: { [weak self] _ in
			
			guard let self else { return }
			self.classified?.checkInHour = self.checkInRow.hour
			self.classified?.checkInMinute = self.checkInRow.minute
			self.updateSaveButton()
			
		}), for: .valueChanged)
		return $0
		
	}(RU_Section_TimeRow_StackView())
	private lazy var checkOutRow:RU_Section_TimeRow_StackView = {
		
		$0.image = UIImage(systemName: "figure.walk.departure")
		$0.title = String(key: "settings.classified.schedule.checkOut")
		$0.datePicker.addAction(.init(handler: { [weak self] _ in
			
			guard let self else { return }
			self.classified?.checkOutHour = self.checkOutRow.hour
			self.classified?.checkOutMinute = self.checkOutRow.minute
			self.updateSaveButton()
			
		}), for: .valueChanged)
		return $0
		
	}(RU_Section_TimeRow_StackView())
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
	private lazy var checklistAddButton:RU_Button = {
		
		$0.image = UIImage(systemName: "plus")
		return $0
		
	}(RU_Button(String(key: "settings.classified.checklist.add.button")) { [weak self] _ in
		
		self?.beginChecklistItemEditing(item: nil)
	})
	private lazy var checklistTableView:RU_TableView = {
		
		$0.isHeightDynamic = true
		$0.register(RU_Classified_ChecklistItem_TableViewCell.self, forCellReuseIdentifier: RU_Classified_ChecklistItem_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	private lazy var checklistManageButton:RU_Button = {
		
		$0.isHidden = true
		$0.image = UIImage(systemName: "list.bullet")
		return $0
		
	}(RU_Button(String(key: "settings.classified.checklist.manage.button")) { [weak self] _ in
		
		self?.openChecklistViewController()
	})
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
					NotificationCenter.post(.updateBookings)
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
        feesTipStackView.addLabel(String(key: "settings.classified.fees.tip.content"))
        generalSectionStackView.addArrangedSubview(feesTipStackView)
        
        generalSectionStackView.addArrangedSubview(feesRow)
		contentStackView.addArrangedSubview(generalSectionStackView)
		
		let scheduleSectionStackView:RU_Section_StackView = .init()
		scheduleSectionStackView.title = String(key: "settings.classified.schedule.section.title")
		scheduleSectionStackView.subtitle = String(key: "settings.classified.schedule.section.subtitle")
		scheduleSectionStackView.addArrangedSubview(checkInRow)
		scheduleSectionStackView.addArrangedSubview(checkOutRow)
		contentStackView.addArrangedSubview(scheduleSectionStackView)
		
		let configurationSectionStackView:RU_Section_StackView = .init()
		configurationSectionStackView.title = String(key: "settings.classified.configuration.section.title")
		configurationSectionStackView.subtitle = String(key: "settings.classified.configuration.section.subtitle")
        configurationSectionStackView.addArrangedSubview(capacityRow)
		configurationSectionStackView.addArrangedSubview(doubleBedsRow)
		configurationSectionStackView.addArrangedSubview(singleBedsRow)
		configurationSectionStackView.addArrangedSubview(babiesBedsRow)
		contentStackView.addArrangedSubview(configurationSectionStackView)
		
		let checklistSectionStackView:RU_Section_StackView = .init()
		checklistSectionStackView.title = String(key: "settings.classified.checklist.section.title")
		checklistSectionStackView.subtitle = String(key: "settings.classified.checklist.section.subtitle")
		checklistSectionStackView.addArrangedSubview(checklistAddButton)
		checklistSectionStackView.addArrangedSubview(checklistTableView)
		checklistSectionStackView.addArrangedSubview(checklistManageButton)
		contentStackView.addArrangedSubview(checklistSectionStackView)
		
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
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        updateChecklistSection()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        checklistTableView.setEditing(true, animated: false)
    }
    
    public override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        
        view.layoutIfNeeded()
        
        saveButtonBottomInset = saveButton.bounds.height + 2 * UI.Margins
		updateScrollInsets()
    }
	
	private func updateScrollInsets() {
		
		let bottomInset = max(saveButtonBottomInset, keyboardBottomInset)
		contentScrollView.contentInset.bottom = bottomInset
		contentScrollView.verticalScrollIndicatorInsets.bottom = bottomInset
	}
	
	@objc private func keyboardWillChangeFrame(_ notification: Notification) {
		
		guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
			  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
		
		let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
		let overlap = contentScrollView.frame.intersection(keyboardFrameInView)
		keyboardBottomInset = overlap.isNull || overlap.height <= 0 ? 0 : overlap.height + UI.Margins
		
		UIView.animate(withDuration: duration) {
			
			self.updateScrollInsets()
			self.view.layoutIfNeeded()
		} completion: { _ in
			
			self.scrollToEditingChecklistItemIfNeeded()
		}
	}
	
	@objc private func keyboardWillHide(_ notification: Notification) {
		
		guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
		
		keyboardBottomInset = 0
		
		UIView.animate(withDuration: duration) {
			
			self.updateScrollInsets()
			self.view.layoutIfNeeded()
		}
	}
	
	private func scrollToEditingChecklistItemIfNeeded() {
		
		guard let uuid = editingChecklistItemUUID,
			  let index = classified?.checklist?.firstIndex(where: { $0.uuid == uuid }) else { return }
		
		let indexPath = IndexPath(row: index, section: 0)
		checklistTableView.layoutIfNeeded()
		
		var cell = checklistTableView.cellForRow(at: indexPath)
		
		if cell == nil {
			
			checklistTableView.scrollToRow(at: indexPath, at: .middle, animated: false)
			checklistTableView.layoutIfNeeded()
			cell = checklistTableView.cellForRow(at: indexPath)
		}
		
		guard let cell else { return }
		
		let frameInScrollView = cell.convert(cell.bounds, to: contentScrollView).insetBy(dx: 0, dy: -2 * UI.Margins)
		contentScrollView.scrollRectToVisible(frameInScrollView, animated: true)
	}
	
	private func updateSaveButton() {
		
		saveButton.isEnabled = classified?.canSave ?? false
	}
	
	private func updateChecklistSection() {
		
		let count = classified?.checklist?.count ?? 0
		let usesFullController = count > RU_Classifieds_Checklist_ViewController.inlineLimit
		
		checklistTableView.isHidden = usesFullController
		checklistAddButton.isHidden = usesFullController
		checklistManageButton.isHidden = !usesFullController
		
		if usesFullController {
			
			checklistManageButton.title = String(format: String(key: "settings.classified.checklist.manage.button"), count)
		}
		else {
			
			checklistTableView.reloadData()
		}
	}
	
	private func openChecklistViewController() {
		
		let viewController:RU_Classifieds_Checklist_ViewController = .init()
		viewController.classified = classified
		viewController.completion = { [weak self] in
			
			self?.updateChecklistSection()
			self?.updateSaveButton()
		}
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func removeChecklistItem(at index: Int) {
		
		classified?.checklist?.remove(at: index)
		
		if classified?.checklist?.isEmpty == true {
			
			classified?.checklist = nil
		}
		
		updateChecklistSection()
		updateSaveButton()
	}
	
	private func beginChecklistItemEditing(item: RU_Classified.ChecklistItem?) {
		
		if item == nil, (classified?.checklist?.count ?? 0) >= RU_Classifieds_Checklist_ViewController.inlineLimit {
			
			openChecklistViewController()
			return
		}
		
		if editingChecklistItemUUID != nil {
			
			view.endEditing(true)
		}
		
		if let item {
			
			isCreatingChecklistItem = false
			editingChecklistOriginalTitle = item.title
			editingChecklistItemUUID = item.uuid
		}
		else {
			
			let newItem = RU_Classified.ChecklistItem()
			
			if classified?.checklist == nil {
				
				classified?.checklist = []
			}
			
			classified?.checklist?.append(newItem)
			isCreatingChecklistItem = true
			editingChecklistOriginalTitle = nil
			editingChecklistItemUUID = newItem.uuid
		}
		
		updateChecklistSection()
		updateSaveButton()
		
		DispatchQueue.main.async { [weak self] in
			
			self?.scrollToEditingChecklistItemIfNeeded()
		}
	}
	
	private func commitChecklistItemEditing(title: String?) {
		
		guard let uuid = editingChecklistItemUUID,
			  let index = classified?.checklist?.firstIndex(where: { $0.uuid == uuid }) else { return }
		
		let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		
		if trimmedTitle.isEmpty {
			
			if isCreatingChecklistItem {
				
				classified?.checklist?.remove(at: index)
				
				if classified?.checklist?.isEmpty == true {
					
					classified?.checklist = nil
				}
			}
			else {
				
				classified?.checklist?[index].title = editingChecklistOriginalTitle
			}
		}
		else {
			
			classified?.checklist?[index].title = trimmedTitle
		}
		
		editingChecklistItemUUID = nil
		isCreatingChecklistItem = false
		editingChecklistOriginalTitle = nil
		
		updateChecklistSection()
		updateSaveButton()
	}
}

extension RU_Classifieds_Edit_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if tableView == checklistTableView {
			
			let count = classified?.checklist?.count ?? 0
			return min(count, RU_Classifieds_Checklist_ViewController.inlineLimit)
		}
		
		return RU_Platform.all?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if tableView == checklistTableView {
			
			let cell: RU_Classified_ChecklistItem_TableViewCell = tableView.dequeueReusableCell(withIdentifier: RU_Classified_ChecklistItem_TableViewCell.identifier) as! RU_Classified_ChecklistItem_TableViewCell
			let item = classified?.checklist?[indexPath.row]
			cell.item = item
			cell.showsInfoButton = true
			cell.verticalInset = UI.Margins / 2
			cell.selectionStyle = .none
			cell.isTitleEditing = item?.uuid == editingChecklistItemUUID
			cell.infoHandler = { [weak self] in
				
				self?.beginChecklistItemEditing(item: item)
			}
			cell.titleCommitHandler = { [weak self] title in
				
				self?.commitChecklistItemEditing(title: title)
			}
			
			if cell.isTitleEditing {
				
				DispatchQueue.main.async {
					
					cell.beginTitleEditing()
				}
			}
			
			return cell
		}
		
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
		
		if tableView == checklistTableView {
			
			return
		}
		
		let platform = RU_Platform.all?[indexPath.row]
        
        let alertController:RU_Classified_Platform_Alert_ViewController = .init()
        alertController.isEditing = true
        alertController.classified = classified
        alertController.platform = platform
        alertController.completion = { [weak self] in
            
            self?.tarificationTableView.reloadData()
            self?.updateSaveButton()
        }
        alertController.present(as: .Sheet)
	}
    
    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return tableView == checklistTableView
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard tableView == checklistTableView, editingStyle == .delete else { return }
        
        removeChecklistItem(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
