//
//  RU_Section_TimeRow_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 25/07/2026.
//

import UIKit
import SnapKit

public class RU_Section_TimeRow_StackView : RU_Section_Row_StackView {
	
	public lazy var datePicker:RU_DatePicker = {
		
		$0.datePickerMode = .time
		$0.minuteInterval = 15
		$0.locale = Locale(identifier: "fr_FR")
		return $0
		
	}(RU_DatePicker())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		view = datePicker
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func set(hour: Int, minute: Int) {
		
		var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
		components.hour = hour
		components.minute = minute
		components.second = 0
		datePicker.date = Calendar.current.date(from: components) ?? Date()
	}
	
	public var hour: Int {
		
		Calendar.current.component(.hour, from: datePicker.date)
	}
	
	public var minute: Int {
		
		Calendar.current.component(.minute, from: datePicker.date)
	}
}
