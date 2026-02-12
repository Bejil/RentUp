//
//  RU_Classifieds_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 04/02/2026.
//

import UIKit
import SnapKit

public class RU_Classifieds_ViewController : RU_ViewController {
	
	private var classifieds:[RU_Classified]? {
		
		didSet {
			
			view.dismissPlaceholder()
			
			tableView.reloadData()
			
			if classifieds?.isEmpty == true {
				
				let placeholderView = view.showPlaceholder(.Empty)
				let addButton:RU_Button = .init(String(key: "classifieds.create.button")) { _ in
					
					UI.MainController.present(RU_NavigationController(rootViewController: RU_Classifieds_Edit_ViewController()), animated: true)
				}
				addButton.image = UIImage(systemName: "plus.circle")
				placeholderView.contentStackView.addArrangedSubview(addButton)
			}
		}
	}
	private lazy var tableView:RU_TableView = {
		
		$0.register(RU_Classified_TableViewCell.self, forCellReuseIdentifier: RU_Classified_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.classifieds"), image: UIImage(systemName: "house"), tag: RU_TabBarController.Indexes.allCases.firstIndex(of: .Classifieds) ?? 0)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "classifieds.title")
		
        view.addSubview(tableView)
		
		let addButton:RU_Button = .init(String(key: "classifieds.create.button")) { _ in
			
			UI.MainController.present(RU_NavigationController(rootViewController: RU_Classifieds_Edit_ViewController()), animated: true)
		}
		addButton.image = UIImage(systemName: "plus.circle")
        
        let bottomButtonsVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .light))
        bottomButtonsVisualEffectView.contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.edges.equalTo(bottomButtonsVisualEffectView.safeAreaLayoutGuide).inset(UI.Margins)
        }
        bottomButtonsVisualEffectView.contentView.addLine(position: .top)
        view.addSubview(bottomButtonsVisualEffectView)
        
        tableView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.bottom.equalTo(bottomButtonsVisualEffectView.snp.top).offset(-UI.Margins)
        }
        
        bottomButtonsVisualEffectView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(UI.Margins)
            make.right.left.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom).inset(UI.Margins)
        }
		
		NotificationCenter.add(.updateClassifieds, { [weak self] _ in
			
			self?.updateClassifieds()
		})
		
		updateClassifieds()
	}
	
	private func updateClassifieds() {
		
		view.showPlaceholder(.Loading)
		
		RU_Classified.getAll { [weak self] error, classifieds in
			
			self?.view.dismissPlaceholder()
			
			if let error {
				
				self?.view.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					self?.updateClassifieds()
				}
			}
			else {
				
				self?.classifieds = classifieds
			}
		}
	}
}

extension RU_Classifieds_ViewController : UITableViewDelegate, UITableViewDataSource {
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return classifieds?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let classified = classifieds?[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: RU_Classified_TableViewCell.identifier, for: indexPath) as! RU_Classified_TableViewCell
		cell.classified = classified
		cell.deleteHandler = { classified in
			
			let alertController:RU_Classified_Delete_Alert_ViewController = .init()
			alertController.classified = classified
			alertController.present()
		}
		cell.editHandler = { [weak self] classified in
			
			let viewController:RU_Classifieds_Edit_ViewController = .init()
			viewController.classified = classified
			self?.navigationController?.pushViewController(viewController, animated: true)
		}
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let viewController:RU_Classifieds_Edit_ViewController = .init()
		viewController.classified = classifieds?[indexPath.row]
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		return UIContextMenuConfiguration.init(identifier: indexPath as NSIndexPath, previewProvider: { () -> UIViewController? in
			
			return nil
			
		}) { (suggestedActions) -> UIMenu? in
			
			let cell = tableView.cellForRow(at: indexPath) as? RU_Classified_TableViewCell
			return cell?.menu
		}
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
		
		let cell = tableView.cellForRow(at: indexPath) as? RU_Classified_TableViewCell
		return cell?.trailingSwipeActionsConfiguration
	}
}
