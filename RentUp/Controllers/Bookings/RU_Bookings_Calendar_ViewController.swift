//
//  RU_Bookings_Calendar_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 31/01/2026.
//

import UIKit
import HorizonCalendar
import SnapKit

public class RU_Bookings_Calendar_ViewController: RU_ViewController {
	
	// MARK: - Properties
	
	public var bookings: [RU_Booking]? {
		didSet {
			updateCalendar()
		}
	}
	
	public var didSelectBooking: ((RU_Booking) -> Void)?
	
	private lazy var calendarView: CalendarView = {
		
		let calendarView = CalendarView(initialContent: makeContent())
		calendarView.backgroundColor = .clear
		return calendarView
	}()
	
	// MARK: - Lifecycle
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
        navigationItem.title = String(key: "bookings.calendar.overview.title")
		
		view.addSubview(calendarView)
		calendarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
		}
		
		calendarView.daySelectionHandler = { [weak self] day in
			self?.handleDaySelection(day)
		}
        
        calendarView.scroll(toMonthContaining: Date(), scrollPosition: .centered, animated: true)
	}
	
	// MARK: - Selection
	
	private func handleDaySelection(_ day: DayComponents) {
		
		let calendar = Calendar.current
		guard let selectedDate = calendar.date(from: DateComponents(year: day.month.year, month: day.month.month, day: day.day)) else { return }
		
		// Trouver la réservation correspondant à cette date
		if let booking = bookings?.first(where: { booking in
			let start = calendar.startOfDay(for: booking.dates.start)
			let end = calendar.startOfDay(for: booking.dates.end)
			let selected = calendar.startOfDay(for: selectedDate)
			return selected >= start && selected <= end
		}) {
			didSelectBooking?(booking)
		}
	}
	
	private func updateCalendar() {
		
		calendarView.setContent(makeContent())
	}
	
	private func makeContent() -> CalendarViewContent {
		
		let calendar = Calendar.current
		
		// Afficher 1 an dans le passé et 1 an dans le futur
		let startMonth = calendar.date(byAdding: .year, value: -1, to: Date())!
		let endMonth = calendar.date(byAdding: .year, value: 1, to: Date())!
		
		return CalendarViewContent(
			calendar: calendar,
			visibleDateRange: startMonth...endMonth,
			monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
		)
		.interMonthSpacing(24)
		.verticalDayMargin(8)
		.horizontalDayMargin(8)
		
		// Month header
		.monthHeaderItemProvider { month in
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier: "fr_FR")
			dateFormatter.dateFormat = "MMMM yyyy"
			
			let monthDate = calendar.date(from: DateComponents(year: month.year, month: month.month))!
			let monthText = dateFormatter.string(from: monthDate).capitalized
			
			return CalendarItemModel<MonthHeaderView>(
				invariantViewProperties: .init(font: Fonts.Content.Title.H4, textColor: Colors.Content.Title),
				content: .init(text: monthText)
			)
		}
		
		// Day of week header
		.dayOfWeekItemProvider { _, dayOfWeek in
			let weekdaySymbols = ["L", "M", "M", "J", "V", "S", "D"]
			let text = weekdaySymbols[dayOfWeek]
			
			return CalendarItemModel<DayOfWeekView>(
				invariantViewProperties: .init(font: Fonts.Content.Text.Bold, textColor: Colors.Content.Text.withAlphaComponent(0.5)),
				content: .init(text: text)
			)
		}
		
		// Day item
		.dayItemProvider { [weak self] day in
			
			let date = calendar.date(from: DateComponents(year: day.month.year, month: day.month.month, day: day.day))!
			let dayStart = calendar.startOfDay(for: date)
			let isToday = calendar.isDateInToday(date)
			
			// Trouver TOUTES les réservations pour ce jour
			let bookingsForDay = self?.bookings?.filter({ booking in
				let start = calendar.startOfDay(for: booking.dates.start)
				let end = calendar.startOfDay(for: booking.dates.end)
				return dayStart >= start && dayStart <= end
			}) ?? []
			
			// Créer les infos pour chaque réservation
			let bookingInfos: [BookingBarInfo] = bookingsForDay.map { booking in
				BookingBarInfo(
					isStartDate: calendar.isDate(date, inSameDayAs: booking.dates.start),
					isEndDate: calendar.isDate(date, inSameDayAs: booking.dates.end),
					color: booking.platform?.type?.backgroundColor ?? Colors.Primary
				)
			}
			
			return CalendarItemModel<BookingDayView>(
				invariantViewProperties: .init(),
				content: .init(
					day: day,
					isToday: isToday,
					bookings: bookingInfos
				)
			)
		}
	}
}

