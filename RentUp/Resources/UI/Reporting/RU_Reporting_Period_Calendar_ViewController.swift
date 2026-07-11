//
//  RU_Reporting_Period_Calendar_ViewController.swift
//  RentUp
//

import UIKit
import SnapKit

public class RU_Reporting_Period_Calendar_ViewController: RU_Bookings_Calendar_ViewController {
	
	public var didSelectRange: ((Date, Date) -> Void)?
	
	private let presetFrom: Date
	private let presetTo: Date
	private var selectedStartDate: Date?
	private var hasAppliedPresetRange = false
	
	internal override var calendarSupportsLazyForwardLoading: Bool { true }
	
	public init(from: Date, to: Date) {
		self.presetFrom = from
		self.presetTo = to
		super.init(nibName: nil, bundle: nil)
	}
	
	@MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private lazy var validateButton: RU_Button = {
		$0.image = UIImage(systemName: "checkmark")
		return $0
	}(RU_Button(String(key: "reporting.period.alert.confirm")) { [weak self] _ in
		guard let self, let range = self.secondaryHighlightRanges?.first else { return }
		let start = self.normalizedCalendarDay(range.lowerBound)
		let end = self.normalizedCalendarDay(range.upperBound)
		self.didSelectRange?(start, end)
		self.close()
	})
	
	public override func loadView() {
		super.loadView()
		
		isModal = true
		navigationItem.title = String(key: "reporting.period.alert.title")
		navigationItem.largeTitleDisplayMode = .always
		
		view.addSubview(validateButton)
		validateButton.snp.makeConstraints { make in
			make.right.bottom.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
		}
	}
	
	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let bottomInset = validateButton.bounds.height + 2 * UI.Margins
		if let collectionView = view as? UICollectionView {
			collectionView.contentInset.bottom = bottomInset
			collectionView.verticalScrollIndicatorInsets.bottom = bottomInset
		}
	}
	
	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		guard !hasAppliedPresetRange else { return }
		hasAppliedPresetRange = true
		applyPresetRange()
	}
	
	private func applyPresetRange() {
		let start = normalizedCalendarDay(presetFrom)
		let end = normalizedCalendarDay(presetTo)
		secondaryHighlightRanges = normalizedSecondaryRanges([start...end])
		updateButtonSubtitle(from: start, to: end)
		scrollToMonthContaining(start, animated: false)
	}
	
	public override func handleDaySelection(date tappedDate: Date, sourceView: UIView) {
		let tappedDay = normalizedCalendarDay(tappedDate)
		
		if let start = selectedStartDate {
			let rangeStart = min(start, tappedDay)
			let rangeEnd = max(start, tappedDay)
			secondaryHighlightRanges = normalizedSecondaryRanges([rangeStart...rangeEnd])
			selectedStartDate = nil
			updateButtonSubtitle(from: rangeStart, to: rangeEnd)
		} else {
			selectedStartDate = tappedDay
			secondaryHighlightRanges = normalizedSecondaryRanges([tappedDay...tappedDay])
			updateButtonSubtitle(from: tappedDay, to: tappedDay)
		}
	}
	
	private func updateButtonSubtitle(from start: Date, to end: Date) {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.locale = Locale(identifier: "fr_FR")
		if bookingDisplayCalendar.isDate(start, inSameDayAs: end) {
			validateButton.subtitle = formatter.string(from: start)
		} else {
			validateButton.subtitle = "\(formatter.string(from: start)) – \(formatter.string(from: end))"
		}
	}
}
