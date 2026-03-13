//
//  RU_Classified_TableViewCell.swift
//  RentUp
//
//  Created by BLIN Michael on 26/01/2026.
//

import UIKit
import SnapKit

public class RU_Classified_TableViewCell : RU_TableViewCell {
	
	public override class var identifier: String {
		
		return "classifiedTableViewCellIdentifier"
	}
	public var deleteHandler:((RU_Classified?)->Void)?
	public var editHandler:((RU_Classified?)->Void)?
	public var classified:RU_Classified? {
		
		didSet {
			
			nameLabel.text = classified?.name
			
			var details:[String] = []
			
			if let capacity = classified?.configuration.capacity, capacity > 0 {
				
				details.append(String(format: String(key: "settings.classified.cell.capacity"), capacity))
			}
			
			if let doubles = classified?.configuration.beds.doubles, doubles > 0 {
				
				let key = doubles > 1 ? "settings.classified.cell.beds.doubles" : "settings.classified.cell.beds.double"
				details.append(String(format: String(key: key), doubles))
			}
			
			if let singles = classified?.configuration.beds.singles, singles > 0 {
				
				let key = singles > 1 ? "settings.classified.cell.beds.singles" : "settings.classified.cell.beds.single"
				details.append(String(format: String(key: key), singles))
			}
			
			if let babies = classified?.configuration.beds.babies, babies > 0 {
				
				let key = babies > 1 ? "settings.classified.cell.beds.babies" : "settings.classified.cell.beds.baby"
				details.append(String(format: String(key: key), babies))
			}
			
			detailsLabel.text = details.joined(separator: " • ")
            
            platformsStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
            
            classified?.tarification.forEach({
                
                let platformLabel:RU_Platform_Label = .init()
                platformLabel.platform = $0.platform
                platformsStackView.addArrangedSubview(platformLabel)
            })
		}
	}
	private lazy var nameLabel:RU_Label = {
		
		$0.font = Fonts.Content.Title.H3
		return $0
		
	}(RU_Label())
	private lazy var detailsLabel:RU_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(RU_Label())
    private lazy var platformsStackView:RU_StackView = {
        
        $0.axis = .horizontal
        $0.spacing = UI.Margins/2
        $0.alignment = .center
        return $0
        
    }(RU_StackView())
	public var menu:UIMenu? {
		
		get{
			
			return .init(children: [
				
				UIAction(title: String(key: "settings.classified.cell.edit.button"), image: UIImage(systemName: "slider.horizontal.3"), handler: { [weak self] _ in
					
					self?.editHandler?(self?.classified)
				}),
				UIAction(title: String(key: "settings.classified.cell.delete.button"), image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
					
					self?.deleteHandler?(self?.classified)
				})
			])
		}
	}
	public var trailingSwipeActionsConfiguration:UISwipeActionsConfiguration {
		
		get{
			
			var actionsArray:[UIContextualAction] = .init()
			
			let deleteContextualAction:UIContextualAction = .init(style: .destructive, title: String(key: "settings.classified.cell.delete.button")) { [weak self] _, _, completion in
				
				self?.deleteHandler?(self?.classified)
				completion(true)
			}
			deleteContextualAction.image = UIImage(systemName: "trash")
			deleteContextualAction.backgroundColor = Colors.Button.Delete.Background
			actionsArray.append(deleteContextualAction)
			
			let editContextualAction:UIContextualAction = .init(style: .normal, title: String(key: "settings.classified.cell.edit.button")) { [weak self] _, _, completion in
				
				self?.editHandler?(self?.classified)
				completion(true)
			}
			editContextualAction.image = UIImage(systemName: "slider.horizontal.3")
			editContextualAction.backgroundColor = Colors.Primary
			actionsArray.append(editContextualAction)
			
			let actionsConfiguration:UISwipeActionsConfiguration = .init(actions: actionsArray)
			actionsConfiguration.performsFirstActionWithFullSwipe = true
			
			return actionsConfiguration
		}
	}
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		accessoryType = .disclosureIndicator
        
        let platformsContainerStackView:RU_StackView = .init(arrangedSubviews: [platformsStackView])
        platformsContainerStackView.axis = .vertical
        platformsContainerStackView.alignment = .leading
		
		let stackView:RU_StackView = .init(arrangedSubviews: [nameLabel,detailsLabel,platformsContainerStackView])
		stackView.axis = .vertical
		stackView.spacing = UI.Margins/2
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}
}
