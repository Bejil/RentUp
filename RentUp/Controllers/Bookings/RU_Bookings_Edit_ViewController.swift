//
//  RU_Bookings_Edit_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class RU_Bookings_Edit_ViewController : RU_ViewController {
	
	public var booking:RU_Booking? = .init() {
		
		didSet {
			
			updateClassified()
			
			if let platform = booking?.platform, let index = RU_Platform.all?.firstIndex(of: platform) {
				
				platformSegmentedControl.selectedSegmentIndex = index
				platformSegmentedControl.sendActions(for: .valueChanged)
			}
			
			updateDatesButton()
			
			if let value = booking?.travelers.adults {
				
				adultsRow.stepper.value = Double(value)
				adultsRow.stepper.sendActions(for: .valueChanged)
			}
			
			if let value = booking?.travelers.children {
				
				childrenRow.stepper.value = Double(value)
				childrenRow.stepper.sendActions(for: .valueChanged)
			}
			
			if let value = booking?.travelers.babies {
				
				babiesRow.stepper.value = Double(value)
				babiesRow.stepper.sendActions(for: .valueChanged)
			}
			
			if let value = booking?.beds.doubles {
				
				doubleBedsRow.stepper.value = Double(value)
				doubleBedsRow.stepper.sendActions(for: .valueChanged)
			}
			
			if let value = booking?.beds.singles {
				
				singleBedsRow.stepper.value = Double(value)
				singleBedsRow.stepper.sendActions(for: .valueChanged)
			}
			
			if let value = booking?.beds.babies {
				
				babyBedsRow.stepper.value = Double(value)
				babyBedsRow.stepper.sendActions(for: .valueChanged)
			}
			
			commentTextField.text = booking?.comment
			
			deleteButton.isHidden = false
			
			updateSaveButton()
		}
	}
	private lazy var classifiedButton:RU_Button = {
		
		$0.showsMenuAsPrimaryAction = true
		$0.type = .secondary
		$0.titleFont = Fonts.Content.Text.Regular
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		$0.image = UIImage(systemName: "arrowtriangle.down.square.fill")?.applyingSymbolConfiguration(.init(scale: .small))
		$0.configuration?.imagePlacement = .trailing
		$0.configuration?.imagePadding = UI.Margins/2
		return $0
		
	}(RU_Button(String(key: "bookings.create.classified.button")))
	private lazy var platformSegmentedControl:RU_Platform_SegmentedControl = {
		
		$0.addAction(.init(handler: { [weak self] _ in
			
			if let index = self?.platformSegmentedControl.selectedSegmentIndex {
				
				self?.booking?.platform = RU_Platform.all?[index]
				self?.updateSaveButton()
			}
			
		}), for: .valueChanged)
		return $0
		
	}(RU_Platform_SegmentedControl())
	private lazy var datesButton:RU_Button = {
		
		$0.type = .secondary
		$0.titleFont = Fonts.Content.Text.Regular
		$0.setContentHuggingPriority(.required, for: .horizontal)
		$0.setContentCompressionResistancePriority(.required, for: .horizontal)
		$0.image = UIImage(systemName: "arrowtriangle.down.square.fill")?.applyingSymbolConfiguration(.init(scale: .small))
		$0.configuration?.imagePlacement = .trailing
		$0.configuration?.imagePadding = UI.Margins/2
		return $0
		
	}(RU_Button(String(key: "bookings.create.dates.button")) { [weak self] button in
		
		button?.isLoading = true
		
		RU_Booking.getAll { [weak self] error, bookings in
			
			button?.isLoading = false
			
			if let error {
				
				RU_Alert_ViewController.present(error)
			}
			else {
				
				let calendarViewController = RU_Calendar_ViewController()
				calendarViewController.startDate = self?.booking?.dates.start
				calendarViewController.endDate = self?.booking?.dates.end
				calendarViewController.existingBookings = bookings
				calendarViewController.currentBooking = self?.booking
				calendarViewController.didSelectRange = { [weak self] startDate, endDate in
					
					self?.booking?.dates.start = startDate
					self?.booking?.dates.end = endDate
					self?.updateDatesButton()
					self?.updateSaveButton()
				}
				
				UI.MainController.present(RU_NavigationController(rootViewController: calendarViewController), animated: true)
			}
		}
	})
	private lazy var adultsRow:RU_Section_StepperRow_StackView = {
		
		$0.image = UIImage(systemName: "person.fill")
		$0.title = String(key: "bookings.create.travelers.adults")
		$0.stepper.minimumValue = 0.0
		$0.stepper.addAction(.init(handler: { [weak self] _ in
			
			guard let self = self else { return }
			
			let newValue = Int(self.adultsRow.stepper.value)
			let previousValue = self.booking?.travelers.adults ?? 0
			
			if self.wouldExceedCapacity(adults: newValue) {
				self.adultsRow.value = String(previousValue)
				self.showCapacityError()
			} else {
				self.booking?.travelers.adults = newValue
				self.updateSaveButton()
			}
			
		}), for: .valueChanged)
		return $0
		
	}(RU_Section_StepperRow_StackView())
	private lazy var childrenRow:RU_Section_StepperRow_StackView = {
		
		$0.image = UIImage(systemName: "figure.child")
		$0.title = String(key: "bookings.create.travelers.children")
		$0.stepper.minimumValue = 0.0
		$0.stepper.addAction(.init(handler: { [weak self] _ in
			
			guard let self = self else { return }
			
			let newValue = Int(self.childrenRow.stepper.value)
			let previousValue = self.booking?.travelers.children ?? 0
			
			if self.wouldExceedCapacity(children: newValue) {
				self.childrenRow.value = String(previousValue)
				self.showCapacityError()
			} else {
				self.booking?.travelers.children = newValue
				self.updateSaveButton()
			}
			
		}), for: .valueChanged)
		return $0
		
	}(RU_Section_StepperRow_StackView())
	private lazy var babiesRow:RU_Section_StepperRow_StackView = {
		
		$0.image = UIImage(systemName: "stroller.fill")
		$0.title = String(key: "bookings.create.travelers.babies")
		$0.stepper.minimumValue = 0.0
		$0.stepper.addAction(.init(handler: { [weak self] _ in
			
			guard let self = self else { return }
			
			let newValue = Int(self.babiesRow.stepper.value)
			let previousValue = self.booking?.travelers.babies ?? 0
			
			if self.wouldExceedCapacity(babies: newValue) {
				self.babiesRow.value = String(previousValue)
				self.showCapacityError()
			} else {
				self.booking?.travelers.babies = newValue
				self.updateSaveButton()
			}
			
		}), for: .valueChanged)
		return $0
		
	}(RU_Section_StepperRow_StackView())
	private lazy var doubleBedsRow:RU_Section_StepperRow_StackView = {
		
		$0.image = UIImage(systemName: "bed.double.fill")
		$0.title = String(key: "bookings.create.configuration.section.beds.double")
		$0.stepper.minimumValue = 0.0
		$0.stepper.addAction(.init(handler: { [weak self] _ in
			
			if let value = self?.doubleBedsRow.stepper.value {
				
				self?.booking?.beds.doubles = Int(value)
				self?.updateSaveButton()
			}
			
		}), for: .valueChanged)
		return $0
		
	}(RU_Section_StepperRow_StackView())
	private lazy var singleBedsRow:RU_Section_StepperRow_StackView = {
		
		$0.image = UIImage(systemName: "bed.double")
		$0.title = String(key: "bookings.create.configuration.section.beds.simple")
		$0.stepper.minimumValue = 0.0
		$0.stepper.addAction(.init(handler: { [weak self] _ in
			
			if let value = self?.singleBedsRow.stepper.value {
				
				self?.booking?.beds.singles = Int(value)
				self?.updateSaveButton()
			}
			
		}), for: .valueChanged)
		return $0
		
	}(RU_Section_StepperRow_StackView())
	private lazy var babyBedsRow:RU_Section_StepperRow_StackView = {
		
		$0.image = UIImage(systemName: "stroller")
		$0.title = String(key: "bookings.create.configuration.section.beds.baby")
		$0.stepper.minimumValue = 0.0
		$0.stepper.addAction(.init(handler: { [weak self] _ in
			
			if let value = self?.babyBedsRow.stepper.value {
				
				self?.booking?.beds.babies = Int(value)
				self?.updateSaveButton()
			}
			
		}), for: .valueChanged)
		return $0
		
	}(RU_Section_StepperRow_StackView())
	private lazy var commentTextField:RU_TextView = .init()
	private lazy var deleteButton:RU_Button = {
		
		$0.isHidden = true
		$0.type = .delete
		$0.image = UIImage(systemName: "trash")
		return $0
		
	}(RU_Button(String(key: "bookings.create.delete.button")){ [weak self] button in
		
		let alertController:RU_Booking_Delete_Alert_ViewController = .init()
		alertController.booking = self?.booking
		alertController.deleteCompletion = { [weak self] in
			
			self?.dismiss()
		}
		alertController.present()
	})
	private lazy var saveButton:RU_Button = {
		
		$0.isEnabled = false
		$0.image = UIImage(systemName: "square.and.arrow.down")
		return $0
		
	}(RU_Button(String(key: "bookings.create.save.button")) { [weak self] button in
		
		button?.isLoading = true
		
		self?.booking?.comment = self?.commentTextField.text
		
		self?.booking?.save { [weak self] error in
			
			button?.isLoading = false
			
			if let error {
				
				RU_Alert_ViewController.present(error)
			}
			else {
				
				NotificationCenter.post(.updateBookings)
				
				self?.dismiss()
			}
		}
	})
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
		title = String(key: booking == nil ? "bookings.create.title.new" : "bookings.create.title.update")
		
		let contentScrollView:RU_ScrollView = .init()
		contentScrollView.isCentered = false
		
		let contentStackView:RU_StackView = .init()
		contentStackView.axis = .vertical
		contentStackView.spacing = 2*UI.Margins
		contentStackView.isLayoutMarginsRelativeArrangement = true
		contentStackView.layoutMargins = .init(UI.Margins)
		contentScrollView.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.top.bottom.left.equalToSuperview()
			make.right.width.equalToSuperview()
		}
		
		contentView.addSubview(contentScrollView)
		contentScrollView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		
		let classifiedSectionTitleStackView:RU_Section_StackView = .init()
		classifiedSectionTitleStackView.title = String(key: "bookings.create.classified.section.title")
		classifiedSectionTitleStackView.subtitle = String(key: "bookings.create.classified.section.subtitle")
		classifiedSectionTitleStackView.accessoryView = classifiedButton
		classifiedButton.snp.remakeConstraints { make in
			make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
		}
		contentStackView.addArrangedSubview(classifiedSectionTitleStackView)
		
		let platformsSectionTitleStackView:RU_Section_StackView = .init()
		platformsSectionTitleStackView.title = String(key: "bookings.create.platform.section.title")
		platformsSectionTitleStackView.subtitle = String(key: "bookings.create.platform.section.subtitle")
		platformsSectionTitleStackView.addArrangedSubview(platformSegmentedControl)
		contentStackView.addArrangedSubview(platformsSectionTitleStackView)
		
		let datesSectionTitleStackView:RU_Section_StackView = .init()
		datesSectionTitleStackView.title = String(key: "bookings.create.dates.section.title")
		datesSectionTitleStackView.subtitle = String(key: "bookings.create.dates.section.subtitle")
		datesSectionTitleStackView.accessoryView = datesButton
		datesButton.snp.remakeConstraints { make in
			make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
		}
		contentStackView.addArrangedSubview(datesSectionTitleStackView)
		
		let travelersSectionTitleStackView:RU_Section_StackView = .init()
		travelersSectionTitleStackView.title = String(key: "bookings.create.travelers.section.title")
		travelersSectionTitleStackView.subtitle = String(key: "bookings.create.travelers.section.subtitle")
		travelersSectionTitleStackView.addArrangedSubview(adultsRow)
		travelersSectionTitleStackView.addArrangedSubview(childrenRow)
		travelersSectionTitleStackView.addArrangedSubview(babiesRow)
		contentStackView.addArrangedSubview(travelersSectionTitleStackView)
		
		let configurationSectionTitleStackView:RU_Section_StackView = .init()
		configurationSectionTitleStackView.title = String(key: "bookings.create.configuration.section.title")
		configurationSectionTitleStackView.subtitle = String(key: "bookings.create.configuration.section.subtitle")
		configurationSectionTitleStackView.addArrangedSubview(doubleBedsRow)
		configurationSectionTitleStackView.addArrangedSubview(singleBedsRow)
		configurationSectionTitleStackView.addArrangedSubview(babyBedsRow)
		contentStackView.addArrangedSubview(configurationSectionTitleStackView)
		
		let commentSectionTitleStackView:RU_Section_StackView = .init()
		commentSectionTitleStackView.title = String(key: "bookings.create.comment.section.title")
		commentSectionTitleStackView.subtitle = String(key: "bookings.create.comment.section.subtitle")
		commentSectionTitleStackView.addArrangedSubview(commentTextField)
		contentStackView.addArrangedSubview(commentSectionTitleStackView)
		
		contentStackView.addArrangedSubview(deleteButton)
		
		bottomButtonsStackView.addArrangedSubview(saveButton)
		
		getClassifieds()
	}
	
	private func getClassifieds() {
		
		classifiedButton.isLoading = true
		
		RU_Classified.getAll { [weak self] error, classifieds in
			
			self?.classifiedButton.isLoading = false
			
			if let error {
				
				RU_Alert_ViewController.present(error) { [weak self] in
					
					self?.getClassifieds()
				}
			}
			else {
				
				self?.classifiedButton.menu = .init(title: String(key: ""), children: classifieds?.compactMap({ [weak self] classified in
					
					return UIAction(title: classified.name ?? "", handler: { [weak self] _ in
						
						self?.booking?.classified = classified
						
						self?.adultsRow.value = String(0)
						self?.adultsRow.stepper.sendActions(for: .valueChanged)
						
						self?.childrenRow.value = String(0)
						self?.childrenRow.stepper.sendActions(for: .valueChanged)
						
						self?.babiesRow.value = String(0)
						self?.babiesRow.stepper.sendActions(for: .valueChanged)
						
						self?.doubleBedsRow.isHidden = classified.configuration.beds.doubles ?? 0 == 0
						self?.doubleBedsRow.value = String(0)
						self?.doubleBedsRow.stepper.sendActions(for: .valueChanged)
						
						self?.singleBedsRow.isHidden = classified.configuration.beds.singles ?? 0 == 0
						self?.singleBedsRow.value = String(0)
						self?.singleBedsRow.stepper.sendActions(for: .valueChanged)
						
						self?.babyBedsRow.isHidden = classified.configuration.beds.babies ?? 0 == 0
						self?.babyBedsRow.value = String(0)
						self?.babyBedsRow.stepper.sendActions(for: .valueChanged)
						
						self?.updateClassified()
					})
					
				}) ?? .init())
			}
		}
	}
	
	private func updateClassified() {
		
		classifiedButton.title = booking?.classified?.name
		
		if classifiedButton.superview != nil {
			
			classifiedButton.snp.remakeConstraints { make in
				make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
			}
		}
		
		platformSegmentedControl.classified = booking?.classified
		
		if let value = booking?.classified?.configuration.beds.doubles {
			
			doubleBedsRow.stepper.maximumValue = Double(value)
		}
		
		if let value = booking?.beds.doubles {
			
			doubleBedsRow.stepper.value = Double(value)
			doubleBedsRow.stepper.sendActions(for: .valueChanged)
		}
		
		if let value = booking?.classified?.configuration.beds.singles {
			
			singleBedsRow.stepper.maximumValue = Double(value)
		}
		
		if let value = booking?.beds.singles {
			
			singleBedsRow.stepper.value = Double(value)
			singleBedsRow.stepper.sendActions(for: .valueChanged)
		}
		
		if let value = booking?.classified?.configuration.beds.babies {
			
			babyBedsRow.stepper.maximumValue = Double(value)
		}
	}
	
	private func updateSaveButton() {
		
		saveButton.isEnabled = booking?.canSave ?? false
	}
	
	private func wouldExceedCapacity(adults: Int? = nil, children: Int? = nil, babies: Int? = nil) -> Bool {
		
		if let capacity = booking?.classified?.configuration.capacity {
			
			let totalAdults = adults ?? (booking?.travelers.adults ?? 0)
			let totalChildren = children ?? (booking?.travelers.children ?? 0)
			let totalBabies = babies ?? (booking?.travelers.babies ?? 0)
			
			let totalTravelers = totalAdults + totalChildren + totalBabies
			
			return totalTravelers > capacity
		}
		
		return false
	}
	
	private func showCapacityError() {
		
		if let capacity = booking?.classified?.configuration.capacity {
			
			RU_Alert_ViewController.present(RU_Error(String(format: String(key: "bookings.create.capacity.error"), capacity)))
		}
	}
	
	private func updateDatesButton() {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.locale = Locale(identifier: "fr_FR")
		
		if let startDate = booking?.dates.start, let endDate = booking?.dates.end {
			
			let startString = dateFormatter.string(from: startDate)
			let endString = dateFormatter.string(from: endDate)
			
			let calendar = Calendar.current
			let nights = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
			let nightsString = nights > 1 ? String(key: "bookings.details.nights") : String(key: "bookings.details.night")
			
			datesButton.title = "\(startString) ➜ \(endString) • \(nights) \(nightsString)"
		}
		else {
			
			datesButton.title = nil
		}
		
		if datesButton.superview != nil {
			
			datesButton.snp.remakeConstraints { make in
				make.width.lessThanOrEqualToSuperview().multipliedBy(0.5)
			}
		}
	}
	
}