// MARK: - Month Header View

private struct MonthHeaderViewProperties: Hashable {
	let font: UIFont
	let textColor: UIColor
}

private struct MonthHeaderViewContent: Equatable {
	let text: String
}

private final class MonthHeaderView: UIView, CalendarItemViewRepresentable {
	
	typealias InvariantViewProperties = MonthHeaderViewProperties
	typealias Content = MonthHeaderViewContent
	
	private let label = UILabel()
	
	init() {
		super.init(frame: .zero)
		
		addSubview(label)
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func makeView(withInvariantViewProperties invariantViewProperties: MonthHeaderViewProperties) -> MonthHeaderView {
		let view = MonthHeaderView()
		view.label.font = invariantViewProperties.font
		view.label.textColor = invariantViewProperties.textColor
		return view
	}
	
	static func setContent(_ content: MonthHeaderViewContent, on view: MonthHeaderView) {
		view.label.text = content.text
	}
}

// MARK: - Day of Week View

private struct DayOfWeekViewProperties: Hashable {
	let font: UIFont
	let textColor: UIColor
}

private struct DayOfWeekViewContent: Equatable {
	let text: String
}

private final class DayOfWeekView: UIView, CalendarItemViewRepresentable {
	
	typealias InvariantViewProperties = DayOfWeekViewProperties
	typealias Content = DayOfWeekViewContent
	
	private let label = UILabel()
	
	init() {
		super.init(frame: .zero)
		
		label.textAlignment = .center
		addSubview(label)
		label.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func makeView(withInvariantViewProperties invariantViewProperties: DayOfWeekViewProperties) -> DayOfWeekView {
		let view = DayOfWeekView()
		view.label.font = invariantViewProperties.font
		view.label.textColor = invariantViewProperties.textColor
		return view
	}
	
	static func setContent(_ content: DayOfWeekViewContent, on view: DayOfWeekView) {
		view.label.text = content.text
	}
}

// MARK: - Booking Bar Info

private struct BookingBarInfo: Equatable {
	let isStartDate: Bool
	let isEndDate: Bool
	let color: UIColor
	
	static func == (lhs: BookingBarInfo, rhs: BookingBarInfo) -> Bool {
		return lhs.isStartDate == rhs.isStartDate &&
			lhs.isEndDate == rhs.isEndDate
	}
}

// MARK: - Booking Day View

private struct BookingDayViewProperties: Hashable {}

private struct BookingDayViewContent: Equatable {
	let day: DayComponents
	let isToday: Bool
	let bookings: [BookingBarInfo]
	
	static func == (lhs: BookingDayViewContent, rhs: BookingDayViewContent) -> Bool {
		return lhs.day == rhs.day && lhs.isToday == rhs.isToday && lhs.bookings == rhs.bookings
	}
}

private final class BookingDayView: UIView, CalendarItemViewRepresentable {
	
	typealias InvariantViewProperties = BookingDayViewProperties
	typealias Content = BookingDayViewContent
	
	private let label = UILabel()
	private let todayIndicator = UIView()
	private let barsStackView = UIStackView()
	private var barViews: [UIView] = []
	
