//
//  RU_Bookings_Checklist_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 20/07/2026.
//

import UIKit
import SnapKit

public class RU_Bookings_Checklist_ViewController : RU_ViewController {
	
	public var booking:RU_Booking? {
		
		didSet {
			
			tableView.reloadData()
			updateNavigationItems()
			updateProgress()
		}
	}
	
	private var checklistItems:[RU_Classified.ChecklistItem] {
		
		return booking?.classified?.checklist ?? []
	}
	
	private lazy var tableView:RU_TableView = {
		
		$0.register(RU_Classified_ChecklistItem_TableViewCell.self, forCellReuseIdentifier: RU_Classified_ChecklistItem_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	private lazy var progressTitleLabel:RU_Label = {
		
        $0.font = Fonts.Content.Title.H4
		$0.text = String(key: "bookings.details.checklist.progress.title")
		return $0
		
	}(RU_Label())
	private lazy var progressValueLabel:RU_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.textAlignment = .right
		$0.setContentHuggingPriority(.required, for: .horizontal)
		return $0
		
	}(RU_Label())
	private lazy var progressTrackView:UIView = {
		
		$0.backgroundColor = Colors.Content.Text.withAlphaComponent(0.1)
		$0.layer.cornerRadius = UI.Margins / 4
		$0.clipsToBounds = true
		$0.snp.makeConstraints { make in
			make.height.equalTo(UI.Margins / 2)
		}
		return $0
		
	}(UIView())
	private lazy var progressFillView:UIView = {
		
		$0.backgroundColor = Colors.Tertiary
		$0.layer.cornerRadius = UI.Margins / 4
		return $0
		
	}(UIView())
	private var progressFillWidthConstraint:Constraint?
	private lazy var progressContainerView:UIView = {
		
		$0.backgroundColor = Colors.Background.View
		$0.layer.cornerRadius = UI.CornerRadius
		$0.layer.shadowColor = UIColor.black.cgColor
		$0.layer.shadowOffset = CGSize(width: 0, height: 4)
		$0.layer.shadowOpacity = 0.08
		$0.layer.shadowRadius = UI.Margins
		
		let headerStackView:RU_StackView = .init(arrangedSubviews: [progressTitleLabel, progressValueLabel])
		headerStackView.axis = .horizontal
		headerStackView.spacing = UI.Margins
		headerStackView.alignment = .center
		
		progressTrackView.addSubview(progressFillView)
		progressFillView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			progressFillWidthConstraint = make.width.equalTo(0).constraint
		}
		
		let contentStackView:RU_StackView = .init(arrangedSubviews: [headerStackView, progressTrackView])
		contentStackView.axis = .vertical
		contentStackView.spacing = UI.Margins
		$0.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		
		return $0
		
	}(UIView())
	
