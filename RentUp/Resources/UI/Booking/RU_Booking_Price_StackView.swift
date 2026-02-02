//
//  RU_Booking_Price_StackView.swift
//  RentUp
//
//  Created by BLIN Michael on 29/01/2026.
//

import UIKit
import SnapKit

public class RU_Booking_Price_View : UIView {
	
	private lazy var borderShapeLayer:CAShapeLayer = {
		
		$0.strokeColor = Colors.Background.View.cgColor
		$0.lineWidth = 5
		$0.lineDashPattern = [5, 4]
		return $0
		
	}(CAShapeLayer())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		layer.shadowOffset = .zero
		layer.shadowOpacity = 0.5
		layer.shadowRadius = UI.Margins/3
		layer.shadowColor = Colors.Content.Text.cgColor
		backgroundColor = Colors.Background.View
		layer.addSublayer(borderShapeLayer)
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: 0))
		path.addLine(to: CGPoint(x: bounds.size.width, y: 0))
		path.move(to: CGPoint(x: 0, y: bounds.size.height))
		path.addLine(to: CGPoint(x: bounds.size.width, y: bounds.size.height))
		
		borderShapeLayer.path = path.cgPath
	}
}
