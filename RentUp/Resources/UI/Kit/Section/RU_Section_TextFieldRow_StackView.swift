//
//  RU_Section_TextFieldRow_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 24/01/2026.
//

import UIKit

public class RU_Section_TextFieldRow_StackView : RU_Section_Row_StackView {
	
	public lazy var textField:RU_Section_TextField = {
		
		$0.placeholder = String(key: "section.textField.placeholder")
		$0.addAction(.init(handler: { [weak self] _ in
			
			if let textField = self?.textField {
				
				textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
			}
			
		}), for: .editingDidBegin)
		return $0
		
	}(RU_Section_TextField())
	public var suffix:String? {
		
		didSet {
			
			suffixLabel.isHidden = suffix?.isEmpty ?? true
			suffixLabel.text = suffix
		}
	}
	private lazy var suffixLabel:RU_Label = {
		
		$0.isHidden = true
		$0.font = Fonts.Content.Text.Bold
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		return $0
		
	}(RU_Label())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		let textFieldStackView:RU_StackView = .init(arrangedSubviews: [textField,suffixLabel])
		textFieldStackView.axis = .horizontal
		textFieldStackView.spacing = UI.Margins
		textFieldStackView.alignment = .center
		view = textFieldStackView
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
