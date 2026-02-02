//
//  RU_Platform_TableViewCell.swift
//  RentUp
//
//  Created by BLIN Michael on 22/01/2026.
//

import UIKit
import SnapKit

public class RU_Platform_TableViewCell : RU_TableViewCell {
	
	public override class var identifier: String {
		
		return "platformTableViewCellIdentifier"
	}
	public var platform:RU_Platform? {
		
		didSet {
			
			platformLabel.platform = platform
		}
	}
	private lazy var platformLabel:RU_Platform_Label = .init()
	public lazy var detailsLabel:RU_Label = .init()
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		accessoryType = .disclosureIndicator
		
		let stackView:RU_StackView = .init(arrangedSubviews: [platformLabel,detailsLabel])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .center
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
	}
	
	@MainActor required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
