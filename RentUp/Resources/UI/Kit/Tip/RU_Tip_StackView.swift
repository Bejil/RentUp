//
//  RU_Tip.swift
//  RentUp
//
//  Created by BLIN Michael on 22/01/2026.
//

import UIKit
import SnapKit

public class RU_Tip_StackView: RU_StackView {
	
	public var isMinimized:Bool = false {
		
		didSet {
			
			titleStackView.isHidden = isMinimized
			iconContentImageView.isHidden = !isMinimized
		}
	}
	public var icon:UIImage? {
		
		didSet {
			
			iconTitleImageView.isHidden = icon == nil
			iconTitleImageView.image = icon
			
			iconContentImageView.isHidden = !isMinimized || icon == nil
			iconContentImageView.image = icon
		}
	}
	public var title:String? {
		
		didSet {
			
			titleLabel.isHidden = title == nil
			titleLabel.text = title
		}
	}
	private lazy var iconTitleImageView: UIImageView = {
		$0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		$0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		$0.snp.makeConstraints { make in
			make.size.equalTo(2 * UI.Margins).priority(.high)
		}
		return $0
	}(createImageView())
	private lazy var iconContentImageView: UIImageView = {
		$0.isHidden = true
		$0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		$0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		$0.snp.makeConstraints { make in
			make.size.equalTo(1.25 * UI.Margins).priority(.high)
		}
		return $0
	}(createImageView())
	private lazy var titleLabel:RU_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(RU_Label())
	private lazy var titleStackView:RU_StackView = {
		
		$0.isHidden = false
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.alignment = .center
		return $0
		
	}(RU_StackView(arrangedSubviews: [iconTitleImageView,titleLabel]))
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
		
		addArrangedSubview(titleStackView)
		
		let contentContainerStackView = RU_StackView(arrangedSubviews: [iconContentImageView,contentStackView])
		contentContainerStackView.axis = .horizontal
		contentContainerStackView.spacing = UI.Margins/2
		contentContainerStackView.alignment = .top
		addArrangedSubview(contentContainerStackView)
		
		contentStackView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(iconContentImageView).priority(.high)
		}
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func reset() {
		
		contentStackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
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
	
	public func createImageView() -> UIImageView {
		
		let imageView:UIImageView = .init(image: UIImage(systemName: "info.circle.fill"))
		imageView.tintColor = Colors.Tip.Icon
		imageView.contentMode = .scaleAspectFit
		return imageView
	}
}
