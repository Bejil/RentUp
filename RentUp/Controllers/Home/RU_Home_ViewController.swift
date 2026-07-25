//
//  RU_Home_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_Home_ViewController: RU_ViewController {
    
    private let reportingAlertLastShownMonthKey = "home.reporting.alert.lastShownMonth"
	
	private var bookings: [RU_Booking]? {
		
		didSet {
			
			view.dismissPlaceholder()
			
            nextBookingSectionStackView.booking = bookings?.next
			currentStayStickyView.booking = bookings?.current
			monthProgressView.update(bookings: bookings)
			
            if (bookings?.isEmpty ?? true) {
				
                let placeholderView = view.showPlaceholder(.Empty)
                let button = placeholderView.addButton(String(key: "bookings.create.button")) { _ in
                    
                    RU_Booking.create()
                }
                button.image = UIImage(systemName: "plus")
			}
            
            navigationItem.leftBarButtonItem = nil
            
            if !(bookings?.isEmpty ?? true) && RU_Booking.shouldPresentReporting {
                
                reportingTipStackView.isHidden = false
                reportingTipStackView.bookings = bookings
                
                let alertController:RU_Reporting_Alert_ViewController = .init()
                alertController.bookings = bookings
                alertController.present()
            }
		}
	}
	private lazy var monthProgressView: RU_Home_MonthProgress_View = .init()
	private lazy var nextBookingSectionStackView: RU_Booking_Card_Section_StackView = {
		
		$0.title = String(key: "home.nextBooking.section.title")
		return $0
		
	}(RU_Booking_Card_Section_StackView())
	private lazy var contentScrollView = RU_ScrollView()
	private lazy var contentStackView: RU_StackView = {
		let stack = RU_StackView(arrangedSubviews: [
			reportingTipStackView,
			promoTipStackView,
			monthProgressView,
			nextBookingSectionStackView
		])
		stack.axis = .vertical
		stack.spacing = 2 * UI.Margins
		stack.isLayoutMarginsRelativeArrangement = true
		return stack
	}()
	private lazy var currentStayStickyView: RU_Home_CurrentStay_StickyView = {
		$0.onVisibilityChange = { [weak self] _ in
			self?.updateCurrentStayInset()
		}
		return $0
	}(RU_Home_CurrentStay_StickyView())
    private lazy var reportingTipStackView:RU_Reporting_Tip_StackView = {
        
        $0.isHidden = true
        return $0
        
    }(RU_Reporting_Tip_StackView())
	private lazy var promoTipStackView: RU_Tip_StackView = {
        
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
		
		updateAdaptiveLayoutMargins()
		RU_AdaptiveLayout.installScrollContent(
			scrollView: contentScrollView,
			contentView: contentStackView,
			in: view,
			traitCollection: traitCollection
		)
		
		view.addSubview(currentStayStickyView)
		currentStayStickyView.snp.makeConstraints { make in
			make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
		
		NotificationCenter.add(.updateBookings) { [weak self] _ in
			
			self?.updateBookings()
		}
	}
	
	public override func viewDidLoad() {
		
		super.viewDidLoad()
		
		registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (self: Self, previousTraitCollection: UITraitCollection) in
			
			guard self.traitCollection.horizontalSizeClass != previousTraitCollection.horizontalSizeClass else { return }
			self.updateAdaptiveLayoutMargins()
		}
	}
	
	private func updateAdaptiveLayoutMargins() {
		let margins = UI.adaptiveMargins(for: traitCollection)
		contentStackView.layoutMargins = UIEdgeInsets(top: margins, left: margins, bottom: margins, right: margins)
		updateCurrentStayInset()
	}
	
	func handleTabReselect() {
		currentStayStickyView.restoreAfterDismiss()
	}
	
	private func updateCurrentStayInset() {
		view.layoutIfNeeded()
		
		let stickyVisible = currentStayStickyView.booking != nil && !currentStayStickyView.isHidden
		let stickyHeight = stickyVisible ? currentStayStickyView.bounds.height : 0
		let bottomInset = stickyVisible ? stickyHeight + 2 * UI.Margins : 0
		
		contentScrollView.contentInset.bottom = bottomInset
		contentScrollView.verticalScrollIndicatorInsets.bottom = bottomInset
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
			promoTipStackView.addLabel(String(key: "home.tip.promo.message"))
			
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
            
			let label = promoTipStackView.addLabel(dateRangeText + ":\n" + String(key: opportunity.name))
            label.set(font: Fonts.Content.Text.Bold, string: dateRangeText + ":")
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
