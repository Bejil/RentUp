//
//  RU_Bookings_Edit_Calendar_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 23/02/2026.
//

import UIKit
import SnapKit

public class RU_Bookings_Edit_Calendar_ViewController: RU_Bookings_Calendar_ViewController {

    internal override var calendarSupportsLazyForwardLoading: Bool { true }
    
    public var currentBooking: RU_Booking? {
        didSet {
            selectedStartDate = nil
            if isEditingExistingBooking,
               let current = currentBooking,
               !current.isCancelled {
                let start = normalizedCalendarDay(current.dates.start)
                let end = normalizedCalendarDay(current.dates.end)
                secondaryHighlightRanges = normalizedSecondaryRanges([start...end])
                updateButtonSubtitle(from: start, to: end)
            } else if let current = currentBooking {
                restorePresetArrivalIfNeeded(from: current)
            } else {
                secondaryHighlightRanges = nil
                button.subtitle = nil
            }
        }
    }
    private var selectedStartDate: Date?
    public var didSelectRange: ((Date, Date) -> Void)?
    
    private var isEditingExistingBooking: Bool {
        guard let id = currentBooking?.id, !id.isEmpty else { return false }
        return true
    }
    
    private var todayStart: Date {
        normalizedCalendarDay(Date())
    }
    
    private func isPastDayBlocked(_ day: Date) -> Bool {
        !isEditingExistingBooking && day < todayStart
    }
    private lazy var button:RU_Button = {
        
        $0.image = UIImage(systemName: "square.and.arrow.down")
        return $0
        
    }(RU_Button(String(key: "bookings.calendar.validate")) { [weak self] _ in
        guard let self else { return }
        if let range = self.secondaryHighlightRanges?.first {
            self.didSelectRange?(range.lowerBound, range.upperBound)
        }
    })
    
