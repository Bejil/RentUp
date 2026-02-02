//
//  RU_Section_TextField.swift
//  RentUp
//
//  Created by BLIN Michael on 24/01/2026.
//

import UIKit

public class RU_Section_TextField : RU_TextField {
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		textAlignment = .right
		inset = .zero
		font = Fonts.Content.Title.H4
		textColor = Colors.TextField.TintColor
		layer.cornerRadius = 0
		layer.borderWidth = 0
		keyboardType = .decimalPad
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