	init() {
		super.init(frame: .zero)
		
		// Indicateur pour aujourd'hui
		todayIndicator.backgroundColor = Colors.Primary
		todayIndicator.layer.cornerRadius = 3
		todayIndicator.isHidden = true
		addSubview(todayIndicator)
		todayIndicator.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview().offset(8)
			make.size.equalTo(6)
		}
		
		// Stack view pour les barres de réservation
		barsStackView.axis = .vertical
		barsStackView.spacing = 2
		barsStackView.distribution = .fillEqually
		addSubview(barsStackView)
		barsStackView.snp.makeConstraints { make in
			make.left.right.equalToSuperview()
			make.bottom.equalToSuperview().offset(-2)
			make.height.equalTo(10)
		}
		
		label.textAlignment = .center
		label.font = Fonts.Content.Text.Regular
		addSubview(label)
		label.snp.makeConstraints { make in
			make.top.left.right.equalToSuperview()
			make.bottom.equalTo(barsStackView.snp.top).offset(-1)
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	static func makeView(withInvariantViewProperties invariantViewProperties: BookingDayViewProperties) -> BookingDayView {
		return BookingDayView()
	}
	
	static func setContent(_ content: BookingDayViewContent, on view: BookingDayView) {
		view.label.text = "\(content.day.day)"
		
		// Indicateur d'aujourd'hui
		view.todayIndicator.isHidden = !content.isToday
		
		// Supprimer les anciennes barres
		view.barViews.forEach { $0.removeFromSuperview() }
		view.barViews.removeAll()
		
		if content.bookings.isEmpty {
			if content.isToday {
				view.label.textColor = Colors.Primary
				view.label.font = Fonts.Content.Text.Bold
			}
			else {
				view.label.textColor = Colors.Content.Text
				view.label.font = Fonts.Content.Text.Regular
			}
			view.barsStackView.isHidden = true
		}
		else {
			if content.isToday {
				view.label.textColor = Colors.Primary
			}
			else {
				view.label.textColor = Colors.Content.Text
			}
			view.label.font = Fonts.Content.Text.Bold
			view.barsStackView.isHidden = false
			
			// Ajuster la hauteur selon le nombre de barres
			let barHeight = max(Int(UI.Margins)/3, Int(UI.Margins) / content.bookings.count)
			view.barsStackView.snp.updateConstraints { make in
				make.height.equalTo(content.bookings.count * barHeight + (content.bookings.count - 1) * 2)
			}
			
			// Créer une barre pour chaque réservation
			for booking in content.bookings {
				let bar = UIView()
				bar.backgroundColor = booking.color
				bar.layer.cornerRadius = CGFloat(barHeight) / 2
				
				// Arrondir les coins selon la position
				var corners: CACornerMask = []
				if booking.isStartDate {
					corners.insert(.layerMinXMinYCorner)
					corners.insert(.layerMinXMaxYCorner)
				}
				if booking.isEndDate {
					corners.insert(.layerMaxXMinYCorner)
					corners.insert(.layerMaxXMaxYCorner)
				}
				bar.layer.maskedCorners = corners
				
				// Container : le trait commence/finit à la moitié du jour (centre du jour)
				let container = UIView()
				container.addSubview(bar)
				bar.snp.makeConstraints { make in
					if booking.isStartDate && !booking.isEndDate {
						make.left.equalTo(container.snp.centerX)
						make.right.equalToSuperview()
					} else if booking.isEndDate && !booking.isStartDate {
						make.left.equalToSuperview()
						make.right.equalTo(container.snp.centerX)
					} else if booking.isStartDate && booking.isEndDate {
						make.centerX.equalToSuperview()
						make.width.equalTo(container.snp.width).multipliedBy(0.08)
					} else {
						make.left.right.equalToSuperview()
					}
					make.top.bottom.equalToSuperview()
				}
				
				view.barsStackView.addArrangedSubview(container)
				view.barViews.append(container)
			}
		}
	}
}
