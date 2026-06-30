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
			guard isViewLoaded else { return }
			weeksScrollHostView.applyBookingsChange()
		}
	}
	
	/// Plages à afficher en Colors.Secondary (ex. résa en cours d’édition). Dessinées au-dessus des résas Primary.
	public var secondaryHighlightRanges: Set<ClosedRange<Date>>? {
		didSet {
			guard isViewLoaded else { return }
			weeksScrollHostView.applySecondaryHighlightChange()
		}
	}
	
	public var didSelectBooking: ((RU_Booking) -> Void)?
	
	private var weeksScrollHostView: WeeksScrollHostView!
	
	// MARK: - Lifecycle
	
	public override func loadView() {
		
		weeksScrollHostView = WeeksScrollHostView(owner: self)
		view = weeksScrollHostView
		installDefaultViewChrome()
		
		isModal = true
        navigationItem.title = String(key: "bookings.calendar.overview.title")
        navigationItem.largeTitleDisplayMode = .always
        
        DispatchQueue.main.async { [weak self] in
            self?.weeksScrollHostView.performInitialLoad()
        }
	}
	
	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.prefersLargeTitles = true
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
            let classifiedName = booking.classified?.name ?? "-"
            
            let button = alert.addButton(title: "\(platformName) • \(classifiedName)") { [weak self] _ in
                alert.close {
                    self?.didSelectBooking?(booking)
                }
            }
            let range = String(key: "bookings.calendar.overview.range.0") + " \(formatter.string(from: booking.dates.start)) " + String(key: "bookings.calendar.overview.range.1") + " \(formatter.string(from: booking.dates.end))"
            button.subtitle = range
            button.configuration?.baseBackgroundColor = booking.platform?.type?.backgroundColor
        }
        
        alert.addCancelButton()
        alert.present(as: .Sheet)
	}
	
	internal func updateCalendar() {
		guard isViewLoaded else { return }
		weeksScrollHostView.applyBookingsChange()
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
    
    /// Grille verticale scrollable : une cellule = une semaine ; hauteur variable par semaine.
    private final class WeeksScrollHostView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        private static let horizontalDayGap: CGFloat = 2
        private static let weekRowGap: CGFloat = 2
        private static let monthHeaderHeight: CGFloat = 36
        private static let weekdayHeaderHeight: CGFloat = 22
        private static let monthGapHeight: CGFloat = 24
        
        unowned let owner: RU_Bookings_Calendar_ViewController
        
        private let rangeOverlay = UIView()
        private let rangeLayerSecondary = CAShapeLayer()
        
        private var dataSourceItems: [CalendarRowItem] = []
        private var displayItems: [CalendarRowItem] = []
        private var weekDaysByKey: [WeekRowKey: [Date?]] = [:]
        private var weekBandsByKey: [WeekRowKey: Int] = [:]
        private var monthStartByTimestamp: [TimeInterval: Date] = [:]
        private var laneByBookingKey: [String: Int] = [:]
        private var dateToDayView: [Date: BookingDayView] = [:]
        private var pendingScrollMonth: Date?
        private var pendingScrollAnimated = false
        
        init(owner: RU_Bookings_Calendar_ViewController) {
            self.owner = owner
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.minimumLineSpacing = Self.weekRowGap
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: UI.Margins, bottom: 0, right: UI.Margins)
            super.init(frame: .zero, collectionViewLayout: flowLayout)
            backgroundColor = .clear
            alwaysBounceVertical = true
            contentInsetAdjustmentBehavior = .automatic
            dataSource = self
            delegate = self
            
            register(BookingCalendarMonthHeaderCell.self, forCellWithReuseIdentifier: BookingCalendarMonthHeaderCell.reuseId)
            register(BookingCalendarWeekdayHeaderCell.self, forCellWithReuseIdentifier: BookingCalendarWeekdayHeaderCell.reuseId)
            register(BookingCalendarMonthGapCell.self, forCellWithReuseIdentifier: BookingCalendarMonthGapCell.reuseId)
            register(BookingCalendarWeekRowCell.self, forCellWithReuseIdentifier: BookingCalendarWeekRowCell.reuseId)
            
            rangeOverlay.isUserInteractionEnabled = false
            rangeLayerSecondary.fillColor = Colors.Secondary.cgColor
            rangeOverlay.layer.addSublayer(rangeLayerSecondary)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            guard let superview else {
                rangeOverlay.removeFromSuperview()
                return
            }
            if rangeOverlay.superview !== superview {
                superview.insertSubview(rangeOverlay, belowSubview: self)
                rangeOverlay.snp.remakeConstraints { $0.edges.equalTo(self) }
            }
        }
        
        func performInitialLoad() {
            rebuildModel()
            applySnapshot(preservingContentOffset: false)
            scrollToMonthContaining(Date(), animated: false)
        }
        
        func applyBookingsChange() {
            let offset = contentOffset
            rebuildModel()
            applySnapshot(preservingContentOffset: true, savedOffset: offset)
        }
        
        func applySecondaryHighlightChange() {
            refreshVisibleWeekCells()
            rebuildRangePaths()
        }
        
        func scrollToMonthContaining(_ date: Date, animated: Bool) {
            let cal = owner.displayedCalendar
            let key = cal.date(from: cal.dateComponents([.year, .month], from: date))!
            pendingScrollMonth = key
            pendingScrollAnimated = animated
            setNeedsLayout()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            rangeLayerSecondary.frame = rangeOverlay.bounds
            
            if let target = pendingScrollMonth {
                let ts = target.timeIntervalSince1970
                if let itemIndex = displayItems.firstIndex(where: {
                    if case .monthHeader(let t) = $0 { return t == ts }
                    return false
                }) {
                    pendingScrollMonth = nil
                    let indexPath = IndexPath(item: itemIndex, section: 0)
                    scrollToItem(at: indexPath, at: .centeredVertically, animated: pendingScrollAnimated)
                }
            }
            
            rebuildRangePaths()
        }
        
        private func configureCell(collectionView: UICollectionView, indexPath: IndexPath, item: CalendarRowItem) -> UICollectionViewCell {
            switch item {
            case .monthGap:
                return collectionView.dequeueReusableCell(withReuseIdentifier: BookingCalendarMonthGapCell.reuseId, for: indexPath)
            case .monthHeader(let timestamp):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookingCalendarMonthHeaderCell.reuseId, for: indexPath) as! BookingCalendarMonthHeaderCell
                let monthStart = monthStartByTimestamp[timestamp] ?? Date(timeIntervalSince1970: timestamp)
                let monthDF = DateFormatter()
                monthDF.locale = Locale(identifier: "fr_FR")
                monthDF.dateFormat = "MMMM yyyy"
                cell.configure(title: monthDF.string(from: monthStart).capitalized)
                return cell
            case .weekdayHeader:
                return collectionView.dequeueReusableCell(withReuseIdentifier: BookingCalendarWeekdayHeaderCell.reuseId, for: indexPath)
            case .week(let key):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookingCalendarWeekRowCell.reuseId, for: indexPath) as! BookingCalendarWeekRowCell
                let days = weekDaysByKey[key] ?? []
                let cal = owner.displayedCalendar
                let today = cal.startOfDay(for: Date())
                let secondary = owner.secondaryHighlightRanges ?? []
                cell.onDaySelected = { [weak owner] date in
                    owner?.handleDaySelection(date: date)
                }
                cell.configure(
                    days: days,
                    calendar: cal,
                    contentProvider: { [weak owner] date in
                        guard let owner else {
                            return BookingDayViewContent(year: 0, month: 0, dayOfMonth: 0, isToday: false, isInSecondaryRange: false, barRows: [], hiddenCount: 0)
                        }
                        return owner.makeBookingDayViewContent(
                            for: date,
                            calendar: cal,
                            today: today,
                            laneByBookingKey: laneByBookingKey,
                            secondaryRanges: secondary
                        )
                    }
                )
                return cell
            }
        }
        
        private func refreshVisibleWeekCells() {
            let cal = owner.displayedCalendar
            let today = cal.startOfDay(for: Date())
            let secondary = owner.secondaryHighlightRanges ?? []
            for case let cell as BookingCalendarWeekRowCell in visibleCells {
                cell.refreshContent(
                    contentProvider: { [weak owner] date in
                        guard let owner else {
                            return BookingDayViewContent(year: 0, month: 0, dayOfMonth: 0, isToday: false, isInSecondaryRange: false, barRows: [], hiddenCount: 0)
                        }
                        return owner.makeBookingDayViewContent(
                            for: date,
                            calendar: cal,
                            today: today,
                            laneByBookingKey: laneByBookingKey,
                            secondaryRanges: secondary
                        )
                    }
                )
            }
        }
        
        private func applySnapshot(preservingContentOffset: Bool, savedOffset: CGPoint = .zero) {
            displayItems = dataSourceItems
            reloadData()
            layoutIfNeeded()
            if preservingContentOffset {
                let maxY = max(0, contentSize.height - bounds.height)
                let y = min(savedOffset.y, maxY)
                setContentOffset(CGPoint(x: 0, y: y), animated: false)
            }
            rebuildRangePaths()
        }
        
        private func rebuildModel() {
            let cal = owner.displayedCalendar
            let today = cal.startOfDay(for: Date())
            let sourceBookings = owner.bookings ?? []
            let activeForLanes = sourceBookings.filter { !$0.isCancelled }
            laneByBookingKey = owner.makeLaneMapping(for: activeForLanes, calendar: cal)
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
                    displayItems = []
                    dataSourceItems = []
                    weekDaysByKey = [:]
                    weekBandsByKey = [:]
                    monthStartByTimestamp = [:]
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
            
            var items: [CalendarRowItem] = []
            var daysMap: [WeekRowKey: [Date?]] = [:]
            var bandsMap: [WeekRowKey: Int] = [:]
            var monthMap: [TimeInterval: Date] = [:]
            var nextRowItemID = 0
            
            for (monthIndex, monthCursor) in allMonthStarts.enumerated() {
                if monthIndex > 0 {
                    items.append(.monthGap(nextRowItemID))
                    nextRowItemID += 1
                }
                let monthKey = cal.date(from: cal.dateComponents([.year, .month], from: monthCursor))!
                let ts = monthKey.timeIntervalSince1970
                monthMap[ts] = monthKey
                items.append(.monthHeader(ts))
                items.append(.weekdayHeader(nextRowItemID))
                nextRowItemID += 1
                
                let weeks = Self.weeksForMonth(monthAnchor: monthCursor, calendar: cal)
                for (weekIndex, week) in weeks.enumerated() {
                    let key = WeekRowKey(monthTimestamp: ts, weekIndex: weekIndex)
                    let maxBands = week.compactMap { $0 }.map { d in
                        owner.barBandCountForDay(date: d, calendar: cal, today: today, laneByBookingKey: laneByBookingKey)
                    }.max() ?? 0
                    daysMap[key] = week
                    bandsMap[key] = maxBands
                    items.append(.week(key))
                }
            }
            
            displayItems = items
            dataSourceItems = items
            weekDaysByKey = daysMap
            weekBandsByKey = bandsMap
            monthStartByTimestamp = monthMap
        }
        
        private func weekRowHeight(for key: WeekRowKey, containerWidth: CGFloat) -> CGFloat {
            let bands = weekBandsByKey[key] ?? 0
            let ratio = RU_Bookings_Calendar_ViewController.verticalDayAspectRatio(maxBarBands: bands)
            let gapCount: CGFloat = 6
            let cellWidth = (containerWidth - Self.horizontalDayGap * gapCount) / 7
            return cellWidth * ratio
        }
        
        private func contentWidth() -> CGFloat {
            bounds.width - UI.Margins * 2
        }
        
        private func syncVisibleDayViewRegistry() {
            let cal = owner.displayedCalendar
            dateToDayView.removeAll(keepingCapacity: true)
            for case let cell as BookingCalendarWeekRowCell in visibleCells {
                cell.registerDayViews(into: &dateToDayView, calendar: cal)
            }
        }
        
        private func rebuildRangePaths() {
            let cal = owner.displayedCalendar
            let secondary = owner.secondaryHighlightRanges ?? []
            guard !secondary.isEmpty else {
                rangeLayerSecondary.path = nil
                return
            }
            syncVisibleDayViewRegistry()
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
        
        private static func weeksForMonth(monthAnchor: Date, calendar: Calendar) -> [[Date?]] {
            guard let interval = calendar.dateInterval(of: .month, for: monthAnchor) else { return [] }
            let firstDay = calendar.startOfDay(for: interval.start)
            guard let dayCount = calendar.range(of: .day, in: .month, for: firstDay)?.count else { return [] }
            let weekday = calendar.component(.weekday, from: firstDay)
            let leading = (weekday - calendar.firstWeekday + 7) % 7
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
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            displayItems.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            configureCell(collectionView: collectionView, indexPath: indexPath, item: displayItems[indexPath.item])
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            guard indexPath.item < displayItems.count else {
                return CGSize(width: contentWidth(), height: 44)
            }
            let width = contentWidth()
            switch displayItems[indexPath.item] {
            case .monthGap:
                return CGSize(width: width, height: Self.monthGapHeight)
            case .monthHeader:
                return CGSize(width: width, height: Self.monthHeaderHeight)
            case .weekdayHeader:
                return CGSize(width: width, height: Self.weekdayHeaderHeight)
            case .week(let key):
                return CGSize(width: width, height: weekRowHeight(for: key, containerWidth: width))
            }
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            rebuildRangePaths()
        }
        
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard indexPath.item < displayItems.count,
                  case .week = displayItems[indexPath.item] else { return }
            DispatchQueue.main.async { [weak self] in
                self?.rebuildRangePaths()
            }
        }
    }
}

