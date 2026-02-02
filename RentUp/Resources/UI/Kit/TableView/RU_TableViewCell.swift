//
//  RU_TableViewCell.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit
import SnapKit

public class RU_TableViewCell: UITableViewCell {
	
	public class var identifier: String {
		
		return "tableViewCellIdentifier"
	}
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		tintColor = Colors.TableView.Tint
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		separatorInset = .zero
		
		selectionStyle = .default
		selectedBackgroundView = .init()
		selectedBackgroundView?.backgroundColor = Colors.Background.View
		
		let view:UIView = .init()
		view.backgroundColor = Colors.TableView.Tint.withAlphaComponent(0.1)
		selectedBackgroundView?.addSubview(view)
		view.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		textLabel?.numberOfLines = 0
		textLabel?.textColor = Colors.Content.Text
		textLabel?.font = Fonts.Content.Text.Bold
		
		detailTextLabel?.numberOfLines = 0
		detailTextLabel?.textColor = Colors.Content.Text
		detailTextLabel?.font = Fonts.Content.Text.Regular
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}
	
	public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		
		super.setHighlighted(highlighted, animated: animated)
		
		if !isEditing && selectionStyle != .none {
			
			UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut,.allowUserInteraction], animations: {
				
				self.transform = highlighted ? .init(scaleX: 0.95, y: 0.95) : .identity
				
			}, completion: nil)
		}
	}
}
