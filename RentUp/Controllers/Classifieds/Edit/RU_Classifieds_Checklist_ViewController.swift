//
//  RU_Classifieds_Checklist_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 20/07/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_Checklist_ViewController : RU_ViewController {
	
	public static let inlineLimit = 5
	
	public var classified:RU_Classified?
	public var isReadOnly:Bool = false
	public var shouldPersistChanges:Bool = false
	public var completion:(()->Void)?
	
	private var selectedItemUUIDs:Set<String> = []
	
	private lazy var tableView:RU_TableView = {
		
		$0.register(RU_Classified_ChecklistItem_TableViewCell.self, forCellReuseIdentifier: RU_Classified_ChecklistItem_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	private lazy var addButton:RU_Button = {
		
		$0.image = UIImage(systemName: "plus.circle")
		return $0
		
	}(RU_Button(String(key: "settings.classified.checklist.add.button")) { [weak self] _ in
		
		self?.presentChecklistItemAlert(item: nil)
	})
	private lazy var deleteButton:RU_Button = {
		
		$0.type = .delete
		$0.image = UIImage(systemName: "trash")
		return $0
		
	}(RU_Button(String(key: "settings.classified.checklist.deleteSelected.button")) { [weak self] _ in
		
		self?.deleteSelectedItems()
	})
	private lazy var selectAllNoneButton:RU_Button = {
		
		$0.type = .secondary
		return $0
		
	}(RU_Button(String(key: "settings.classified.checklist.selectAll.button")) { [weak self] _ in
		
		self?.toggleSelectAllOrNone()
	})
	private lazy var editingActionsStackView:RU_StackView = {
		
		$0.isHidden = true
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.distribution = .fillEqually
		$0.addArrangedSubview(selectAllNoneButton)
		$0.addArrangedSubview(deleteButton)
		return $0
		
	}(RU_StackView())
	private lazy var deleteAllButton:RU_Button = {
		
		$0.type = .delete
		$0.image = UIImage(systemName: "trash.slash")
		return $0
		
	}(RU_Button(String(key: "settings.classified.checklist.deleteAll.button")) { [weak self] _ in
		
		self?.presentDeleteAllAlert()
	})
	private lazy var bottomButtonsStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins / 2
		return $0
		
	}(RU_StackView())
	
	public override func loadView() {
		
		super.loadView()
		
		title = String(key: "settings.classified.checklist.controller.title")
		
		view.addSubview(tableView)
		tableView.snp.makeConstraints { make in
			make.edges.equalTo(view.safeAreaLayoutGuide)
		}
		
		if !isReadOnly {
			
			bottomButtonsStackView.addArrangedSubview(addButton)
			bottomButtonsStackView.addArrangedSubview(editingActionsStackView)
			bottomButtonsStackView.addArrangedSubview(deleteAllButton)
			view.addSubview(bottomButtonsStackView)
			bottomButtonsStackView.snp.makeConstraints { make in
				make.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
				make.left.right.equalTo(view.safeAreaLayoutGuide).inset(1.5 * UI.Margins)
			}
		}
		
		updateNavigationItems()
		updateBottomBar(animated: false)
        applyTableEditingMode()
		updateEmptyState()
	}
	
	public override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		updateTableInsets()
	}
	
	public override func setEditing(_ editing: Bool, animated: Bool) {
		
		super.setEditing(editing, animated: animated)
		
		selectedItemUUIDs.removeAll()
		applyTableEditingMode()
		updateBottomBar(animated: animated)
		updateSelection()
		updateNavigationItems()
	}
	
	private func applyTableEditingMode() {
		
		if isReadOnly || isEditing {
			
			// Mode sélection / lecture : pas d'édition native (sinon décalage / rognage des cellules)
			tableView.setEditing(false, animated: false)
		}
		else {
			
			tableView.setEditing(true, animated: true)
		}
		
		tableView.reloadData()
		tableView.layoutIfNeeded()
		updateEmptyState()
	}
	
	private func updateEmptyState() {
		
		tableView.dismissPlaceholder()
		
		if classified?.checklist?.isEmpty ?? true {
			
			tableView.showPlaceholder(.Empty)
		}
	}
	
	private func updateTableInsets() {
		
		view.layoutIfNeeded()
		
		let bottomInset = isReadOnly ? 0 : bottomButtonsStackView.bounds.height + 2 * UI.Margins
		tableView.contentInset.bottom = bottomInset
		tableView.verticalScrollIndicatorInsets.bottom = bottomInset
	}
	
	private func updateBottomBar(animated: Bool) {
		
		guard !isReadOnly else { return }
		
		let isEmpty = classified?.checklist?.isEmpty ?? true
		
		let updates = {
			
			self.addButton.isHidden = self.isEditing
			self.editingActionsStackView.isHidden = !self.isEditing
			self.deleteAllButton.isHidden = self.isEditing || isEmpty
			
			self.addButton.alpha = self.addButton.isHidden ? 0 : 1
			self.editingActionsStackView.alpha = self.editingActionsStackView.isHidden ? 0 : 1
			self.deleteAllButton.alpha = self.deleteAllButton.isHidden ? 0 : 1
		}
		
		if animated {
			
			UIView.animation(0.3, updates)
		}
		else {
			
			updates()
		}
		
		updateTableInsets()
	}
	
	private func updateNavigationItems() {
		
		if isReadOnly {
			
			navigationItem.rightBarButtonItem = nil
			return
		}
		
		let isEmpty = classified?.checklist?.isEmpty ?? true
		navigationItem.rightBarButtonItem = isEmpty ? nil : editButtonItem
	}
	
	private func updateSelection() {
		
		deleteButton.isEnabled = !selectedItemUUIDs.isEmpty
		selectAllNoneButton.title = selectedItemUUIDs.isEmpty
			? String(key: "settings.classified.checklist.selectAll.button")
			: String(key: "settings.classified.checklist.selectNone.button")
	}
	
	private func toggleSelectAllOrNone() {
		
		if selectedItemUUIDs.isEmpty {
			
			selectedItemUUIDs = Set((classified?.checklist ?? []).map(\.uuid))
		}
		else {
			
			selectedItemUUIDs.removeAll()
		}
		
		tableView.reloadData()
		updateSelection()
	}
	
	private func configureCell(_ cell: RU_Classified_ChecklistItem_TableViewCell, at indexPath: IndexPath) {
		
		let item = classified?.checklist?[indexPath.row]
		cell.item = item
		cell.showsInfoButton = !isReadOnly && !isEditing
		cell.showsSelectionControl = isEditing
		cell.isItemSelected = item.map { selectedItemUUIDs.contains($0.uuid) } ?? false
		cell.verticalInset = (isReadOnly || isEditing) ? UI.Margins : UI.Margins / 2
		cell.selectionStyle = .none
		cell.infoHandler = { [weak self] in
			
			self?.presentChecklistItemAlert(item: item)
		}
	}
	
	private func removeItems(at indexPaths: [IndexPath]) {
		
		let sortedIndexPaths = indexPaths.sorted { $0.row > $1.row }
		sortedIndexPaths.forEach { indexPath in
			classified?.checklist?.remove(at: indexPath.row)
		}
		
		if classified?.checklist?.isEmpty == true {
			
			classified?.checklist = nil
		}
		
		selectedItemUUIDs.removeAll()
		tableView.reloadData()
		updateEmptyState()
		updateNavigationItems()
		updateBottomBar(animated: true)
		updateSelection()
		notifyChanges()
	}
	
	private func deleteSelectedItems() {
		
		guard !selectedItemUUIDs.isEmpty else { return }
		
		let indexPaths = (classified?.checklist ?? []).enumerated().compactMap { index, item -> IndexPath? in
			
			selectedItemUUIDs.contains(item.uuid) ? IndexPath(row: index, section: 0) : nil
		}
		
		removeItems(at: indexPaths)
		setEditing(false, animated: true)
	}
	
	private func presentDeleteAllAlert() {
		
		let alertController:RU_Alert_ViewController = .init()
		alertController.title = String(key: "settings.classified.checklist.deleteAll.alert.title")
		alertController.add(String(key: "settings.classified.checklist.deleteAll.alert.content"))
		let button = alertController.addButton(title: String(key: "settings.classified.checklist.deleteAll.button")) { [weak self] _ in
			
			self?.classified?.checklist = nil
			self?.selectedItemUUIDs.removeAll()
			self?.tableView.reloadData()
			self?.updateEmptyState()
			self?.setEditing(false, animated: true)
			self?.updateNavigationItems()
			self?.updateBottomBar(animated: true)
			self?.notifyChanges()
			alertController.close()
		}
		button.type = .delete
		button.image = UIImage(systemName: "trash.slash")
		alertController.addCancelButton()
		alertController.present()
	}
	
	private func presentChecklistItemAlert(item: RU_Classified.ChecklistItem?) {
		
		let alertController:RU_Classified_ChecklistItem_Alert_ViewController = .init()
		alertController.isCreating = item == nil
		
		if let item {
			
			alertController.item = item
		}
		
		alertController.saveHandler = { [weak self] savedItem in
			
			if let item {
				
				if let index = self?.classified?.checklist?.firstIndex(where: { $0.uuid == item.uuid }) {
					
					self?.classified?.checklist?[index] = savedItem
				}
			}
			else {
				
				if self?.classified?.checklist == nil {
					
					self?.classified?.checklist = []
				}
				self?.classified?.checklist?.append(savedItem)
			}
			
			self?.tableView.reloadData()
			self?.updateEmptyState()
			self?.updateNavigationItems()
			self?.updateBottomBar(animated: true)
			self?.notifyChanges()
		}
		alertController.present(as: .Alert)
	}
	
	private func notifyChanges() {
		
		completion?()
		
		guard shouldPersistChanges else { return }
		
		classified?.save { error in
			
			if let error {
				
				RU_Alert_ViewController.present(error)
			}
		}
	}
}

