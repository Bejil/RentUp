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
	private var editingItemUUID:String?
	private var isCreatingItem:Bool = false
	private var editingOriginalTitle:String?
	private var keyboardBottomInset:CGFloat = 0
	
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
		
		self?.beginChecklistItemEditing(item: nil)
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
	private lazy var bottomButtonsStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = UI.Margins / 2
		$0.addArrangedSubview(addButton)
		$0.addArrangedSubview(editingActionsStackView)
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
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
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
		
		let buttonsInset = isReadOnly ? 0 : bottomButtonsStackView.bounds.height + 2 * UI.Margins
		let bottomInset = max(buttonsInset, keyboardBottomInset)
		tableView.contentInset.bottom = bottomInset
		tableView.verticalScrollIndicatorInsets.bottom = bottomInset
	}
	
	@objc private func keyboardWillChangeFrame(_ notification: Notification) {
		
		guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
			  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
		
		let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
		let overlap = tableView.frame.intersection(keyboardFrameInView)
		keyboardBottomInset = overlap.isNull || overlap.height <= 0 ? 0 : overlap.height + UI.Margins
		
		UIView.animate(withDuration: duration) {
			
			self.updateTableInsets()
			self.view.layoutIfNeeded()
		} completion: { _ in
			
			self.scrollToEditingItemIfNeeded()
		}
	}
	
	@objc private func keyboardWillHide(_ notification: Notification) {
		
		guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
		
		keyboardBottomInset = 0
		
		UIView.animate(withDuration: duration) {
			
			self.updateTableInsets()
			self.view.layoutIfNeeded()
		}
	}
	
	private func scrollToEditingItemIfNeeded() {
		
		guard let uuid = editingItemUUID,
			  let index = classified?.checklist?.firstIndex(where: { $0.uuid == uuid }) else { return }
		
		let indexPath = IndexPath(row: index, section: 0)
		guard tableView.numberOfRows(inSection: 0) > index else { return }
		
		tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
	}
	
	private func updateBottomBar(animated: Bool) {
		
		guard !isReadOnly else { return }
		
		let updates = {
			
			self.addButton.isHidden = self.isEditing
			self.editingActionsStackView.isHidden = !self.isEditing
			
			self.addButton.alpha = self.addButton.isHidden ? 0 : 1
			self.editingActionsStackView.alpha = self.editingActionsStackView.isHidden ? 0 : 1
			
			self.bottomButtonsStackView.layoutIfNeeded()
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
		
		let isEmpty = classified?.checklist?.isEmpty ?? true
		var items:[UIBarButtonItem] = []
		
		if !isEmpty {
			
			items.append(.init(image: UIImage(systemName: "square.and.arrow.up"), primaryAction: .init(handler: { [weak self] _ in
				
				self?.shareChecklist()
			})))
		}
		
		if !isReadOnly, !isEmpty {
			
			items.append(editButtonItem)
		}
		
		navigationItem.rightBarButtonItems = items.isEmpty ? nil : items
	}
	
	private func shareChecklist() {
		
		guard let items = classified?.checklist, !items.isEmpty else { return }
		
		var lines:[String] = []
		
		if let name = classified?.name, !name.isEmpty {
			
			lines.append(String(format: String(key: "settings.classified.checklist.share.title"), " — \(name)"))
		}
		else {
			
			lines.append(String(format: String(key: "settings.classified.checklist.share.title"), ""))
		}
		
		lines.append("")
		
		items.forEach { item in
			
			guard let title = item.title, !title.isEmpty else { return }
			lines.append(String(format: String(key: "settings.classified.checklist.share.item"), title))
		}
		
		let activityViewController = UIActivityViewController(activityItems: [lines.joined(separator: "\n")], applicationActivities: nil)
		
		if let popover = activityViewController.popoverPresentationController {
			
			popover.barButtonItem = navigationItem.rightBarButtonItems?.first
		}
		
		present(activityViewController, animated: true)
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
		cell.isTitleEditing = item?.uuid == editingItemUUID
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
	}
	
	private func beginChecklistItemEditing(item: RU_Classified.ChecklistItem?) {
		
		guard !isReadOnly, !isEditing else { return }
		
		if editingItemUUID != nil {
			
			view.endEditing(true)
		}
		
		if let item {
			
			isCreatingItem = false
			editingOriginalTitle = item.title
			editingItemUUID = item.uuid
		}
		else {
			
			let newItem = RU_Classified.ChecklistItem()
			
			if classified?.checklist == nil {
				
				classified?.checklist = []
			}
			
			classified?.checklist?.append(newItem)
			isCreatingItem = true
			editingOriginalTitle = nil
			editingItemUUID = newItem.uuid
		}
		
		tableView.reloadData()
		updateEmptyState()
		updateNavigationItems()
		updateBottomBar(animated: true)
		
		DispatchQueue.main.async { [weak self] in
			
			self?.scrollToEditingItemIfNeeded()
		}
	}
	
	private func commitChecklistItemEditing(title: String?) {
		
		guard let uuid = editingItemUUID,
			  let index = classified?.checklist?.firstIndex(where: { $0.uuid == uuid }) else { return }
		
		let trimmedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
		
		if trimmedTitle.isEmpty {
			
			if isCreatingItem {
				
				classified?.checklist?.remove(at: index)
				
				if classified?.checklist?.isEmpty == true {
					
					classified?.checklist = nil
				}
			}
			else {
				
				classified?.checklist?[index].title = editingOriginalTitle
			}
		}
		else {
			
			classified?.checklist?[index].title = trimmedTitle
		}
		
		editingItemUUID = nil
		isCreatingItem = false
		editingOriginalTitle = nil
		
		tableView.reloadData()
		updateEmptyState()
		updateNavigationItems()
		updateBottomBar(animated: true)
		notifyChanges()
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
