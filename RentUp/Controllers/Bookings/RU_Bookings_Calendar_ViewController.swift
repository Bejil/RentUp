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
	
    private let maxVisibleLanesPerDay = 3
    
    /// Calendrier aligné ISO / France : semaine du lundi au dimanche (idem que `weekdayIndex` d’HorizonCalendar : 0 = dimanche … 6 = samedi).
    private let displayedCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "fr_FR")
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }()
    
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
		
		let calendar = displayedCalendar
		guard let selectedDate = calendar.date(from: DateComponents(year: day.month.year, month: day.month.month, day: day.day)) else { return }
        let selectedDay = calendar.startOfDay(for: selectedDate)
		
		// Trouver TOUTES les réservations correspondant à cette date
        let bookingsForDay = bookings?.filter({ booking in
			let start = calendar.startOfDay(for: booking.dates.start)
			let end = calendar.startOfDay(for: booking.dates.end)
			return selectedDay >= start && selectedDay <= end
		}) ?? []
        
        guard !bookingsForDay.isEmpty else { return }
        
        if bookingsForDay.count == 1, let booking = bookingsForDay.first {
			didSelectBooking?(booking)
            return
		}
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "dd/MM"
        
        let alert: RU_Alert_ViewController = .init()
        alert.title = String(key: "bookings.calendar.overview.title")
        
        bookingsForDay.sorted(by: { $0.dates.start < $1.dates.start }).forEach { booking in
            let platformName = booking.platform?.type?.name ?? "-"
            let range = "\(formatter.string(from: booking.dates.start)) → \(formatter.string(from: booking.dates.end))"
            alert.addButton(title: "\(platformName) • \(range)") { [weak self] _ in
                alert.close {
                    self?.didSelectBooking?(booking)
                }
            }
        }
        
        alert.addCancelButton()
        alert.present(as: .Sheet)
	}
	
	internal func updateCalendar() {
		
		calendarView.setContent(makeContent())
	}
	
	internal func makeContent() -> CalendarViewContent {
		
		let calendar = displayedCalendar
        let today = calendar.startOfDay(for: Date())
        
        let activeBookings = (bookings ?? []).filter { !$0.isCancelled }
        let laneByBookingKey = makeLaneMapping(for: activeBookings, calendar: calendar)
		
		// Plages de dates des réservations (pour le fond coloré entre les jours)
		let bookingRanges: Set<ClosedRange<Date>> = Set(
			activeBookings.map { booking in
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
		
		// Day of week header — `weekdayIndex` HorizonCalendar = indice Apple (0 = dimanche … 6 = samedi), comme les symboles du calendrier.
		.dayOfWeekItemProvider { _, weekdayIndex in
			let weekdaySymbols = ["D", "L", "M", "M", "J", "V", "S"]
			let index = max(0, min(weekdaySymbols.count - 1, weekdayIndex))
			let text = weekdaySymbols[index]
			
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
            let sortedBookingsForDay = bookingsForDay.sorted {
                let lhsKey = self?.bookingKey(for: $0) ?? ""
                let rhsKey = self?.bookingKey(for: $1) ?? ""
                return (laneByBookingKey[lhsKey] ?? .max) < (laneByBookingKey[rhsKey] ?? .max)
            }
			let bookingInfos: [BookingBarInfo] = Array(sortedBookingsForDay.prefix(self?.maxVisibleLanesPerDay ?? 3)).map { booking in
                let key = self?.bookingKey(for: booking) ?? ""
                return BookingBarInfo(
					isStartDate: calendar.isDate(date, inSameDayAs: booking.dates.start),
					isEndDate: calendar.isDate(date, inSameDayAs: booking.dates.end),
                    color: booking.platform?.type?.backgroundColor ?? .red,
                    lane: laneByBookingKey[key] ?? 0,
                    isCurrent: dayStart >= calendar.startOfDay(for: booking.dates.start) && dayStart <= calendar.startOfDay(for: booking.dates.end) && today >= calendar.startOfDay(for: booking.dates.start) && today <= calendar.startOfDay(for: booking.dates.end)
				)
			}
            let hiddenCount = max(0, bookingsForDay.count - bookingInfos.count)
			
			return CalendarItemModel<BookingDayView>(
				invariantViewProperties: .init(),
				content: .init(
					day: day,
					isToday: isToday,
                    isInSecondaryRange: isInSecondaryRange,
					bookings: bookingInfos,
                    hiddenCount: hiddenCount
				)
			)
		}
	}
    
    private func bookingKey(for booking: RU_Booking) -> String {
        if let id = booking.id, !id.isEmpty {
            return id
        }
        
        // Fallback stable si id absent
        return "\(booking.dates.start.timeIntervalSince1970)|\(booking.dates.end.timeIntervalSince1970)|\(booking.platform?.type?.rawValue ?? "-")|\(booking.classified?.id ?? "-")"
    }
    
    private func makeLaneMapping(for bookings: [RU_Booking], calendar: Calendar) -> [String: Int] {
        var laneByKey: [String: Int] = [:]
        var laneEndByIndex: [Int: Date] = [:]
        
        let sorted = bookings.sorted {
            if $0.dates.start == $1.dates.start {
                return $0.dates.end < $1.dates.end
            }
            return $0.dates.start < $1.dates.start
        }
        
        for booking in sorted {
            let start = calendar.startOfDay(for: booking.dates.start)
            let end = calendar.startOfDay(for: booking.dates.end)
            let key = bookingKey(for: booking)
            
            // Deux réservations qui se suivent (checkout/checkin le même jour) partagent la même lane
            let existingLane = laneEndByIndex
                .sorted(by: { $0.key < $1.key })
                .first(where: { start >= $0.value })?.key
            
            let lane: Int
            if let existingLane {
                lane = existingLane
            } else {
                lane = (laneEndByIndex.keys.max() ?? -1) + 1
            }
            
            laneByKey[key] = lane
            laneEndByIndex[lane] = end
        }
        
        return laneByKey
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
    let lane: Int
    let isCurrent: Bool

	static func == (lhs: BookingBarInfo, rhs: BookingBarInfo) -> Bool {
		lhs.isStartDate == rhs.isStartDate
        && lhs.isEndDate == rhs.isEndDate
        && lhs.lane == rhs.lane
        && lhs.isCurrent == rhs.isCurrent
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
    let hiddenCount: Int
	
	static func == (lhs: BookingDayViewContent, rhs: BookingDayViewContent) -> Bool {
		return lhs.day == rhs.day
        && lhs.isToday == rhs.isToday
        && lhs.isInSecondaryRange == rhs.isInSecondaryRange
        && lhs.bookings == rhs.bookings
        && lhs.hiddenCount == rhs.hiddenCount
	}
}

private final class BookingDayView: UIView, CalendarItemViewRepresentable {

	typealias InvariantViewProperties = BookingDayViewProperties
	typealias Content = BookingDayViewContent

	private let backgroundCircleView = UIView()
	private let contentStackView = RU_StackView()
    private let barsStackView = RU_StackView()
    private let moreLabel = UILabel()
	private let label = UILabel()

    private static let barHeight: CGFloat = 5
	private static let barSpacing: CGFloat = 2
	private static let barLabelSpacing: CGFloat = 3
    private static let horizontalInset: CGFloat = 2

	init() {
		super.init(frame: .zero)

        backgroundCircleView.backgroundColor = Colors.Secondary
		backgroundCircleView.isHidden = true
        backgroundCircleView.layer.cornerRadius = 6
		addSubview(backgroundCircleView)
		backgroundCircleView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(UI.Margins/2)
            make.left.right.equalToSuperview().inset(UI.Margins/4)
		}

		contentStackView.axis = .vertical
		contentStackView.spacing = Self.barLabelSpacing
		contentStackView.alignment = .center
		addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

        barsStackView.axis = .vertical
        barsStackView.spacing = Self.barSpacing
        barsStackView.alignment = .fill
        contentStackView.addArrangedSubview(barsStackView)
        barsStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(Self.horizontalInset)
        }
        
        moreLabel.font = Fonts.Content.Text.Bold.withSize(9)
        moreLabel.textAlignment = .center
        moreLabel.textColor = Colors.Content.Text.withAlphaComponent(0.6)
        contentStackView.addArrangedSubview(moreLabel)

		label.textAlignment = .center
		label.font = Fonts.Content.Text.Regular
		contentStackView.addArrangedSubview(label)

		sendSubviewToBack(backgroundCircleView)
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

		// Barres au-dessus du numéro : une par réservation (max N), alignées par lane
        view.barsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		if !content.bookings.isEmpty {
			view.barsStackView.isHidden = false
			for booking in content.bookings {
                let bar = UIView()
                // Conserver la couleur de plateforme même pour aujourd'hui
                bar.backgroundColor = booking.color
                
                // Coins arrondis demandés:
                // - début: haut gauche + haut droite
                // - fin: haut droite + bas droite
                if booking.isStartDate && booking.isEndDate {
                    bar.layer.cornerRadius = Self.barHeight / 2
                    bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                }
                else if booking.isStartDate {
                    bar.layer.cornerRadius = Self.barHeight / 2
                    bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                }
                else if booking.isEndDate {
                    bar.layer.cornerRadius = Self.barHeight / 2
                    bar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                }
                else {
                    bar.layer.cornerRadius = 0
                }
                bar.layer.masksToBounds = true
                
                view.barsStackView.addArrangedSubview(bar)
                bar.snp.makeConstraints { make in
                    make.height.equalTo(Self.barHeight)
                    if booking.isStartDate && booking.isEndDate {
                        make.width.equalToSuperview().multipliedBy(0.5)
                        make.centerX.equalToSuperview()
                    }
                    else if booking.isStartDate {
                        make.width.equalToSuperview().multipliedBy(0.5)
                        make.right.equalToSuperview()
                    }
                    else if booking.isEndDate {
                        make.width.equalToSuperview().multipliedBy(0.5)
                        make.left.equalToSuperview()
                    }
                    else {
                        make.left.right.equalToSuperview()
                    }
                }
			}
		} else {
			view.barsStackView.isHidden = true
		}
        
        if content.hiddenCount > 0 {
            view.moreLabel.isHidden = false
            view.moreLabel.text = "+\(content.hiddenCount)"
        } else {
            view.moreLabel.isHidden = true
            view.moreLabel.text = nil
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
