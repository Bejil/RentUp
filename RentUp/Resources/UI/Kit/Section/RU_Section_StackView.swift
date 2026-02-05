//
//  RU_Section_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 22/01/2026.
//

import UIKit
import SnapKit

public class RU_Section_StackView : RU_StackView {
	
	public var title:String? {
		
		didSet {
			
			titleLabel.text = title
			titleLabel.isHidden = title?.isEmpty ?? true
		}
	}
	public var subtitle:String? {
		
		didSet {
			
			subtitleLabel.text = subtitle
			subtitleLabel.isHidden = subtitle?.isEmpty ?? true
		}
	}
	private lazy var titleLabel:RU_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Title.H3
		return $0
		
	}(RU_Label())
	private lazy var subtitleLabel:RU_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Text.Regular
		$0.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		return $0
		
	}(RU_Label())
	public var accessoryView:UIView? {
		
		didSet {
			
			if let oldValue {
				
				oldValue.removeFromSuperview()
			}
			
			if let accessoryView {
				
				headerStackView.addArrangedSubview(accessoryView)
			}
		}
	}
	private lazy var headerStackView:RU_StackView = {
		
		$0.axis = .horizontal
		$0.spacing = UI.Margins
		$0.alignment = .center
		
		let textStackView:RU_StackView = .init(arrangedSubviews: [titleLabel,subtitleLabel])
		textStackView.axis = .vertical
		textStackView.spacing = UI.Margins/2
		$0.addArrangedSubview(textStackView)
		
		return $0
		
	}(RU_StackView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins/2
		addArrangedSubview(headerStackView)
		setCustomSpacing(UI.Margins, after: headerStackView)
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
