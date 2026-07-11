//
//  RU_Bookings_Detail_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 23/01/2026.
//

import UIKit
import SnapKit

public class RU_Bookings_Detail_ViewController : RU_ViewController {
    
	public var booking:RU_Booking? {
		
		didSet {
            
            title = booking?.classified?.name ?? String(key: "bookings.details.title")
			
			platformLabel.platform = booking?.platform
			statusLabel.booking = booking
			
			// Dates
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .long
			dateFormatter.locale = Locale(identifier: "fr_FR")
			
			if let startDate = booking?.dates.start {
				
				let startDateString = dateFormatter.string(from: startDate)
				datesStartValueLabel.text = startDateString
			}
			
			if let endDate = booking?.dates.end {
				
				let endDateString = dateFormatter.string(from: endDate)
				datesEndValueLabel.text = endDateString
			}
			
			if let startDate = booking?.dates.start, let endDate = booking?.dates.end, let nights = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day {
				
				let nightsString = nights > 1 ? String(key: "bookings.details.nights") : String(key: "bookings.details.night")
				nightsValueLabel.text = "\(nights) \(nightsString)"
			}
			
			commentTipStackView.reset()
			
			if let comment = booking?.comment, !comment.isEmpty {
				
				commentTipStackView.isHidden = false
				commentTipStackView.addLabel(comment)
			}
			else {
				
				commentTipStackView.isHidden = true
			}
			
			if let adults = booking?.travelers.adults {
				
				adultsValueLabel.text = "\(adults)"
			}
			
			if let children = booking?.travelers.children {
				
				childrenValueLabel.text = "\(children)"
			}
			else {
				
				childrenSectionRowStackView.isHidden = true
			}
			
			if let babies = booking?.travelers.babies {
				
				babiesValueLabel.text = "\(babies)"
			}
			else {
				
				babiesSectionRowStackView.isHidden = true
			}
			
			if let doubles = booking?.beds.doubles, doubles > 0 {
				
				doubleBedsValueLabel.text = "\(doubles)"
				doubleBedsSectionRowStackView.isHidden = false
			}
			else {
				
				doubleBedsSectionRowStackView.isHidden = true
			}
			
			if let singles = booking?.beds.singles, singles > 0 {
				
				singleBedsValueLabel.text = "\(singles)"
				singleBedsSectionRowStackView.isHidden = false
			}
			else {
				
				singleBedsSectionRowStackView.isHidden = true
			}
			
			if let babies = booking?.beds.babies, babies > 0 {
				
				babyBedsValueLabel.text = "\(babies)"
				babyBedsSectionRowStackView.isHidden = false
			}
			else {
				
				babyBedsSectionRowStackView.isHidden = true
			}
			
			let hasAnyBed = (booking?.beds.doubles ?? 0) > 0 || (booking?.beds.singles ?? 0) > 0 || (booking?.beds.babies ?? 0) > 0
			configurationSectionStackView.isHidden = !hasAnyBed
			
			if let booking, let calculation = booking.platform?.calculatePrice(for: booking) {
				
				travelerSectionTitleStackView.subtitle = booking.platform?.type?.priceFormulaTraveler
				travelerNightsValueLabel.text = String(format: "%.2f €", calculation.totalNights + calculation.discount)
				
				travelerDiscountSectionRowStackView.isHidden = calculation.discount == 0
				travelerDiscountValueLabel.text = String(format: "-%.2f € (%.0f%%)", calculation.discount, calculation.discountPercent)
				
				travelerCleaningSectionRowStackView.isHidden = calculation.cleaning == 0
				travelerCleaningValueLabel.text = String(format: "%.2f €", calculation.cleaning)
				
				travelerFeesSectionRowStackView.isHidden = calculation.travelerFees == 0
				travelerFeesValueLabel.text = String(format: "%.2f €", calculation.travelerFees)
				
				travelerTouristTaxValueLabel.text = String(format: "%.2f €", calculation.touristTax)
				travelerTotalValueLabel.text = String(format: "%.2f €", calculation.travelerTotal)
				
				hostSectionTitleStackView.subtitle = booking.platform?.type?.priceFormulaHost
				hostNightsValueLabel.text = String(format: "%.2f €", calculation.totalNights + calculation.discount)
				
				hostDiscountSectionRowStackView.isHidden = calculation.discount == 0
				hostDiscountValueLabel.text = String(format: "-%.2f € (%.0f%%)", calculation.discount, calculation.discountPercent)
				
				hostCleaningSectionRowStackView.isHidden = calculation.cleaning == 0
				hostCleaningValueLabel.text = String(format: "%.2f €", calculation.cleaning)
				
				hostFeesValueLabel.text = String(format: "%.2f €", calculation.hostFees)
                
                hostCostsCleaningSectionRowStackView.isHidden = calculation.hostCleaningCost == 0
                hostCostsCleaningValueLabel.text = String(format: "%.2f €", calculation.hostCleaningCost)
                
                hostCostsCompensationSectionRowStackView.isHidden = calculation.hostCompensationCost == 0
                hostCostsCompensationValueLabel.text = String(format: "%.2f €", calculation.hostCompensationCost)
                
				hostTotalValueLabel.text = String(format: "%.2f €", calculation.hostTotal)
				
				// Masquer les sections si pas de calcul possible
				travelerSectionTitleStackView.isHidden = false
				hostSectionTitleStackView.isHidden = false
			}
			else {
				
				travelerSectionTitleStackView.isHidden = true
				hostSectionTitleStackView.isHidden = true
			}
            
            let isCancelled = booking?.isCancelled ?? false
            cancelButton.title = String(key: isCancelled ? "bookings.details.approve.button" : "bookings.details.cancel.button")
            cancelButton.type = isCancelled ? .primary : .delete
            cancelButton.image = UIImage(systemName: isCancelled ? "checkmark" : "xmark")
		}
	}
	private lazy var childrenSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "figure.child", title: String(key: "bookings.create.travelers.children"), view: childrenValueLabel)
	private lazy var babiesSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "stroller.fill", title: String(key: "bookings.create.travelers.babies"), view: babiesValueLabel)
	private lazy var statusLabel:RU_Booking_Status_Label = .init()
	private lazy var configurationSectionStackView:RU_Section_StackView = {
		
		$0.title = String(key: "bookings.details.configuration.section.title")
		$0.addArrangedSubview(doubleBedsSectionRowStackView)
		$0.addArrangedSubview(singleBedsSectionRowStackView)
		$0.addArrangedSubview(babyBedsSectionRowStackView)
		return $0
		
	}(RU_Section_StackView())
	private lazy var doubleBedsValueLabel:RU_Label = .init()
	private lazy var doubleBedsSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "bed.double.fill", title: String(key: "bookings.details.configuration.beds.double"), view: doubleBedsValueLabel)
	private lazy var singleBedsValueLabel:RU_Label = .init()
	private lazy var singleBedsSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "bed.double", title: String(key: "bookings.details.configuration.beds.single"), view: singleBedsValueLabel)
	private lazy var babyBedsValueLabel:RU_Label = .init()
	private lazy var babyBedsSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "stroller", title: String(key: "bookings.details.configuration.beds.baby"), view: babyBedsValueLabel)
	private lazy var platformLabel:RU_Platform_Label = .init()
	private lazy var datesStartValueLabel:RU_Label = .init()
	private lazy var datesEndValueLabel:RU_Label = .init()
	private lazy var nightsValueLabel:RU_Label = .init()
	private lazy var commentTipStackView:RU_Tip_StackView = {
		
		$0.title = String(key: "bookings.details.comment.title")
		return $0
		
	}(RU_Tip_StackView())
	private lazy var adultsValueLabel:RU_Label = .init()
	private lazy var childrenValueLabel:RU_Label = .init()
	private lazy var babiesValueLabel:RU_Label = .init()
	private lazy var pricesStackView:RU_StackView = {
		
		$0.axis = .vertical
		$0.spacing = 2*UI.Margins
		return $0
		
	}(RU_StackView(arrangedSubviews: [travelerSectionTitleStackView,hostSectionTitleStackView]))
	private lazy var travelerSectionTitleStackView:RU_Section_StackView = {
		
		let backgroundView:RU_Booking_Price_View = .init()
		$0.insertSubview(backgroundView, at: 0)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(2*UI.Margins)
		$0.layoutMargins.bottom = UI.Margins
		$0.title = String(key: "bookings.details.travelerPrice.section.title")
		$0.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "bookings.details.price.nights"), view: travelerNightsValueLabel))
		$0.addArrangedSubview(travelerDiscountSectionRowStackView)
		$0.addArrangedSubview(travelerCleaningSectionRowStackView)
		$0.addArrangedSubview(travelerFeesSectionRowStackView)
		$0.addArrangedSubview(createRow(icon: "building.columns.fill", title: String(key: "bookings.details.price.touristTax"), view: travelerTouristTaxValueLabel))
		$0.addArrangedSubview(createRow(icon: "equal.circle.fill", title: String(key: "bookings.details.price.travelerTotal"), view: travelerTotalValueLabel, isHighlighted: true))
		
		return $0
		
	}(RU_Section_StackView())
	private lazy var travelerNightsValueLabel:RU_Label = .init()
	private lazy var travelerDiscountSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "percent", title: String(key: "bookings.details.price.discount"), view: travelerDiscountValueLabel)
	private lazy var travelerDiscountValueLabel:RU_Label = .init()
	private lazy var travelerCleaningSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "sparkles", title: String(key: "bookings.details.price.cleaning"), view: travelerCleaningValueLabel)
	private lazy var travelerCleaningValueLabel:RU_Label = .init()
	private lazy var travelerFeesSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "plus", title: String(key: "bookings.details.price.travelerFees"), view: travelerFeesValueLabel)
	private lazy var travelerFeesValueLabel:RU_Label = .init()
	private lazy var travelerTouristTaxValueLabel:RU_Label = .init()
	private lazy var travelerTotalValueLabel:RU_Label = .init()
	private lazy var hostSectionTitleStackView:RU_Section_StackView = {
		
		let backgroundView:RU_Booking_Price_View = .init()
		$0.insertSubview(backgroundView, at: 0)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(2*UI.Margins)
		$0.layoutMargins.bottom = UI.Margins
		$0.title = String(key: "bookings.details.hostRevenue.section.title")
		$0.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "bookings.details.price.nights"), view: hostNightsValueLabel))
		$0.addArrangedSubview(hostDiscountSectionRowStackView)
		$0.addArrangedSubview(hostCleaningSectionRowStackView)
		$0.addArrangedSubview(createRow(icon: "minus", title: String(key: "bookings.details.price.hostFees"), view: hostFeesValueLabel))
        $0.addArrangedSubview(hostCostsCleaningSectionRowStackView)
        $0.addArrangedSubview(hostCostsCompensationSectionRowStackView)
		$0.addArrangedSubview(createRow(icon: "equal.circle.fill", title: String(key: "bookings.details.price.hostTotal"), view: hostTotalValueLabel, isHighlighted: true))
		
		return $0
		
	}(RU_Section_StackView())
	private lazy var hostNightsValueLabel:RU_Label = .init()
	private lazy var hostDiscountSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "percent", title: String(key: "bookings.details.price.discount"), view: hostDiscountValueLabel)
	private lazy var hostDiscountValueLabel:RU_Label = .init()
	private lazy var hostCleaningSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "sparkles", title: String(key: "bookings.details.price.cleaning"), view: hostCleaningValueLabel)
	private lazy var hostCleaningValueLabel:RU_Label = .init()
	private lazy var hostFeesValueLabel:RU_Label = .init()
    private lazy var hostCostsCleaningSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "sparkles", title: String(key: "bookings.details.price.costs.cleaning"), view: hostCostsCleaningValueLabel)
    private lazy var hostCostsCleaningValueLabel:RU_Label = .init()
    private lazy var hostCostsCompensationSectionRowStackView:RU_Section_Row_StackView = createRow(icon: "hand.wave", title: String(key: "bookings.details.price.costs.compensation"), view: hostCostsCompensationValueLabel)
    private lazy var hostCostsCompensationValueLabel:RU_Label = .init()
	private lazy var hostTotalValueLabel:RU_Label = .init()
    private lazy var cancelButton:RU_Button = .init() { [weak self] _ in
        
        guard let self, let booking = self.booking else { return }
        
        RU_Booking.handleCancellationToggle(for: booking, markingAsCancelled: !booking.isCancelled) { [weak self] error in
            
            if let error {
                RU_Alert_ViewController.present(error)
            } else {
                self?.booking = booking
            }
        }
    }
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
        
        navigationItem.rightBarButtonItem = .init(title: String(key: "bookings.details.edit.button"), primaryAction: .init(handler: { [weak self] _ in
            
            let viewController:RU_Bookings_Edit_ViewController = .init()
            viewController.booking = self?.booking
            UI.MainController.present(RU_NavigationController(rootViewController: viewController), animated: true)
        }))
		
		let contentScrollView:RU_ScrollView = .init()
		
		let contentStackView:RU_StackView = .init()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(UI.Margins)
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
		}
		
		view.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let datesSectionTitleStackView:RU_Section_StackView = .init()
		datesSectionTitleStackView.title = String(key: "bookings.details.dates.section.title")
		let platformStackView:RU_StackView = .init(arrangedSubviews: [.init(),platformLabel])
		platformStackView.axis = .horizontal
		let statusStackView:RU_StackView = .init(arrangedSubviews: [.init(),statusLabel])
		statusStackView.axis = .horizontal
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "checkmark.circle.fill", title: String(key: "bookings.details.status"), view: statusStackView))
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "app.badge.fill", title: String(key: "bookings.details.platform"), view: platformStackView))
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "airplane.arrival", title: String(key: "bookings.details.dates.start"), view: datesStartValueLabel))
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "airplane.departure", title: String(key: "bookings.details.dates.end"), view: datesEndValueLabel))
		datesSectionTitleStackView.addArrangedSubview(createRow(icon: "moon.fill", title: String(key: "bookings.details.nights.label"), view: nightsValueLabel))
		contentStackView.addArrangedSubview(datesSectionTitleStackView)
		
		contentStackView.addArrangedSubview(commentTipStackView)
		
		let travelersSectionTitleStackView:RU_Section_StackView = .init()
		travelersSectionTitleStackView.title = String(key: "bookings.details.travelers.section.title")
		travelersSectionTitleStackView.addArrangedSubview(createRow(icon: "person.fill", title: String(key: "bookings.create.travelers.adults"), view: adultsValueLabel))
		travelersSectionTitleStackView.addArrangedSubview(childrenSectionRowStackView)
		travelersSectionTitleStackView.addArrangedSubview(babiesSectionRowStackView)
		contentStackView.addArrangedSubview(travelersSectionTitleStackView)
		
		contentStackView.addArrangedSubview(configurationSectionStackView)
		contentStackView.addArrangedSubview(pricesStackView)
        contentStackView.addArrangedSubview(cancelButton)
        
        NotificationCenter.add(.updateBookings) { [weak self] _ in
            
            RU_Booking.getAll { [weak self] error, bookings in
               
                if let booking = bookings?.first(where: { $0.uuid == self?.booking?.uuid }) {
                    
                    self?.booking = booking
                }
                else {
                    
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
	}
	
	private func createRow(icon: String, title: String, view: UIView, isHighlighted: Bool = false) -> RU_Section_Row_StackView {
		
		let stackView:RU_Section_Row_StackView = .init()
		stackView.image = UIImage(systemName: icon)
		stackView.title = title
		stackView.view = view
		stackView.isHighlighted = isHighlighted
		return stackView
	}
}
