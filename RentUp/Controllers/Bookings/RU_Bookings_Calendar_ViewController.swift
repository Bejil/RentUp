//
//  RU_Bookings_Calendar_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 31/01/2026.
//

import UIKit
import SnapKit

public class RU_Bookings_Calendar_ViewController: RU_ViewController {
	
	// MARK: - Properties
	
    /// Nombre max de lignes de barres (un logement = une ligne, plusieurs résas le même jour = segments sur la même ligne).
    private let maxVisibleLanesPerDay = 3
    
    /// Calendrier aligné ISO / France : semaine du lundi au dimanche.
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
	
	private lazy var weeksScrollHostView: WeeksScrollHostView = {
		WeeksScrollHostView(owner: self)
	}()
	
	// MARK: - Lifecycle
	
	public override func loadView() {
		
		super.loadView()
		
		isModal = true
        navigationItem.title = String(key: "bookings.calendar.overview.title")
		
		view.addSubview(weeksScrollHostView)
		weeksScrollHostView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
		}
        // Ne pas construire toute la grille dans loadView (bloque le thread UI) : chargement différé + mois asynchrones.
        DispatchQueue.main.async { [weak self] in
            self?.weeksScrollHostView.reload(animated: false)
            self?.weeksScrollHostView.scrollToMonthContaining(Date(), animated: false)
        }
	}
	
	// MARK: - Selection
	
	internal func handleDaySelection(date selectedDate: Date) {
		
		let calendar = displayedCalendar
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
            let button = alert.addButton(title: "\(platformName) • \(range)") { [weak self] _ in
                alert.close {
                    self?.didSelectBooking?(booking)
                }
            }
            button.configuration?.baseBackgroundColor = booking.platform?.type?.backgroundColor
        }
        
        alert.addCancelButton()
        alert.present(as: .Sheet)
	}
	
	internal func updateCalendar() {
		weeksScrollHostView.reload(animated: false)
	}
	
	/// Contenu d’une cellule jour (grille maison : pas de `DayComponents` Horizon).
	private func makeBookingDayViewContent(
        for date: Date,
        calendar: Calendar,
        today: Date,
        laneByBookingKey: [String: Int],
        secondaryRanges: Set<ClosedRange<Date>>
    ) -> BookingDayViewContent {
        let dayStart = calendar.startOfDay(for: date)
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        let dom = calendar.component(.day, from: date)
        let isToday = calendar.isDateInToday(date)
        let isInSecondaryRange = secondaryRanges.contains(where: { $0.contains(dayStart) })
        
        let bookingsForDay = (bookings ?? []).filter({ booking in
            let start = calendar.startOfDay(for: booking.dates.start)
            let end = calendar.startOfDay(for: booking.dates.end)
            return dayStart >= start && dayStart <= end
        })
        
        let barRows = makeBarRows(
            for: date,
            dayStart: dayStart,
            today: today,
            bookingsForDay: bookingsForDay,
            calendar: calendar,
            laneByBookingKey: laneByBookingKey,
            maxRows: maxVisibleLanesPerDay
        )
        let allRowCount = countPropertyRows(for: bookingsForDay)
        let hiddenCount = max(0, allRowCount - barRows.count)
        
        return BookingDayViewContent(
            year: y,
            month: m,
            dayOfMonth: dom,
            isToday: isToday,
            isInSecondaryRange: isInSecondaryRange,
            barRows: barRows,
            hiddenCount: hiddenCount
        )
    }
    
    /// Bandes verticales (lignes de barres + ligne « +N ») pour un jour — sert au ratio de hauteur **par semaine**.
    private func barBandCountForDay(
        date: Date,
        calendar: Calendar,
        today: Date,
        laneByBookingKey: [String: Int]
    ) -> Int {
        let dayStart = calendar.startOfDay(for: date)
        let bookingsForDay = (bookings ?? []).filter { booking in
            let s = calendar.startOfDay(for: booking.dates.start)
            let e = calendar.startOfDay(for: booking.dates.end)
            return dayStart >= s && dayStart <= e
        }
        guard !bookingsForDay.isEmpty else { return 0 }
        let barRows = makeBarRows(
            for: date,
            dayStart: dayStart,
            today: today,
            bookingsForDay: bookingsForDay,
            calendar: calendar,
            laneByBookingKey: laneByBookingKey,
            maxRows: maxVisibleLanesPerDay
        )
        let allPropertyRows = countPropertyRows(for: bookingsForDay)
        let hidden = max(0, allPropertyRows - barRows.count)
        return barRows.count + (hidden > 0 ? 1 : 0)
    }
    
    private func bookingKey(for booking: RU_Booking) -> String {
        if let id = booking.id, !id.isEmpty {
            return id
        }
        
        // Fallback stable si id absent
        return "\(booking.dates.start.timeIntervalSince1970)|\(booking.dates.end.timeIntervalSince1970)|\(booking.platform?.type?.rawValue ?? "-")|\(booking.classified?.id ?? "-")"
    }
    
    /// Identifiant du logement : les résas du même bien partagent une ligne de barres.
    private func propertyKey(for booking: RU_Booking) -> String {
        if let uuid = booking.classified?.uuid, !uuid.isEmpty {
            return "classified:\(uuid)"
        }
        return "booking:\(booking.id)"
    }
    
    private func countPropertyRows(for bookings: [RU_Booking]) -> Int {
        Set(bookings.map { propertyKey(for: $0) }).count
    }
    
    private func makeBarRows(
        for date: Date,
        dayStart: Date,
        today: Date,
        bookingsForDay: [RU_Booking],
        calendar: Calendar,
        laneByBookingKey: [String: Int],
        maxRows: Int
    ) -> [BookingBarRowModel] {
        let grouped = Dictionary(grouping: bookingsForDay, by: { propertyKey(for: $0) })
        var keys = Array(grouped.keys)
        keys.sort { a, b in
            let laneA = grouped[a]!.map { laneByBookingKey[bookingKey(for: $0)] ?? .max }.min() ?? .max
            let laneB = grouped[b]!.map { laneByBookingKey[bookingKey(for: $0)] ?? .max }.min() ?? .max
            if laneA != laneB { return laneA < laneB }
            return a < b
        }
        keys = Array(keys.prefix(maxRows))
        
        return keys.map { key in
            let list = grouped[key]!.sorted { $0.dates.start < $1.dates.start }
            let segments: [BookingBarSegment] = list.map { booking in
                BookingBarSegment(
                    isStartDate: calendar.isDate(date, inSameDayAs: booking.dates.start),
                    isEndDate: calendar.isDate(date, inSameDayAs: booking.dates.end),
                    color: booking.platform?.type?.backgroundColor ?? .red,
                    isCurrent: dayStart >= calendar.startOfDay(for: booking.dates.start)
                        && dayStart <= calendar.startOfDay(for: booking.dates.end)
                        && today >= calendar.startOfDay(for: booking.dates.start)
                        && today <= calendar.startOfDay(for: booking.dates.end)
                )
            }
            return BookingBarRowModel(segments: segments)
        }
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
    
    /// Ratio hauteur / largeur d’une case jour : > 1 = plus d’air pour barres + numéro (appliqué **par ligne de semaine** sur la grille).
    private static func verticalDayAspectRatio(maxBarBands: Int) -> CGFloat {
        switch maxBarBands {
        case 0, 1: return 1.0
        case 2: return 1.24
        case 3: return 1.52
        case 4: return 1.82
        default: return min(2.45, 1.02 + CGFloat(maxBarBands) * 0.2)
        }
    }
    
    /// Grille verticale scrollable : hauteur de **ligne** = ratio(max bandes sur **cette** semaine uniquement).
    private final class WeeksScrollHostView: UIView {
        
        private let scrollView = UIScrollView()
        private let contentContainer = UIView()
        private let rangeOverlay = UIView()
        private let rangeLayerSecondary = CAShapeLayer()
        private let contentStack = UIStackView()
        
        unowned let owner: RU_Bookings_Calendar_ViewController
        
        private var dateToDayView: [Date: BookingDayView] = [:]
        private var tapDateByViewId: [ObjectIdentifier: Date] = [:]
        private var monthBlockByMonthStart: [Date: UIView] = [:]
        private var pendingScrollMonth: Date?
        private var pendingScrollAnimated = false
        /// Mois à centrer une fois le `reload` terminé (évite un scroll avec `contentSize` encore incomplet).
        private var centerMonthWhenReloadFinishes: (month: Date, animated: Bool)?
        /// Annule les enchaînements `async` d’un `reload` précédent lorsqu’un nouveau `reload` est demandé.
        private var reloadGeneration = 0
        
        private static let horizontalDayGap: CGFloat = 2
        private static let weekRowGap: CGFloat = 2
        
        init(owner: RU_Bookings_Calendar_ViewController) {
            self.owner = owner
            super.init(frame: .zero)
            backgroundColor = .clear
            
            addSubview(scrollView)
            scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
            scrollView.alwaysBounceVertical = true
            
            scrollView.addSubview(contentContainer)
            contentContainer.snp.makeConstraints { make in
                make.edges.equalTo(scrollView.contentLayoutGuide)
                make.width.equalTo(scrollView.frameLayoutGuide)
            }
            
            contentContainer.addSubview(rangeOverlay)
            rangeOverlay.isUserInteractionEnabled = false
            rangeOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }
            rangeLayerSecondary.fillColor = Colors.Secondary.cgColor
            rangeOverlay.layer.addSublayer(rangeLayerSecondary)
            
            contentContainer.addSubview(contentStack)
            contentStack.axis = .vertical
            contentStack.spacing = 0
            contentStack.alignment = .fill
            contentStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: UI.Margins, bottom: 0, right: UI.Margins)) }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleDayTap(_:)))
            contentStack.addGestureRecognizer(tap)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func reload(animated: Bool) {
            _ = animated
            reloadGeneration += 1
            let generation = reloadGeneration
            pendingScrollMonth = nil
            centerMonthWhenReloadFinishes = nil
            
            contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            dateToDayView.removeAll()
            tapDateByViewId.removeAll()
            monthBlockByMonthStart.removeAll()
            contentStack.alpha = 0
            rangeOverlay.alpha = 0
            
            showPlaceholder(.Loading)
            
            let cal = owner.displayedCalendar
            let today = cal.startOfDay(for: Date())
            let sourceBookings = owner.bookings ?? []
            let activeForLanes = sourceBookings.filter { !$0.isCancelled }
            let laneByBookingKey = owner.makeLaneMapping(for: activeForLanes, calendar: cal)
            let secondary = owner.secondaryHighlightRanges ?? []
            
            func monthStart(containing date: Date) -> Date {
                cal.date(from: cal.dateComponents([.year, .month], from: date))!
            }
            
            var rangeLower: Date?
            var rangeUpper: Date?
            func widenMonth(with date: Date) {
                let m = monthStart(containing: cal.startOfDay(for: date))
                if rangeLower == nil || m < rangeLower! {
                    rangeLower = m
                }
                if rangeUpper == nil || m > rangeUpper! {
                    rangeUpper = m
                }
            }
            
            for booking in sourceBookings {
                widenMonth(with: booking.dates.start)
                widenMonth(with: booking.dates.end)
            }
            for range in secondary {
                widenMonth(with: range.lowerBound)
                widenMonth(with: range.upperBound)
            }
            
            let startMonth: Date
            let endMonth: Date
            if let lo = rangeLower, let hi = rangeUpper {
                let thisMonth = monthStart(containing: Date())
                startMonth = min(lo, thisMonth)
                endMonth = max(hi, thisMonth)
            } else {
                guard let startAnchor = cal.date(byAdding: .year, value: -1, to: Date()),
                      let endAnchor = cal.date(byAdding: .year, value: 1, to: Date()) else {
                    contentStack.alpha = 1
                    rangeOverlay.alpha = 1
                    dismissPlaceholder()
                    return
                }
                startMonth = monthStart(containing: startAnchor)
                endMonth = monthStart(containing: endAnchor)
            }
            
            var allMonthStarts: [Date] = []
            var walk = startMonth
            while walk <= endMonth {
                allMonthStarts.append(walk)
                guard let nx = cal.date(byAdding: .month, value: 1, to: walk) else { break }
                walk = nx
            }
            var pendingMonths = allMonthStarts
            
            let monthDF = DateFormatter()
            monthDF.locale = Locale(identifier: "fr_FR")
            monthDF.dateFormat = "MMMM yyyy"
            
            let symbols = ["L", "M", "M", "J", "V", "S", "D"]
            var isFirstMonth = true
            
            func appendNextMonth() {
                guard generation == self.reloadGeneration else { return }
                guard !pendingMonths.isEmpty else {
                    guard generation == self.reloadGeneration else { return }
                    if let spec = centerMonthWhenReloadFinishes {
                        pendingScrollMonth = spec.month
                        pendingScrollAnimated = spec.animated
                        centerMonthWhenReloadFinishes = nil
                    }
                    setNeedsLayout()
                    layoutIfNeeded()
                    rebuildRangePaths()
                    contentStack.alpha = 1
                    rangeOverlay.alpha = 1
                    dismissPlaceholder()
                    return
                }
                let monthCursor = pendingMonths.removeFirst()
                
                if !isFirstMonth {
                    let spacer = UIView()
                    spacer.snp.makeConstraints { $0.height.equalTo(24) }
                    contentStack.addArrangedSubview(spacer)
                }
                isFirstMonth = false
                
                let monthKey = cal.date(from: cal.dateComponents([.year, .month], from: monthCursor))!
                
                let block = UIView()
                monthBlockByMonthStart[monthKey] = block
                contentStack.addArrangedSubview(block)
                
                let inner = UIStackView()
                inner.axis = .vertical
                inner.spacing = Self.weekRowGap
                inner.alignment = .fill
                block.addSubview(inner)
                inner.snp.makeConstraints { $0.edges.equalToSuperview() }
                
                let header = UILabel()
                header.font = Fonts.Content.Title.H4
                header.textColor = Colors.Content.Title
                header.text = monthDF.string(from: monthKey).capitalized
                inner.addArrangedSubview(header)
                
                let dow = UIStackView()
                dow.axis = .horizontal
                dow.distribution = .fillEqually
                dow.spacing = Self.horizontalDayGap
                for s in symbols {
                    let l = UILabel()
                    l.text = s
                    l.font = Fonts.Content.Text.Bold
                    l.textColor = Colors.Content.Text.withAlphaComponent(0.5)
                    l.textAlignment = .center
                    dow.addArrangedSubview(l)
                }
                inner.addArrangedSubview(dow)
                dow.snp.makeConstraints { $0.height.equalTo(22) }
                
                let weeks = Self.weeksForMonth(monthAnchor: monthCursor, calendar: cal)
                for week in weeks {
                    let maxBands = week.compactMap { $0 }.map { d in
                        owner.barBandCountForDay(date: d, calendar: cal, today: today, laneByBookingKey: laneByBookingKey)
                    }.max() ?? 0
                    let ratio = RU_Bookings_Calendar_ViewController.verticalDayAspectRatio(maxBarBands: maxBands)
                    
                    let row = UIStackView()
                    row.axis = .horizontal
                    row.distribution = .fillEqually
                    row.spacing = Self.horizontalDayGap
                    
                    for dayOpt in week {
                        if let date = dayOpt {
                            let dayView = BookingDayView()
                            let dayStart = cal.startOfDay(for: date)
                            BookingDayView.setContent(
                                owner.makeBookingDayViewContent(
                                    for: date,
                                    calendar: cal,
                                    today: today,
                                    laneByBookingKey: laneByBookingKey,
                                    secondaryRanges: secondary
                                ),
                                on: dayView
                            )
                            dateToDayView[dayStart] = dayView
                            tapDateByViewId[ObjectIdentifier(dayView)] = date
                            row.addArrangedSubview(dayView)
                        } else {
                            let placeholder = UIView()
                            placeholder.isUserInteractionEnabled = false
                            row.addArrangedSubview(placeholder)
                        }
                    }
                    
                    inner.addArrangedSubview(row)
                    let gapCount: CGFloat = 6
                    row.snp.makeConstraints { make in
                        make.height.equalTo(contentStack.snp.width).multipliedBy(ratio / 7).offset(-(Self.horizontalDayGap * gapCount * ratio) / 7)
                    }
                }
                
                DispatchQueue.main.async { appendNextMonth() }
            }
            
            // Un mois par « tour » de run loop pour ne pas bloquer l’interaction / la transition.
            DispatchQueue.main.async { appendNextMonth() }
        }
        
        func scrollToMonthContaining(_ date: Date, animated: Bool) {
            let cal = owner.displayedCalendar
            let key = cal.date(from: cal.dateComponents([.year, .month], from: date))!
            centerMonthWhenReloadFinishes = (month: key, animated: animated)
            setNeedsLayout()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            rangeLayerSecondary.frame = rangeOverlay.bounds
            
            if let target = pendingScrollMonth {
                let viewportH = scrollView.bounds.height
                if viewportH > 0, let block = monthBlockByMonthStart[target] {
                    pendingScrollMonth = nil
                    let rect = block.convert(block.bounds, to: scrollView)
                    let maxOffsetY = max(0, scrollView.contentSize.height - viewportH)
                    let centeredY = rect.midY - viewportH / 2
                    let y = max(0, min(centeredY, maxOffsetY))
                    scrollView.setContentOffset(CGPoint(x: 0, y: y), animated: pendingScrollAnimated)
                }
            }
            
            rebuildRangePaths()
        }
        
        private func rebuildRangePaths() {
            let cal = owner.displayedCalendar
            let secondary = owner.secondaryHighlightRanges ?? []
            guard !secondary.isEmpty else {
                rangeLayerSecondary.path = nil
                return
            }
            let path = UIBezierPath()
            for range in secondary {
                var frames: [CGRect] = []
                var d = cal.startOfDay(for: range.lowerBound)
                let end = cal.startOfDay(for: range.upperBound)
                while d <= end {
                    if let cell = dateToDayView[d] {
                        let f = cell.convert(cell.bounds, to: rangeOverlay)
                        frames.append(f)
                    }
                    guard let next = cal.date(byAdding: .day, value: 1, to: d) else { break }
                    d = next
                }
                Self.appendRowUnionedRects(frames: frames, to: path)
            }
            rangeLayerSecondary.path = path.cgPath
        }
        
        @objc private func handleDayTap(_ gesture: UITapGestureRecognizer) {
            let p = gesture.location(in: contentStack)
            guard let hit = contentStack.hitTest(p, with: nil) else { return }
            var v: UIView? = hit
            while let cur = v {
                if let day = cur as? BookingDayView, let date = tapDateByViewId[ObjectIdentifier(day)] {
                    owner.handleDaySelection(date: date)
                    return
                }
                v = cur.superview
            }
        }
        
        private static func weeksForMonth(monthAnchor: Date, calendar: Calendar) -> [[Date?]] {
            guard let interval = calendar.dateInterval(of: .month, for: monthAnchor) else { return [] }
            let firstDay = calendar.startOfDay(for: interval.start)
            guard let dayCount = calendar.range(of: .day, in: .month, for: firstDay)?.count else { return [] }
            let weekday = calendar.component(.weekday, from: firstDay)
            let leading = (weekday + 5) % 7
            var cells: [Date?] = Array(repeating: nil, count: leading)
            for i in 0..<dayCount {
                cells.append(calendar.date(byAdding: .day, value: i, to: firstDay))
            }
            while cells.count % 7 != 0 {
                cells.append(nil)
            }
            return stride(from: 0, to: cells.count, by: 7).map { i in
                Array(cells[i..<min(i + 7, cells.count)])
            }
        }
        
        private static func appendRowUnionedRects(frames: [CGRect], to path: UIBezierPath) {
            guard !frames.isEmpty else { return }
            var framesByRow: [Int: [CGRect]] = [:]
            for frame in frames {
                let rowKey = Int(frame.midY.rounded())
                framesByRow[rowKey, default: []].append(frame)
            }
            let insetDx: CGFloat = 2
            let insetDy: CGFloat = 6
            for rowKey in framesByRow.keys.sorted() {
                guard let rowFrames = framesByRow[rowKey], !rowFrames.isEmpty else { continue }
                let union = rowFrames.reduce(CGRect.null) { $0.union($1) }
                let rect = union.insetBy(dx: insetDx, dy: insetDy)
                path.append(UIBezierPath(roundedRect: rect, cornerRadius: 6))
            }
        }
    }
}

