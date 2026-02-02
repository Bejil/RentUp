//
//  RU_Settings_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_Settings_ViewController: RU_ViewController {
	
	private var classifieds:[RU_Classified]? {
		
		didSet {
			
			classifiedsTableView.reloadData()
		}
	}
	private lazy var contentScrollView:RU_ScrollView = {
		
		$0.isCentered = false
		$0.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			make.right.width.equalToSuperview()
		}
		return $0
		
	}(RU_ScrollView())
	private lazy var contentStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(UI.Margins)
		return $0
		
	}(RU_StackView())
	private lazy var platformsTableView:RU_TableView = {
		
		$0.isHeightDynamic = true
		$0.register(RU_Platform_TableViewCell.self, forCellReuseIdentifier: RU_Platform_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	private lazy var classifiedsTableView:RU_TableView = {
		
		$0.isHeightDynamic = true
		$0.register(RU_Classified_TableViewCell.self, forCellReuseIdentifier: RU_Classified_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.settings"), image: UIImage(systemName: "slider.horizontal.3"), tag: RU_TabBarController.Indexes.Settings.rawValue)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "settings.title")
		
		contentView.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let platformsSectionTitleStackView:RU_Section_StackView = .init()
		platformsSectionTitleStackView.title = String(key: "settings.platforms.section.title")
		platformsSectionTitleStackView.subtitle = String(key: "settings.platforms.section.subtitle")
		platformsSectionTitleStackView.addArrangedSubview(platformsTableView)
		contentStackView.addArrangedSubview(platformsSectionTitleStackView)
		
		let classifiedsSectionTitleStackView:RU_Section_StackView = .init()
		classifiedsSectionTitleStackView.title = String(key: "settings.classifieds.section.title")
		classifiedsSectionTitleStackView.subtitle = String(key: "settings.classifieds.section.subtitle")
		classifiedsSectionTitleStackView.addArrangedSubview(classifiedsTableView)
		
		let addClassifiedButton:RU_Button = .init(String(key: "settings.classifieds.section.button")) { _ in
			
			let viewController:RU_Settings_Classified_ViewController = .init()
			UI.MainController.present(RU_NavigationController(rootViewController: viewController), animated: true)
		}
		addClassifiedButton.image = UIImage(systemName: "plus.circle")
		classifiedsSectionTitleStackView.addArrangedSubview(addClassifiedButton)
		
		contentStackView.addArrangedSubview(classifiedsSectionTitleStackView)
		
		// MARK: - About Section
		let aboutSectionStackView:RU_Section_StackView = .init()
		aboutSectionStackView.title = String(key: "settings.about.section.title")
		
		let versionLabel:RU_Label = .init()
		versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		let versionRow:RU_Section_Row_StackView = .init()
		versionRow.image = UIImage(systemName: "info.circle.fill")
		versionRow.title = String(key: "settings.about.version")
		versionRow.view = versionLabel
		aboutSectionStackView.addArrangedSubview(versionRow)
		
		let resetButton:RU_Button = .init(String(key: "settings.reset.button")) { _ in
			
			let alertController:RU_Alert_ViewController = .init()
			alertController.title = String(key: "settings.reset.alert.title")
			alertController.add(String(key: "settings.reset.alert.content"))
			let button = alertController.addButton(title: String(key: "settings.reset.alert.button")) { [weak self] _ in
				
				alertController.close() { [weak self] in
					
					self?.reset()
				}
			}
			button.type = .delete
			alertController.addCancelButton()
			alertController.present()
		}
		resetButton.type = .delete
		resetButton.image = UIImage(systemName: "trash")
		aboutSectionStackView.addArrangedSubview(resetButton)
		
		contentStackView.addArrangedSubview(aboutSectionStackView)
		
		NotificationCenter.add(.updatePlatforms) { [weak self] _ in
			
			self?.platformsTableView.reloadData()
		}
		
		NotificationCenter.add(.updateClassifieds) { [weak self] _ in
			
			self?.updateClassifieds()
		}
		
		updateClassifieds()
	}
	
	private func updateClassifieds() {
		
		RU_Alert_ViewController.presentLoading { [weak self] alertController in
			
			RU_Classified.getAll { [weak self] error, classifieds in
				
				alertController?.close { [weak self] in
					
					if let error {
						
						RU_Alert_ViewController.present(error) { [weak self] in
							
							self?.updateClassifieds()
						}
					}
					
					self?.classifieds = classifieds
				}
			}
		}
	}
	
	private func reset() {
		
		UserDefaults.standard.resetAll()
		
		RU_Alert_ViewController.presentLoading { [weak self] alertController in
			
			RU_Platform.setUp { [weak self] error in
				
				alertController?.close { [weak self] in
					
					if let error {
						
						RU_Alert_ViewController.present(error, handler: { [weak self] in
							
							self?.reset()
						})
					}
					else {
						
						NotificationCenter.post(.updatePlatforms)
						NotificationCenter.post(.updateClassifieds)
						NotificationCenter.post(.updateBookings)
					}
				}
			}
		}
	}
}

extension RU_Settings_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if tableView == platformsTableView {
			
			return RU_Platform.all?.count ?? 0
		}
		else if tableView == classifiedsTableView {
			
			return classifieds?.count ?? 0
		}
		
		return 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if tableView == platformsTableView {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: RU_Platform_TableViewCell.identifier, for: indexPath) as! RU_Platform_TableViewCell
			cell.platform = RU_Platform.all?[indexPath.row]
			cell.detailsLabel.text = RU_Platform.all?[indexPath.row].detail
			return cell
		}
		else if tableView == classifiedsTableView {
			
			let classified = classifieds?[indexPath.row]
			
			let cell = tableView.dequeueReusableCell(withIdentifier: RU_Classified_TableViewCell.identifier, for: indexPath) as! RU_Classified_TableViewCell
			cell.classified = classified
			cell.deleteHandler = { classified in
				
				let alertController:RU_Classified_Delete_Alert_ViewController = .init()
				alertController.classified = classified
				alertController.present()
			}
			cell.editHandler = { [weak self] classified in
				
				let viewController:RU_Settings_Classified_ViewController = .init()
				viewController.classified = classified
				self?.navigationController?.pushViewController(viewController, animated: true)
			}
			return cell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: RU_TableViewCell.identifier, for: indexPath) as! RU_TableViewCell
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if tableView == platformsTableView {
			
			let viewController:RU_Settings_Platform_ViewController = .init()
			viewController.platform = RU_Platform.all?[indexPath.row]
			navigationController?.pushViewController(viewController, animated: true)
		}
		else if tableView == classifiedsTableView {
			
			let viewController:RU_Settings_Classified_ViewController = .init()
			viewController.classified = classifieds?[indexPath.row]
			navigationController?.pushViewController(viewController, animated: true)
		}
	}
	
	public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		if tableView == classifiedsTableView {
			
			return UIContextMenuConfiguration.init(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
				
				return nil
				
			}) { (suggestedActions) -> UIMenu? in
				
				let cell = tableView.cellForRow(at: indexPath) as? RU_Classified_TableViewCell
				return cell?.menu
			}
		}
		
		return nil
	}
	
	public func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
		
		if let indexPath = configuration.identifier as? IndexPath {
			
			animator.addCompletion {
				
				tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
			}
		}
		
		return
	}
	
	public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		if tableView == classifiedsTableView {
			
			let cell = tableView.cellForRow(at: indexPath) as? RU_Classified_TableViewCell
			return cell?.trailingSwipeActionsConfiguration
		}
		
		return nil
	}
}

