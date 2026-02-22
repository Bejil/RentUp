//
//  RU_Home_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_Home_ViewController: RU_ViewController {
	
	private var bookings: [RU_Booking]? {
		
		didSet {
			
			view.dismissPlaceholder()
			
            currentBookingSectionStackView.booking = bookings?.current
            nextBookingSectionStackView.booking = bookings?.next
			
            if currentBookingSectionStackView.isHidden && nextBookingSectionStackView.isHidden {
				
                view.showPlaceholder(.Empty)
			}
		}
	}
	private lazy var currentBookingSectionStackView: RU_Booking_Card_Section_StackView = {
		
		$0.title = String(key: "home.currentBooking.section.title")
		return $0
		
	}(RU_Booking_Card_Section_StackView())
	private lazy var nextBookingSectionStackView: RU_Booking_Card_Section_StackView = {
		
		$0.title = String(key: "home.nextBooking.section.title")
		return $0
		
	}(RU_Booking_Card_Section_StackView())
	private lazy var promoTipStackView: RU_Tip_StackView = {
        
		$0.icon = UIImage(systemName: "tag.fill")
        $0.title = String(key: "home.tip.promo.title")
		return $0
        
	}(RU_Tip_StackView())

	public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		
		tabBarItem = .init(title: String(key: "tabbar.home"), image: UIImage(systemName: "flame"), tag: RU_TabBarController.Indexes.allCases.firstIndex(of: .Home) ?? 0)
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		
		super.loadView()
		
		navigationItem.title = String(key: "home.title")
		
        let contentScrollView:RU_ScrollView = .init()
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let contentStackView: RU_StackView = .init(arrangedSubviews: [promoTipStackView, currentBookingSectionStackView, nextBookingSectionStackView])
        contentStackView.axis = .vertical
        contentStackView.spacing = 2 * UI.Margins
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = .init(UI.Margins)
        contentScrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(contentScrollView.snp.width)
        }
		
		NotificationCenter.add(.updateBookings) { [weak self] _ in
			
			self?.updateBookings()
		}
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		
		updateBookings()
		updatePromoTip()
	}
	
	private func updatePromoTip() {
        
		promoTipStackView.reset()
        
		if let opportunity = Date().nextUpcomingHolidayOpportunity(withinDays: 60) {
            
			promoTipStackView.isHidden = false
			promoTipStackView.add(String(key: "home.tip.promo.message"))
			
            let formatter = DateFormatter()
			formatter.locale = Locale(identifier: "fr_FR")
			formatter.dateStyle = .long
			
            let startString = formatter.string(from: opportunity.startDate)
			let endString = formatter.string(from: opportunity.endDate)
			let dateRangeText: String
			
            if Calendar.current.isDate(opportunity.startDate, inSameDayAs: opportunity.endDate) {
                
				dateRangeText = startString
			}
            else {
                
				dateRangeText = String(format: String(key: "home.tip.promo.dates.range"), startString, endString)
			}
            
            let label:RU_Label = .init(dateRangeText + ":\n" + String(key: opportunity.name))
            label.set(font: Fonts.Content.Text.Bold, string: dateRangeText + ":")
			promoTipStackView.add(label)
		}
        else {
            
			promoTipStackView.isHidden = true
		}
	}
	
	private func updateBookings() {
		
        view.showPlaceholder(.Loading)
			
		RU_Booking.getAll { [weak self] error, bookings in
			
			self?.view.dismissPlaceholder()
				
			if let error {
				
				self?.view.showPlaceholder(.Error, error) { [weak self] _ in
					
					self?.view.dismissPlaceholder()
					
					self?.updateBookings()
				}
			}
			else {
				
				self?.bookings = bookings
			}
		}
	}
}
