//
//  RU_SegmentedControl.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_SegmentedControl: UISegmentedControl {
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		setUp()
	}
	
	public override init(items: [Any]?) {
		
		super.init(items: items)
		
		setUp()
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setUp() {
		
		apportionsSegmentWidthsByContent = true
		selectedSegmentTintColor = Colors.SegmentedControl.Background.Selected
		backgroundColor = Colors.SegmentedControl.Background.Default
		setTitleTextAttributes([.foregroundColor: Colors.SegmentedControl.Text.Default, .font: Fonts.SegmentedControl.Default], for:.normal)
		setTitleTextAttributes([.foregroundColor: Colors.SegmentedControl.Text.Selected, .font: Fonts.SegmentedControl.Selected], for:.selected)
		snp.makeConstraints { make in
			make.height.equalTo(3 * UI.Margins)
		}
	}
}
