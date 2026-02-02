//
//  RU_Section_StepperRow_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 24/01/2026.
//

import UIKit

public class RU_Section_StepperRow_StackView : RU_Section_Row_StackView {
	
	public var value:String? {
		
		didSet {
			
			valueLabel.text = value
		}
	}
	private lazy var valueLabel:RU_Label = {
		
		$0.font = Fonts.Content.Text.Bold
		$0.textAlignment = .right
		return $0
		
	}(RU_Label())
	public lazy var stepper:RU_Stepper = {
		
		$0.addAction(.init(handler: { [weak self] _ in
			
			if let self {
				
				self.value = "\(Int(self.stepper.value))"
			}
		}), for: .valueChanged)
		return $0
		
	}(RU_Stepper())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		let textFieldStackView:RU_StackView = .init(arrangedSubviews: [valueLabel,stepper])
		textFieldStackView.axis = .horizontal
		textFieldStackView.spacing = UI.Margins
		textFieldStackView.alignment = .center
		view = textFieldStackView
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
