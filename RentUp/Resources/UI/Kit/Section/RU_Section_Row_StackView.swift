//
//  RU_Section_Row_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 23/01/2026.
//

import UIKit
import SnapKit

public class RU_Section_Row_StackView : RU_StackView {
	
	public var image:UIImage? {
		
		didSet {
			
			imageView.isHidden = image == nil
			imageView.image = image
		}
	}
	private lazy var imageView:RU_Section_ImageView = .init(image: image)
	public var title:String? {
		
		didSet {
			
			titleLabel.isHidden = title == nil
			titleLabel.text = title
		}
	}
	private lazy var titleLabel:RU_Label = {
		
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		$0.font = isHighlighted ? Fonts.Content.Title.H4 : Fonts.Content.Text.Regular
		return $0
		
	}(RU_Label())
	public var view:UIView? {
		
		didSet {
			
			if let view {
				
				addArrangedSubview(view)
			}
		}
	}
	public var isHighlighted:Bool = false {
		
		didSet {
			
			if isHighlighted {
				
				removeLines()
			}
			
			titleLabel.font = isHighlighted ? Fonts.Content.Title.H4 : Fonts.Content.Text.Regular
			
			if let label = view as? RU_Label {
				
				label.textAlignment = .right
				
				if isHighlighted {
					
					label.font = Fonts.Content.Title.H4
					label.textColor = Colors.Primary
				}
				else {
					
					label.font = Fonts.Content.Text.Bold
				}
			}
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		axis = .horizontal
		spacing = UI.Margins
		alignment = .center
		isLayoutMarginsRelativeArrangement = true
		layoutMargins.top = UI.Margins/2
		layoutMargins.bottom = UI.Margins
		addLine(position: .bottom)
		addArrangedSubview(imageView)
		addArrangedSubview(titleLabel)
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
