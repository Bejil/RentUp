//
//  RU_Booking_Status_Label.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit
import SnapKit

public class RU_Booking_Status_Label : RU_Label {
	
	public var booking:RU_Booking? {
		
		didSet {
			
			guard let booking else { return }
			
			backgroundColor = booking.status.backgroundColor
			textColor = booking.status.textColor
			
			let calendar = Calendar.current
			let today = calendar.startOfDay(for: Date())
			
			switch booking.status {
				
			case .upcoming:
				let startDay = calendar.startOfDay(for: booking.dates.start)
				let days = calendar.dateComponents([.day], from: today, to: startDay).day ?? 0
				if days == 1 {
					text = String(key: "booking.status.upcoming.tomorrow")
				} else {
					text = "\(booking.status.text) ➜ \(days) j"
				}
				
			case .current:
				let endDay = calendar.startOfDay(for: booking.dates.end)
				let days = calendar.dateComponents([.day], from: today, to: endDay).day ?? 0
				if days == 0 {
					text = String(key: "booking.status.departure.today")
				} else if days == 1 {
					text = String(key: "booking.status.departure.tomorrow")
				} else {
					text = "\(booking.status.text) ➜ \(days) j"
				}
				
			default:
				text = booking.status.text
			}
		}
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		font = Fonts.Content.Text.Bold.withSize(Fonts.Size-2)
		textAlignment = .center
		numberOfLines = 1
		contentInsets = .init(horizontal: UI.Margins/3, vertical: UI.Margins/7)
		layer.cornerRadius = UI.Margins/2
		setContentHuggingPriority(.required, for: .horizontal)
		setContentCompressionResistancePriority(.required, for: .horizontal)
	}
	
	@MainActor required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