// MARK: - Barres par bien (une ligne = un logement, segments alignés horizontalement)

private struct BookingBarSegment: Equatable {
	let isStartDate: Bool
	let isEndDate: Bool
	let color: UIColor
	let isCurrent: Bool
}

private struct BookingBarRowModel: Equatable {
	let segments: [BookingBarSegment]
}

// MARK: - Booking Day View

private struct BookingDayViewContent: Equatable {
	let year: Int
	let month: Int
	let dayOfMonth: Int
	let isToday: Bool
    /// Indique si le jour fait partie de la plage secondaire (sélection en cours)
    let isInSecondaryRange: Bool
	let barRows: [BookingBarRowModel]
    let hiddenCount: Int
	
	static func == (lhs: BookingDayViewContent, rhs: BookingDayViewContent) -> Bool {
		return lhs.year == rhs.year
        && lhs.month == rhs.month
        && lhs.dayOfMonth == rhs.dayOfMonth
        && lhs.isToday == rhs.isToday
        && lhs.isInSecondaryRange == rhs.isInSecondaryRange
        && lhs.barRows == rhs.barRows
        && lhs.hiddenCount == rhs.hiddenCount
	}
}

private final class BookingDayView: UIView {

	private let daySurfaceView = UIView()
	private let backgroundCircleView = UIView()
	private let contentStackView = RU_StackView()
    private let barsTopSpacer = UIView()
    private let barsStackView = RU_StackView()
    private let moreLabel = UILabel()
	private let label = UILabel()