    public override func loadView() {
        
        super.loadView()
        
        isModal = true
        
        view.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.right.bottom.left.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottomInset = button.bounds.height + 2 * UI.Margins
        if let collectionView = view as? UICollectionView {
            collectionView.contentInset.bottom = bottomInset
            collectionView.verticalScrollIndicatorInsets.bottom = bottomInset
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let start = selectedStartDate {
            scrollToMonthContaining(start, animated: false)
        }
    }

    internal override func calendarDidSelectDay(_ date: Date) {
        handleDaySelection(date: date)
    }
    
    internal override func handleDaySelection(date tappedDate: Date) {
        let tappedDay = normalizedCalendarDay(tappedDate)

        if let start = selectedStartDate {
            let rangeStart = min(start, tappedDay)
            let rangeEnd = max(start, tappedDay)
            
            if isPastDayBlocked(rangeStart) || isPastDayBlocked(rangeEnd) {
                clearSelection(showPastDateError: true)
                return
            }
            
            guard isValidDepartureDay(rangeEnd),
                  isValidArrivalDay(rangeStart),
                  !intervalContainsInteriorBookings(from: rangeStart, to: rangeEnd) else {
                clearSelection(showSelectionError: true)
                return
            }
            
            secondaryHighlightRanges = normalizedSecondaryRanges([rangeStart...rangeEnd])
            selectedStartDate = nil
            updateButtonSubtitle(from: rangeStart, to: rangeEnd)
        } else {
            if isPastDayBlocked(tappedDay) {
                presentPastDateError()
                return
            }
            
            guard isValidArrivalDay(tappedDay) else {
                presentSelectionError()
                return
            }
            
            selectedStartDate = tappedDay
            secondaryHighlightRanges = normalizedSecondaryRanges([tappedDay...tappedDay])
            updateButtonSubtitle(from: tappedDay, to: tappedDay)
        }
    }

    private func blockingBookingsForProperty() -> [RU_Booking] {
        (bookings ?? []).filter { booking in
            !booking.isCancelled && !isCurrentBooking(booking) && isSameProperty(as: booking)
        }
    }
    
    private func isCurrentBooking(_ booking: RU_Booking) -> Bool {
        guard let current = currentBooking else { return false }
        if !current.uuid.isEmpty, current.uuid == booking.uuid { return true }
        if let currentID = current.id, let bookingID = booking.id, currentID == bookingID { return true }
        return false
    }
    
    private func isSameProperty(as booking: RU_Booking) -> Bool {
        guard let currentClassified = currentBooking?.classified else { return true }
        if !currentClassified.uuid.isEmpty {
            return booking.classified?.uuid == currentClassified.uuid
        }
        if let id = currentClassified.id {
            return booking.classified?.id == id
        }
        return true
    }
    
    private func bookingBounds(for booking: RU_Booking) -> (start: Date, end: Date) {
        (
            normalizedCalendarDay(booking.dates.start),
            normalizedCalendarDay(booking.dates.end)
        )
    }
    
    /// Arrivée : jour libre ou fin d’une autre réservation (checkout).
    private func isValidArrivalDay(_ day: Date) -> Bool {
        for booking in blockingBookingsForProperty() {
            let bounds = bookingBounds(for: booking)
            guard day >= bounds.start && day <= bounds.end else { continue }
            if day == bounds.end { continue }
            return false
        }
        return true
    }
    
    /// Départ : jour libre ou début d’une autre réservation (check-in).
    private func isValidDepartureDay(_ day: Date) -> Bool {
        for booking in blockingBookingsForProperty() {
            let bounds = bookingBounds(for: booking)
            guard day >= bounds.start && day <= bounds.end else { continue }
            if day == bounds.start { continue }
            return false
        }
        return true
    }
    
    /// Jours strictement entre arrivée et départ : aucune autre réservation.
    private func intervalContainsInteriorBookings(from start: Date, to end: Date) -> Bool {
        guard start < end else { return false }
        let cal = bookingDisplayCalendar
        guard var day = cal.date(byAdding: .day, value: 1, to: start) else { return false }
        while day < end {
            for booking in blockingBookingsForProperty() {
                let bounds = bookingBounds(for: booking)
                if day >= bounds.start && day <= bounds.end {
                    return true
                }
            }
            guard let next = cal.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return false
    }
    
    private func restorePresetArrivalIfNeeded(from current: RU_Booking) {
        let start = normalizedCalendarDay(current.dates.start)
        let end = normalizedCalendarDay(current.dates.end)
        guard bookingDisplayCalendar.isDate(start, inSameDayAs: end) else { return }
        selectedStartDate = start
        secondaryHighlightRanges = normalizedSecondaryRanges([start...start])
        updateButtonSubtitle(from: start, to: end)
    }
    
    private func clearSelection(showSelectionError: Bool = false, showPastDateError: Bool = false) {
        selectedStartDate = nil
        if isEditingExistingBooking,
           let current = currentBooking,
           !current.isCancelled {
            let start = normalizedCalendarDay(current.dates.start)
            let end = normalizedCalendarDay(current.dates.end)
            secondaryHighlightRanges = normalizedSecondaryRanges([start...end])
            updateButtonSubtitle(from: start, to: end)
        } else if let current = currentBooking {
            restorePresetArrivalIfNeeded(from: current)
        } else {
            secondaryHighlightRanges = nil
            button.subtitle = nil
        }
        if showPastDateError {
            presentPastDateError()
        } else if showSelectionError {
            presentSelectionError()
        }
    }
    
    private func presentSelectionError() {
        RU_Alert_ViewController.present(RU_Error(String(key: "bookings.calendar.edit.selection.error")))
    }
    
    private func presentPastDateError() {
        RU_Alert_ViewController.present(RU_Error(String(key: "bookings.calendar.edit.pastDate.error")))
    }

    private func updateButtonSubtitle(from start: Date, to end: Date) {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: "fr_FR")
        if bookingDisplayCalendar.isDate(start, inSameDayAs: end) {
            button.subtitle = df.string(from: start)
        } else {
            button.subtitle = "\(df.string(from: start)) – \(df.string(from: end))"
        }
    }
}
