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
	
	/// Plages à afficher en Colors.Secondary (ex. résa en cours d’édition). Dessinées au-dessus des résas Primary.
	public var secondaryHighlightRanges: Set<ClosedRange<Date>>? {
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
        
        calendarView.scroll(toMonthContaining: Date(), scrollPosition: .centered, animated: false)
	}
	
	// MARK: - Selection
	
	internal func handleDaySelection(_ day: DayComponents) {
		
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
	
	internal func updateCalendar() {
		
		calendarView.setContent(makeContent())
	}
	
	internal func makeContent() -> CalendarViewContent {
		
		let calendar = Calendar.current
		
		// Plages de dates des réservations (pour le fond coloré entre les jours)
		let bookingRanges: Set<ClosedRange<Date>> = Set(
			(bookings ?? []).filter { !$0.isCancelled }.map { booking in
				let start = calendar.startOfDay(for: booking.dates.start)
				let end = calendar.startOfDay(for: booking.dates.end)
				return start...end
			}
		)
		let secondary = secondaryHighlightRanges ?? []
		let allRanges = bookingRanges.union(secondary)
		
		// Afficher 1 an dans le passé et 1 an dans le futur
		let startMonth = calendar.date(byAdding: .year, value: -1, to: Date())!
		let endMonth = calendar.date(byAdding: .year, value: 1, to: Date())!
		
		var content = CalendarViewContent(
			calendar: calendar,
			visibleDateRange: startMonth...endMonth,
			monthsLayout: .vertical(options: VerticalMonthsLayoutOptions())
		)
		.interMonthSpacing(24)
		.verticalDayMargin(8)
		.horizontalDayMargin(8)
		
		// Un seul provider : chaque plage est dessinée en Primary ou Secondary selon secondaryHighlightRanges
		if !allRanges.isEmpty {
			content = content.dayRangeItemProvider(for: allRanges) { dayRangeLayoutContext in
				let frames = dayRangeLayoutContext.daysAndFrames.map { $0.frame }
				let range: ClosedRange<Date>? = {
					guard let first = dayRangeLayoutContext.daysAndFrames.first, let last = dayRangeLayoutContext.daysAndFrames.last else { return nil }
					guard let start = calendar.date(from: DateComponents(year: first.day.month.year, month: first.day.month.month, day: first.day.day)),
					      let end = calendar.date(from: DateComponents(year: last.day.month.year, month: last.day.month.month, day: last.day.day)) else { return nil }
					return calendar.startOfDay(for: start)...calendar.startOfDay(for: end)
				}()
				let isSecondary = range.map { secondary.contains($0) } ?? false
				return CalendarItemModel<BookingRangeBackgroundView>(
					invariantViewProperties: .init(secondaryRanges: secondary),
					content: .init(framesOfDaysToHighlight: frames, range: range, isSecondary: isSecondary)
				)
			}
		}
		
		return content
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
            let isInSecondaryRange = secondary.contains(where: { $0.contains(dayStart) })
			
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
                    color: booking.platform?.type?.backgroundColor ?? .red
				)
			}
			
			return CalendarItemModel<BookingDayView>(
				invariantViewProperties: .init(),
				content: .init(
					day: day,
					isToday: isToday,
                    isInSecondaryRange: isInSecondaryRange,
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

// MARK: - Booking Range Background View (bande entre les jours)

private struct BookingRangeBackgroundViewProperties: Hashable {
	var secondaryRanges: Set<ClosedRange<Date>> = []
}

private struct BookingRangeBackgroundViewContent: Equatable {
	let framesOfDaysToHighlight: [CGRect]
	let range: ClosedRange<Date>?
	let isSecondary: Bool
}

private final class BookingRangeBackgroundView: UIView, CalendarItemViewRepresentable {
	typealias InvariantViewProperties = BookingRangeBackgroundViewProperties
	typealias Content = BookingRangeBackgroundViewContent

	private let rangeLayer = CAShapeLayer()

	override init(frame: CGRect) {
		super.init(frame: frame)
        rangeLayer.fillColor = UIColor.clear.cgColor
		layer.addSublayer(rangeLayer)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		rangeLayer.frame = bounds
	}

	static func makeView(withInvariantViewProperties invariantViewProperties: BookingRangeBackgroundViewProperties) -> BookingRangeBackgroundView {
		BookingRangeBackgroundView()
	}

	static func setContent(_ content: BookingRangeBackgroundViewContent, on view: BookingRangeBackgroundView) {
		// En arrière des labels et bullets des jours ; Secondary au-dessus de Primary
		view.layer.zPosition = content.isSecondary ? -1 : -2
        view.rangeLayer.fillColor = (content.isSecondary ? Colors.Secondary : .clear).cgColor
		guard !content.framesOfDaysToHighlight.isEmpty else {
			view.rangeLayer.path = nil
			return
		}
		var framesByRow: [Int: [CGRect]] = [:]
		for frame in content.framesOfDaysToHighlight {
			let rowKey = Int(frame.midY.rounded())
			framesByRow[rowKey, default: []].append(frame)
		}
		let path = UIBezierPath()
		let insetDx: CGFloat = 2
		let insetDy: CGFloat = 6
		for rowKey in framesByRow.keys.sorted() {
			guard let rowFrames = framesByRow[rowKey], !rowFrames.isEmpty else { continue }
			let union = rowFrames.reduce(CGRect.null) { $0.union($1) }
			let rect = union.insetBy(dx: insetDx, dy: insetDy)
			path.append(UIBezierPath(roundedRect: rect, cornerRadius: 6))
		}
		view.rangeLayer.path = path.cgPath
	}
}

// MARK: - Booking Bar Info (conservé pour savoir si le jour a une résa)

private struct BookingBarInfo: Equatable {
	let isStartDate: Bool
	let isEndDate: Bool
	let color: UIColor

	static func == (lhs: BookingBarInfo, rhs: BookingBarInfo) -> Bool {
		lhs.isStartDate == rhs.isStartDate && lhs.isEndDate == rhs.isEndDate
	}
}

// MARK: - Booking Day View

private struct BookingDayViewProperties: Hashable {}

private struct BookingDayViewContent: Equatable {
	let day: DayComponents
	let isToday: Bool
    /// Indique si le jour fait partie de la plage secondaire (sélection en cours)
    let isInSecondaryRange: Bool
	let bookings: [BookingBarInfo]
	
	static func == (lhs: BookingDayViewContent, rhs: BookingDayViewContent) -> Bool {
		return lhs.day == rhs.day
        && lhs.isToday == rhs.isToday
        && lhs.isInSecondaryRange == rhs.isInSecondaryRange
        && lhs.bookings == rhs.bookings
	}
}

private final class BookingDayView: UIView, CalendarItemViewRepresentable {

	typealias InvariantViewProperties = BookingDayViewProperties
	typealias Content = BookingDayViewContent

	private let backgroundCircleView = UIView()
	private let contentStackView = UIStackView()
	private let bulletsStackView = UIStackView()
	private let label = UILabel()

    private static let bulletSize: CGFloat = UI.Margins/3
	private static let bulletSpacing: CGFloat = 2
	private static let bulletLabelSpacing: CGFloat = 3

	init() {
		super.init(frame: .zero)

        backgroundCircleView.backgroundColor = Colors.Secondary
		backgroundCircleView.isHidden = true
		addSubview(backgroundCircleView)
		backgroundCircleView.snp.makeConstraints { make in
			make.center.equalToSuperview()
            make.size.equalTo(UI.Margins*2)
		}

		contentStackView.axis = .vertical
		contentStackView.spacing = Self.bulletLabelSpacing
		contentStackView.alignment = .center
		addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.center.equalToSuperview()
		}

		bulletsStackView.axis = .horizontal
		bulletsStackView.spacing = Self.bulletSpacing
		bulletsStackView.alignment = .center
		bulletsStackView.distribution = .equalSpacing
		contentStackView.addArrangedSubview(bulletsStackView)
		bulletsStackView.snp.makeConstraints { make in
			make.height.equalTo(Self.bulletSize)
		}

		label.textAlignment = .center
		label.font = Fonts.Content.Text.Regular
		contentStackView.addArrangedSubview(label)

		sendSubviewToBack(backgroundCircleView)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		backgroundCircleView.layer.cornerRadius = backgroundCircleView.bounds.width / 2
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	static func makeView(withInvariantViewProperties invariantViewProperties: BookingDayViewProperties) -> BookingDayView {
		BookingDayView()
	}

	static func setContent(_ content: BookingDayViewContent, on view: BookingDayView) {
		view.label.text = "\(content.day.day)"

		view.backgroundCircleView.isHidden = !content.isToday
        if content.isToday {
            // Cercle autour d'aujourd'hui : blanc si dans la sélection secondaire, sinon Secondary
            view.backgroundCircleView.backgroundColor = content.isInSecondaryRange ? .white : Colors.Secondary
        }

		// Bullets au-dessus du numéro : une par réservation
        view.bulletsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		if !content.bookings.isEmpty {
			view.bulletsStackView.isHidden = false
			for booking in content.bookings {
				let bullet = UIView()
                bullet.backgroundColor = content.isToday ? .white : booking.color
				bullet.layer.cornerRadius = Self.bulletSize / 2
				view.bulletsStackView.addArrangedSubview(bullet)
				bullet.snp.makeConstraints { make in
					make.size.equalTo(Self.bulletSize)
				}
			}
		} else {
			view.bulletsStackView.isHidden = true
		}

        if content.isToday && content.isInSecondaryRange {
            // Aujourd'hui dans la plage sélectionnée : cercle blanc, texte Secondary
            view.label.textColor = Colors.Secondary
            view.label.font = Fonts.Content.Text.Bold
        }
        else if content.isInSecondaryRange {
            // Autres jours dans la plage sélectionnée : texte blanc
            view.label.textColor = .white
            view.label.font = content.isToday ? Fonts.Content.Text.Bold : Fonts.Content.Text.Regular
        }
        else if !content.bookings.isEmpty {
            view.label.textColor = content.isToday ? .white : Colors.Primary
			view.label.font = content.isToday ? Fonts.Content.Text.Bold : Fonts.Content.Text.Regular
		}
        else if content.isToday {
            view.label.textColor = .white
			view.label.font = Fonts.Content.Text.Bold
		}
        else {
			view.label.textColor = Colors.Content.Text
			view.label.font = Fonts.Content.Text.Regular
		}
	}
}
