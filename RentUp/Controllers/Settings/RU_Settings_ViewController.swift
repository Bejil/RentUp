//
//  RU_Settings_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_Settings_ViewController: RU_ViewController {
	
	private lazy var platformsTableView:RU_TableView = {
		
		$0.isHeightDynamic = true
		$0.register(RU_Platform_TableViewCell.self, forCellReuseIdentifier: RU_Platform_TableViewCell.identifier)
		$0.delegate = self
		$0.dataSource = self
		return $0
		
	}(RU_TableView(frame: .zero, style: .plain))
	
	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.settings"), image: UIImage(systemName: "slider.horizontal.3"), tag: RU_TabBarController.Indexes.allCases.firstIndex(of: .Settings) ?? 0)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "settings.title")
		
		let contentScrollView:RU_ScrollView = .init()
		contentScrollView.isCentered = false
		
		let contentStackView:RU_StackView = .init()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(UI.Margins)
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			make.right.width.equalToSuperview()
		}
		
		contentView.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let platformsSectionTitleStackView:RU_Section_StackView = .init()
		platformsSectionTitleStackView.title = String(key: "settings.platforms.section.title")
		platformsSectionTitleStackView.subtitle = String(key: "settings.platforms.section.subtitle")
		platformsSectionTitleStackView.addArrangedSubview(platformsTableView)
		contentStackView.addArrangedSubview(platformsSectionTitleStackView)
		
		// MARK: - About Section
		let aboutSectionStackView:RU_Section_StackView = .init()
		aboutSectionStackView.title = String(key: "settings.about.section.title")
		aboutSectionStackView.subtitle = String(key: "settings.about.section.subtitle")
		
		let versionLabel:RU_Label = .init()
		versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		let versionRow:RU_Section_Row_StackView = .init()
		versionRow.image = UIImage(systemName: "info.circle.fill")
		versionRow.title = String(key: "settings.about.version")
		versionRow.view = versionLabel
		aboutSectionStackView.addArrangedSubview(versionRow)
		contentStackView.addArrangedSubview(aboutSectionStackView)
		
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
		contentStackView.addArrangedSubview(resetButton)
		
		NotificationCenter.add(.updatePlatforms) { [weak self] _ in
			
			self?.platformsTableView.reloadData()
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
		
		return RU_Platform.all?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: RU_Platform_TableViewCell.identifier, for: indexPath) as! RU_Platform_TableViewCell
		cell.platform = RU_Platform.all?[indexPath.row]
		cell.detailsLabel.text = RU_Platform.all?[indexPath.row].detail
		return cell
	}
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let viewController:RU_Settings_Platform_ViewController = .init()
		viewController.platform = RU_Platform.all?[indexPath.row]
		navigationController?.pushViewController(viewController, animated: true)
	}
}

