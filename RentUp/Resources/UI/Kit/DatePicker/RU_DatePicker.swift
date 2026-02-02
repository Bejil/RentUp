//
//  RU_DatePicker.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit

public class RU_DatePicker : UIDatePicker {
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		datePickerMode = .date
		preferredDatePickerStyle = .compact
		tintColor = Colors.DatePicker.TintColor
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
