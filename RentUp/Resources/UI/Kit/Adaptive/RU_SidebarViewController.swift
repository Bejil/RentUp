//
//  RU_SidebarViewController.swift
//  RentUp
//

import UIKit
import SnapKit

protocol RU_SidebarViewControllerDelegate: AnyObject {
	func sidebarViewController(_ controller: RU_SidebarViewController, didSelect section: RU_TabBarController.Indexes)
}

final class RU_SidebarViewController: RU_ViewController {
	
	weak var delegate: RU_SidebarViewControllerDelegate?
	
	private var selectedSection: RU_TabBarController.Indexes = .Home
	private var badgeSections = Set<RU_TabBarController.Indexes>()
	
	private lazy var headerStackView: RU_StackView = {
		let iconView = UIImageView(image: UIImage(systemName: "building.2.fill"))
		iconView.tintColor = Colors.Primary
		iconView.contentMode = .scaleAspectFit
		iconView.snp.makeConstraints { make in
			make.size.equalTo(44)
		}
		
		let titleLabel = RU_Label()
		titleLabel.text = "BienGéré"
		titleLabel.font = Fonts.Content.Title.H2
		
		let stack = RU_StackView(arrangedSubviews: [iconView, titleLabel])
		stack.axis = .horizontal
		stack.spacing = UI.Margins
		stack.alignment = .center
		return stack
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.rowHeight = 52
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SidebarCell")
		return tableView
	}()
	
	override func loadView() {
		super.loadView()
		
		navigationItem.title = ""
		navigationItem.hidesBackButton = true
		navigationController?.navigationBar.prefersLargeTitles = false
		
		let containerStack = RU_StackView(arrangedSubviews: [headerStackView, tableView])
		containerStack.axis = .vertical
		containerStack.spacing = 2 * UI.Margins
		containerStack.isLayoutMarginsRelativeArrangement = true
		containerStack.layoutMargins = UIEdgeInsets(
			top: UI.adaptiveMargins(for: traitCollection),
			left: UI.adaptiveMargins(for: traitCollection),
			bottom: UI.adaptiveMargins(for: traitCollection),
			right: UI.adaptiveMargins(for: traitCollection)
		)
		
		view.addSubview(containerStack)
		containerStack.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	func selectSection(_ section: RU_TabBarController.Indexes, animated: Bool = false) {
		selectedSection = section
		tableView.reloadData()
		if let index = RU_TabBarController.Indexes.allCases.firstIndex(of: section) {
			let indexPath = IndexPath(row: index, section: 0)
			tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
		}
	}
	
	func updateBadges(_ sections: Set<RU_TabBarController.Indexes>) {
		badgeSections = sections
		tableView.reloadData()
	}
	
	private func section(for indexPath: IndexPath) -> RU_TabBarController.Indexes {
		RU_TabBarController.Indexes.allCases[indexPath.row]
	}
}

extension RU_SidebarViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		RU_TabBarController.Indexes.allCases.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SidebarCell", for: indexPath)
		let section = section(for: indexPath)
		var content = cell.defaultContentConfiguration()
		content.text = section.title
		content.image = UIImage(systemName: section.symbolName)
		cell.contentConfiguration = content
		cell.accessoryType = badgeSections.contains(section) ? .none : .none
		cell.selectionStyle = .default
		
		if badgeSections.contains(section) {
			let badgeLabel = UILabel()
			badgeLabel.text = "!"
			badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
			badgeLabel.textColor = .white
			badgeLabel.backgroundColor = Colors.TabBar.Badge
			badgeLabel.textAlignment = .center
			badgeLabel.layer.cornerRadius = 9
			badgeLabel.clipsToBounds = true
			badgeLabel.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
			cell.accessoryView = badgeLabel
		} else {
			cell.accessoryView = nil
		}
		
		cell.backgroundColor = section == selectedSection ? Colors.Primary.withAlphaComponent(0.08) : .clear
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let section = section(for: indexPath)
		selectedSection = section
		RU_Feedback.shared.make(.On)
		delegate?.sidebarViewController(self, didSelect: section)
		tableView.reloadData()
	}
}
