//
//  RU_Bookings_Edit_Calendar_ViewController.swift
//  RentUp
//
//  Created by Michaël Blin on 23/02/2026.
//

import UIKit
import SnapKit

public class RU_Bookings_Edit_Calendar_ViewController: RU_Bookings_Calendar_ViewController {

    public var currentBooking: RU_Booking? {
        didSet {
            selectedStartDate = nil
            let calendar = Calendar.current
            if let current = currentBooking, !current.isCancelled {
                let start = calendar.startOfDay(for: current.dates.start)
                let end = calendar.startOfDay(for: current.dates.end)
                secondaryHighlightRanges = [start...end]
                updateButtonSubtitle(from: start, to: end)
            } else {
                secondaryHighlightRanges = nil
                button.subtitle = nil
            }
        }
    }
    private var selectedStartDate: Date?
    public var didSelectRange: ((Date, Date) -> Void)?
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

    internal override func handleDaySelection(date tappedDate: Date) {
        let calendar = Calendar.current
        let tappedStart = calendar.startOfDay(for: tappedDate)

        if let start = selectedStartDate {
            let rangeStart = min(start, tappedStart)
            let rangeEnd = max(start, tappedStart)
            secondaryHighlightRanges = [rangeStart...rangeEnd]
            selectedStartDate = nil
            updateButtonSubtitle(from: rangeStart, to: rangeEnd)
        } else {
            selectedStartDate = tappedStart
            secondaryHighlightRanges = [tappedStart...tappedStart]
            updateButtonSubtitle(from: tappedStart, to: tappedStart)
        }
    }

    private func updateButtonSubtitle(from start: Date, to end: Date) {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.locale = Locale(identifier: "fr_FR")
        if Calendar.current.isDate(start, inSameDayAs: end) {
            button.subtitle = df.string(from: start)
        } else {
            button.subtitle = "\(df.string(from: start)) – \(df.string(from: end))"
        }
    }
}
