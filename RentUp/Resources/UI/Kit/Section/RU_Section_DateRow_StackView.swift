//
//  RU_Section_DateRow_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 26/01/2026.
//

import UIKit
import SnapKit

public class RU_Section_DateRow_StackView : RU_Section_Row_StackView {
	
	public lazy var datePicker:RU_DatePicker = .init()
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		view = datePicker
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