    private static let barHeight: CGFloat = 5
	private static let barSpacing: CGFloat = 2
	private static let barLabelSpacing: CGFloat = 3
    private static let horizontalInset: CGFloat = 0
    /// Espace au-dessus des barres de réservation.
    private static let barsTopInset: CGFloat = 2
    /// Entre fin de séjour et début suivant le même jour (effet « -- »).
    private static let barGapBetweenSegments: CGFloat = 3

	init() {
		super.init(frame: .zero)

        daySurfaceView.clipsToBounds = false
        daySurfaceView.layer.shadowColor = UIColor.black.cgColor
        daySurfaceView.layer.shadowOffset = CGSize(width: 0, height: 4)
        daySurfaceView.layer.shadowRadius = UI.CornerRadius
        daySurfaceView.layer.shadowOpacity = 0.1
        daySurfaceView.backgroundColor = Colors.Background.View
        daySurfaceView.layer.cornerRadius = UI.Margins/2
		addSubview(daySurfaceView)
		daySurfaceView.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview().inset(UI.Margins / 2)
			make.left.right.equalToSuperview().inset(UI.Margins / 4)
		}

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
			make.top.bottom.equalToSuperview().inset(UI.Margins / 2)
			make.left.right.equalToSuperview().inset(UI.Margins / 4)
		}

        contentStackView.addArrangedSubview(barsTopSpacer)
        barsTopSpacer.snp.makeConstraints { make in
            make.height.equalTo(Self.barsTopInset)
        }
        barsTopSpacer.isHidden = true

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
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private static func applyBarCorners(to bar: UIView, segment: BookingBarSegment) {
		bar.backgroundColor = segment.color
		if segment.isStartDate && segment.isEndDate {
			bar.layer.cornerRadius = Self.barHeight / 2
			bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		} else if segment.isStartDate {
			bar.layer.cornerRadius = Self.barHeight / 2
			bar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
		} else if segment.isEndDate {
			bar.layer.cornerRadius = Self.barHeight / 2
			bar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		} else {
			bar.layer.cornerRadius = 0
		}
		bar.layer.masksToBounds = true
	}

	private static func addBarRow(_ row: BookingBarRowModel, to verticalStack: RU_StackView) {
		let segments = row.segments
		guard let first = segments.first else { return }
		if segments.count == 1 {
			let host = UIView()
			verticalStack.addArrangedSubview(host)
			host.snp.makeConstraints { make in
				make.height.equalTo(Self.barHeight)
			}
			let bar = UIView()
			applyBarCorners(to: bar, segment: first)
			host.addSubview(bar)
			bar.snp.makeConstraints { make in
				make.height.equalTo(Self.barHeight)
				make.centerY.equalToSuperview()
				if first.isStartDate && first.isEndDate {
					make.width.equalTo(host.snp.width).multipliedBy(0.5)
					make.centerX.equalToSuperview()
				} else if first.isStartDate {
					make.width.equalTo(host.snp.width).multipliedBy(0.5)
					make.right.equalToSuperview()
				} else if first.isEndDate {
					make.width.equalTo(host.snp.width).multipliedBy(0.5)
					make.left.equalToSuperview()
				} else {
					make.left.right.equalToSuperview()
				}
			}
		} else {
			let hStack = UIStackView()
			hStack.axis = .horizontal
			hStack.spacing = Self.barGapBetweenSegments
			hStack.distribution = .fillEqually
			hStack.alignment = .fill
			verticalStack.addArrangedSubview(hStack)
			hStack.snp.makeConstraints { make in
				make.height.equalTo(Self.barHeight)
			}
			for segment in segments {
				let cell = UIView()
				let bar = UIView()
				applyBarCorners(to: bar, segment: segment)
				cell.addSubview(bar)
				hStack.addArrangedSubview(cell)
				bar.snp.makeConstraints { make in
					make.height.equalTo(Self.barHeight)
					make.left.right.top.bottom.equalToSuperview()
				}
			}
		}
	}

	static func setContent(_ content: BookingDayViewContent, on view: BookingDayView) {
		view.label.text = "\(content.dayOfMonth)"
        view.daySurfaceView.backgroundColor = content.isInSecondaryRange ? .clear : Colors.Background.View

		view.backgroundCircleView.isHidden = !content.isToday
        if content.isToday {
            // Cercle autour d'aujourd'hui : blanc si dans la sélection secondaire, sinon Secondary
            view.backgroundCircleView.backgroundColor = content.isInSecondaryRange ? .white : Colors.Secondary
        }

		// Une ligne verticale par bien ; plusieurs segments = une ligne horizontale (ex. checkout | checkin).
        view.barsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
		if !content.barRows.isEmpty {
			view.barsTopSpacer.isHidden = false
			view.barsStackView.isHidden = false
            for row in content.barRows {
                Self.addBarRow(row, to: view.barsStackView)
            }
		} else {
			view.barsTopSpacer.isHidden = true
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
        else if !content.barRows.isEmpty {
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
