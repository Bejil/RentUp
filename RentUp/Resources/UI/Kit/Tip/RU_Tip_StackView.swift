//
//  RU_Tip.swift
//  RentUp
//
//  Created by BLIN Michael on 22/01/2026.
//

import UIKit
import SnapKit

public class RU_Tip_StackView: RU_StackView {
	
	public var icon:UIImage? {
		
		didSet {
			
			iconImageView.isHidden = icon == nil
			iconImageView.image = icon
		}
	}
	public var title:String? {
		
		didSet {
			
			titleLabel.isHidden = title == nil
			titleLabel.text = title
		}
	}
	private lazy var iconImageView:UIImageView = {
		
		$0.tintColor = Colors.Tip.Icon
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.size.equalTo(2*UI.Margins)
		}
		return $0
		
	}(UIImageView(image: UIImage(systemName: "lightbulb.circle.fill")))
	private lazy var titleLabel:RU_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(RU_Label())
	private lazy var contentStackView:RU_StackView = {
		
		$0.isHidden = true
		$0.axis = .vertical
		$0.spacing = UI.Margins/3
		return $0
		
	}(RU_StackView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins/2
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(UI.Margins)
		layer.cornerRadius = UI.CornerRadius
		backgroundColor = Colors.Tip.Background
		
		let stackView = RU_StackView(arrangedSubviews: [iconImageView,titleLabel])
		stackView.axis = .horizontal
		stackView.spacing = UI.Margins
		stackView.alignment = .center
		addArrangedSubview(stackView)
		
		addArrangedSubview(contentStackView)
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func add(_ view:UIView) {
		
		contentStackView.addArrangedSubview(view)
		updateContent()
	}
	
	public func add(_ string:String) {
		
		contentStackView.addArrangedSubview(RU_Label(string))
		updateContent()
	}
	
	private func updateContent() {
		
		contentStackView.isHidden = contentStackView.arrangedSubviews.isEmpty
	}
}
