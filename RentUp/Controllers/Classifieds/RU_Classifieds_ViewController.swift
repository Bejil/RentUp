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
            
            let isEmpty = classifieds?.isEmpty == true
            
            navigationItem.rightBarButtonItem = isEmpty ? nil : editButtonItem
			
			if isEmpty {
                
                UIApplication.presentWelcome()
			}
		}
	}
    private lazy var comparatorTipView:UIView = {
        
        $0.addSubview(comparatorTipStackView)
        comparatorTipStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.left.right.equalToSuperview().inset(UI.Margins)
        }
        return $0
        
    }(UIView())
    private lazy var comparatorTipStackView:RU_Tip_StackView = {
        
        $0.contentStackView.spacing = UI.Margins
        $0.title = String(key: "classifieds.comparator.title")
        $0.add(String(key: "classifieds.comparator.tip"))
        $0.add(RU_Button(String(key: "classifieds.comparator.button")) { _ in
            
            RU_Classified.compare()
        })
        return $0
        
    }(RU_Tip_StackView())
	private lazy var tableView:RU_TableView = {
		
        $0.allowsMultipleSelectionDuringEditing = true
		$0.register(RU_Classified_TableViewCell.self, forCellReuseIdentifier: RU_Classified_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
    private lazy var addButton:RU_Button = {
        
        $0.image = UIImage(systemName: "plus.circle")
        return $0
        
    }(RU_Button(String(key: "classifieds.create.button")) { _ in
        
        UI.MainController.present(RU_NavigationController(rootViewController: RU_Classifieds_Create_Name_ViewController()), animated: true)
    })
    private lazy var deleteButton:RU_Button = {
        
        $0.isHidden = true
        $0.image = UIImage(systemName: "trash")
        $0.type = .delete
        return $0
        
    }(RU_Button(String(key: "classifieds.delete.button")) { [weak self] _ in
        
        let alertController:RU_Alert_ViewController = .init()
        alertController.title = String(key: "classifieds.delete.alert.title")
        alertController.add(String(key: "classifieds.delete.alert.content"))
        let button = alertController.addButton(title: String(key: "classifieds.delete.alert.button")) { [weak self] button in
            
            button?.isLoading = true
            
            let dispatchGroup = DispatchGroup()
            
            self?.tableView.indexPathsForSelectedRows?.forEach({
                
                dispatchGroup.enter()
                
                self?.classifieds?[$0.row].delete { _ in
                    
                    dispatchGroup.leave()
                }
            })
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                
                button?.isLoading = false
                
                alertController.close()
                
                self?.setEditing(false, animated: true)
                
                self?.updateClassifieds()
            }
        }
        button.type = .delete
        button.image = UIImage(systemName: "trash")
        alertController.addCancelButton()
        alertController.present()
    })
	
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
        
        let stackView:RU_StackView = .init(arrangedSubviews: [comparatorTipView,tableView])
        stackView.axis = .vertical
        stackView.spacing = UI.Margins
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        let buttonsStackView:RU_StackView = .init(arrangedSubviews: [addButton,deleteButton])
        buttonsStackView.axis = .vertical
        view.addSubview(buttonsStackView)
        buttonsStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(1.5 * UI.Margins)
        }
		
		NotificationCenter.add(.updateClassifieds, { [weak self] _ in
			
			self?.updateClassifieds()
		})
		
		updateClassifieds()
	}
    
    public override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        
        view.layoutIfNeeded()
        
        let bottomInset = addButton.bounds.height + 2 * UI.Margins
        tableView.contentInset.bottom = bottomInset
        tableView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    public override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
        updateSelection()
        
        UIView.animation {
            
            self.deleteButton.isHidden = !editing
            self.deleteButton.alpha = self.deleteButton.isHidden ? 0 : 1
            
            self.addButton.isHidden = editing
            self.addButton.alpha = self.addButton.isHidden ? 0 : 1
        }
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
    
    private func updateSelection() {
        
        deleteButton.isEnabled = !(tableView.indexPathsForSelectedRows?.isEmpty ?? true)
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
		
		if !tableView.isEditing {
         
            tableView.deselectRow(at: indexPath, animated: true)
            
            let viewController:RU_Classifieds_Detail_ViewController = .init()
            viewController.classified = classifieds?[indexPath.row]
            navigationController?.pushViewController(viewController, animated: true)
        }
        else {
            
            updateSelection()
        }
	}
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing {
            
            updateSelection()
        }
    }
	
	public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
        if !tableView.isEditing {
            
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
		
		let cell = tableView.cellForRow(at: indexPath) as? RU_Classified_TableViewCell
		return cell?.trailingSwipeActionsConfiguration
	}
}