extension RU_Classifieds_Checklist_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return classified?.checklist?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell: RU_Classified_ChecklistItem_TableViewCell = tableView.dequeueReusableCell(withIdentifier: RU_Classified_ChecklistItem_TableViewCell.identifier) as! RU_Classified_ChecklistItem_TableViewCell
		configureCell(cell, at: indexPath)
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		guard isEditing, let uuid = classified?.checklist?[indexPath.row].uuid else { return }
		
		if selectedItemUUIDs.contains(uuid) {
			
			selectedItemUUIDs.remove(uuid)
		}
		else {
			
			selectedItemUUIDs.insert(uuid)
		}
		
		if let cell = tableView.cellForRow(at: indexPath) as? RU_Classified_ChecklistItem_TableViewCell {
			
			cell.isItemSelected = selectedItemUUIDs.contains(uuid)
		}
		
		updateSelection()
	}
	
	public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		
		return !isReadOnly && !isEditing
	}
	
	public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		
		return !isReadOnly && !isEditing
	}
	
	public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			
			removeItems(at: [indexPath])
		}
	}
	
	public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		
		guard var items = classified?.checklist else { return }
		
		let item = items.remove(at: sourceIndexPath.row)
		items.insert(item, at: destinationIndexPath.row)
		classified?.checklist = items
		notifyChanges()
	}
}
