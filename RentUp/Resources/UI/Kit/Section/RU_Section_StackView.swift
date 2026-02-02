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
			
			updateUI()
		}
	}
	public var subtitle:String? {
		
		didSet {
			
			subtitleLabel.text = subtitle
			subtitleLabel.isHidden = subtitle?.isEmpty ?? true
			
			updateUI()
		}
	}
	private lazy var titleLabel:RU_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Title.H4
		return $0
		
	}(RU_Label())
	private lazy var subtitleLabel:RU_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Text.Regular
		$0.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		return $0
		
	}(RU_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins/2
		addArrangedSubview(titleLabel)
		addArrangedSubview(subtitleLabel)
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func updateUI() {
		
		if subtitleLabel.isHidden {
			
			setCustomSpacing(UI.Margins, after: titleLabel)
		}
		else {
			
			setCustomSpacing(UI.Margins/2, after: titleLabel)
			setCustomSpacing(UI.Margins, after: subtitleLabel)
		}
	}
}