	public override func loadView() {
		
		super.loadView()
		
		title = String(key: "settings.classified.checklist.controller.title")
		
		view.addSubview(tableView)
		view.addSubview(progressContainerView)
		
		tableView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		progressContainerView.snp.makeConstraints { make in
			make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		updateNavigationItems()
		updateProgress()
	}
	
	private func updateNavigationItems() {
		
		guard !checklistItems.isEmpty else {
			
			navigationItem.rightBarButtonItem = nil
			return
		}
		
		navigationItem.rightBarButtonItem = .init(image: UIImage(systemName: "square.and.arrow.up"), primaryAction: .init(handler: { [weak self] _ in
			
			self?.shareChecklist()
		}))
	}
	
	private func shareChecklist() {
		
		guard !checklistItems.isEmpty else { return }
		
		var lines:[String] = []
		
		if let name = booking?.classified?.name, !name.isEmpty {
			
			lines.append(String(format: String(key: "settings.classified.checklist.share.title"), " — \(name)"))
		}
		else {
			
			lines.append(String(format: String(key: "settings.classified.checklist.share.title"), ""))
		}
		
		lines.append("")
		
		checklistItems.forEach { item in
			
			guard let title = item.title, !title.isEmpty else { return }
			
			lines.append(String(format: String(key: "settings.classified.checklist.share.item"), title))
		}
		
		let activityViewController = UIActivityViewController(activityItems: [lines.joined(separator: "\n")], applicationActivities: nil)
		
		if let popover = activityViewController.popoverPresentationController {
			
			popover.barButtonItem = navigationItem.rightBarButtonItem
		}
		
		present(activityViewController, animated: true)
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		booking?.resolveLiveClassified { [weak self] _ in
			
			self?.tableView.reloadData()
			self?.updateProgress()
		}
	}
	
	public override func viewDidLayoutSubviews() {
		
		super.viewDidLayoutSubviews()
		
		let bottomInset = progressContainerView.bounds.height + 2 * UI.Margins
		tableView.contentInset.bottom = bottomInset
		tableView.verticalScrollIndicatorInsets.bottom = bottomInset
		updateProgressFill(animated: false)
	}
	
	private func isItemCompleted(_ item: RU_Classified.ChecklistItem) -> Bool {
		
		return booking?.checklistCompletedUUIDs?.contains(item.uuid) == true
	}
	
	private func toggleItem(_ item: RU_Classified.ChecklistItem) {
		
		let total = checklistItems.count
		let previouslyCompleted = checklistItems.filter { isItemCompleted($0) }.count
		let wasComplete = total > 0 && previouslyCompleted == total
		
		var completed = booking?.checklistCompletedUUIDs ?? []
		
		if let index = completed.firstIndex(of: item.uuid) {
			
			completed.remove(at: index)
		}
		else {
			
			completed.append(item.uuid)
		}
		
		let validUUIDs = Set(checklistItems.map(\.uuid))
		completed = completed.filter { validUUIDs.contains($0) }
		
		booking?.checklistCompletedUUIDs = completed.isEmpty ? nil : completed
		updateProgress()
		
		let nowCompleted = checklistItems.filter { isItemCompleted($0) }.count
		let isComplete = total > 0 && nowCompleted == total
		
		if isComplete && !wasComplete {
			
			presentChecklistCompletedAlert()
		}
		
		booking?.save { error in
			
			if let error {
				
				RU_Alert_ViewController.present(error)
			}
		}
	}
	
	private func presentChecklistCompletedAlert() {
		
		let alertController:RU_Alert_ViewController = .init()
		alertController.title = String(key: "bookings.details.checklist.completed.title")
		alertController.add(String(key: "bookings.details.checklist.completed.message"))
		alertController.addButton(title: String(key: "bookings.details.checklist.completed.button")) { _ in
			
			RU_Confetti.stop()
			alertController.close()
		}
		alertController.dismissHandler = {
			
			RU_Confetti.stop()
		}
        alertController.present {
            
            RU_Confetti.start()
        }
	}
	
	private func updateProgress() {
		
		let total = checklistItems.count
		let completed = checklistItems.filter { isItemCompleted($0) }.count
		let percent = total > 0 ? Int((Double(completed) / Double(total)) * 100) : 0
		
		progressValueLabel.text = String(format: String(key: "bookings.details.checklist.progress.value"), percent)
		updateProgressFill(animated: true)
	}
	
	private func updateProgressFill(animated: Bool) {
		
		let total = checklistItems.count
		let completed = checklistItems.filter { isItemCompleted($0) }.count
		let ratio = total > 0 ? CGFloat(completed) / CGFloat(total) : 0
		let width = progressTrackView.bounds.width * ratio
		
		guard progressTrackView.bounds.width > 0 else { return }
		
		let updates = {
			
			self.progressFillWidthConstraint?.update(offset: width)
			self.progressTrackView.layoutIfNeeded()
		}
		
		if animated {
			
			UIView.animation(0.3, updates)
		}
		else {
			
			updates()
		}
	}
}

extension RU_Bookings_Checklist_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return checklistItems.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let item = checklistItems[indexPath.row]
		let cell: RU_Classified_ChecklistItem_TableViewCell = tableView.dequeueReusableCell(withIdentifier: RU_Classified_ChecklistItem_TableViewCell.identifier) as! RU_Classified_ChecklistItem_TableViewCell
		cell.item = item
		cell.showsInfoButton = false
		cell.showsSelectionControl = true
		cell.isItemSelected = isItemCompleted(item)
		cell.verticalInset = UI.Margins
		cell.selectionStyle = .none
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let item = checklistItems[indexPath.row]
		toggleItem(item)
		
		if let cell = tableView.cellForRow(at: indexPath) as? RU_Classified_ChecklistItem_TableViewCell {
			
			cell.isItemSelected = isItemCompleted(item)
		}
	}
}
