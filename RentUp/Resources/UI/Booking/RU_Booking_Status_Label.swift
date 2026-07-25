//
//  RU_Booking_Status_Label.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit
import SnapKit

public class RU_Booking_Status_Label : UIView {
	
	public var booking:RU_Booking? {
		
		didSet {
			
			guard let booking else { return }
			
			backgroundColor = booking.status.backgroundColor
			textLabel.textColor = booking.status.textColor
			
			let calendar = Calendar.current
			let today = calendar.startOfDay(for: Date())
			
			switch booking.status {
				
			case .upcoming:
				let startDay = calendar.startOfDay(for: booking.stayCheckInDate)
				let days = calendar.dateComponents([.day], from: today, to: startDay).day ?? 0
				if days == 0 {
					textLabel.text = String(key: "booking.status.arrival.today")
				} else if days == 1 {
					textLabel.text = String(key: "booking.status.upcoming.tomorrow")
				} else {
					textLabel.text = "\(booking.status.text) ➜ \(days) j"
				}
				
			case .current:
				let endDay = calendar.startOfDay(for: booking.stayCheckOutDate)
				let days = calendar.dateComponents([.day], from: today, to: endDay).day ?? 0
				if days == 0 {
					textLabel.text = String(key: "booking.status.departure.today")
				} else if days == 1 {
					textLabel.text = String(key: "booking.status.departure.tomorrow")
				} else {
					textLabel.text = "\(booking.status.text) ➜ \(days) j"
				}
				
			default:
				textLabel.text = booking.status.text
			}
		}
	}
	
	private lazy var textLabel: RU_Label = {
		
		$0.font = UI.Badge.font
		$0.textAlignment = .center
		$0.numberOfLines = 1
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		return $0
		
	}(RU_Label())
	
	private lazy var contentStackView: RU_StackView = {
		
		$0.axis = .horizontal
		$0.alignment = .center
		$0.isLayoutMarginsRelativeArrangement = true
		$0.insetsLayoutMarginsFromSafeArea = false
		$0.layoutMargins = UI.Badge.contentInsets
		$0.addArrangedSubview(textLabel)
		return $0
		
	}(RU_StackView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		layer.masksToBounds = true
		layer.cornerRadius = UI.Badge.cornerRadius
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.required, for: .horizontal)
		addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		snp.makeConstraints { make in
			make.height.equalTo(UI.Badge.height)
		}
	}
	
	@MainActor required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
