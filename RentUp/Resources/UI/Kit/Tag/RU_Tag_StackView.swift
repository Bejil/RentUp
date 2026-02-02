//
//  RU_Tag_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 28/01/2026.
//

import UIKit
import SnapKit

public class RU_Tag_StackView : RU_StackView {
	
	public var image:UIImage? {
		
		didSet {
			
			imageView.isHidden = image == nil
			imageView.image = image
		}
	}
	private lazy var imageView:UIImageView = {
		
		$0.isHidden = true
		$0.tintColor = Colors.Content.Text
		$0.contentMode = .scaleAspectFit
		$0.snp.makeConstraints { make in
			make.size.equalTo(UI.Margins)
		}
		return $0
		
	}(UIImageView())
	public var text:String? {
		
		didSet {
			
			label.isHidden = text == nil
			label.text = text
		}
	}
	private lazy var label:RU_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-3)
		$0.numberOfLines = 1
		return $0
		
	}(RU_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		spacing = UI.Margins/2
		alignment = .center
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(horizontal: UI.Margins/3, vertical: UI.Margins/7)
		backgroundColor = Colors.Content.Text.withAlphaComponent(0.05)
		layer.cornerRadius = UI.Margins/2
		clipsToBounds = true
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.required, for: .horizontal)
		addArrangedSubview(imageView)
		addArrangedSubview(label)
	}
	
	@MainActor required init(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