// MARK: - Collection calendar models & cells

private enum CalendarRowItem: Hashable {
    case monthGap(Int)
    case monthHeader(TimeInterval)
    case weekdayHeader(Int)
    case week(WeekRowKey)
}

private struct WeekRowKey: Hashable {
    let monthTimestamp: TimeInterval
    let weekIndex: Int
}

private final class BookingCalendarMonthGapCell: UICollectionViewCell {
    static let reuseId = "BookingCalendarMonthGapCell"
}

private final class BookingCalendarMonthHeaderCell: UICollectionViewCell {
    static let reuseId = "BookingCalendarMonthHeaderCell"
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = Fonts.Content.Title.H4
        label.textColor = Colors.Content.Title
        contentView.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(title: String) {
        label.text = title
    }
}

private final class BookingCalendarWeekdayHeaderCell: UICollectionViewCell {
    static let reuseId = "BookingCalendarWeekdayHeaderCell"
    private let stack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 2
        contentView.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }
        for s in ["L", "M", "M", "J", "V", "S", "D"] {
            let l = UILabel()
            l.text = s
            l.font = Fonts.Content.Text.Bold
            l.textColor = Colors.Content.Text.withAlphaComponent(0.5)
            l.textAlignment = .center
            stack.addArrangedSubview(l)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private final class BookingCalendarWeekRowCell: UICollectionViewCell {
    static let reuseId = "BookingCalendarWeekRowCell"
    private static let horizontalDayGap: CGFloat = 2
    
    private let rowStack = UIStackView()
    private var slotViews: [UIView] = []
    private var dayViews: [BookingDayView] = []
    private var dayDates: [Date?] = Array(repeating: nil, count: 7)
    var onDaySelected: ((Date) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        rowStack.axis = .horizontal
        rowStack.distribution = .fillEqually
        rowStack.spacing = Self.horizontalDayGap
        contentView.addSubview(rowStack)
        rowStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        for i in 0..<7 {
            let slot = UIView()
            slot.isUserInteractionEnabled = false
            let dayView = BookingDayView()
            dayView.tag = i
            slot.addSubview(dayView)
            dayView.snp.makeConstraints { $0.edges.equalToSuperview() }
            slotViews.append(slot)
            dayViews.append(dayView)
            rowStack.addArrangedSubview(slot)
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleDayTap(_:)))
            dayView.addGestureRecognizer(tap)
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayDates = Array(repeating: nil, count: 7)
        onDaySelected = nil
    }
    
    func configure(
        days: [Date?],
        calendar: Calendar,
        contentProvider: (Date) -> BookingDayViewContent
    ) {
        for i in 0..<7 {
            let dateOpt = i < days.count ? days[i] : nil
            dayDates[i] = dateOpt
            let dayView = dayViews[i]
            let slot = slotViews[i]
            let hasDay = dateOpt != nil
            slot.isUserInteractionEnabled = hasDay
            dayView.isUserInteractionEnabled = hasDay
            dayView.isHidden = !hasDay
            
            if let date = dateOpt {
                BookingDayView.setContent(contentProvider(date), on: dayView)
            }
        }
    }
    
    func registerDayViews(into registry: inout [Date: BookingDayView], calendar: Calendar) {
        for i in 0..<7 {
            guard let date = dayDates[i] else { continue }
            registry[calendar.startOfDay(for: date)] = dayViews[i]
        }
    }
    
    func refreshContent(contentProvider: (Date) -> BookingDayViewContent) {
        for i in 0..<7 {
            guard let date = dayDates[i] else { continue }
            BookingDayView.setContent(contentProvider(date), on: dayViews[i])
        }
    }
    
    @objc private func handleDayTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view, view.tag >= 0, view.tag < dayDates.count,
              let date = dayDates[view.tag] else { return }
        onDaySelected?(date)
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
