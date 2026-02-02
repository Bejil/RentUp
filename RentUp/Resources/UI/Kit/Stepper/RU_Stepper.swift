//
//  RU_Stepper.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit

public class RU_Stepper : UIStepper {
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		tintColor = Colors.Stepper.TintColor
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
