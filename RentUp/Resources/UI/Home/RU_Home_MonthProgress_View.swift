//
//  RU_Home_MonthProgress_View.swift
//  RentUp
//

import UIKit
import SnapKit

public class RU_Home_MonthProgress_View: RU_StackView {
	
	private lazy var titleLabel: RU_Label = {
		$0.font = Fonts.Content.Title.H3
		$0.text = String(key: "home.monthProgress.title")
		$0.setContentHuggingPriority(.required, for: .horizontal)
		return $0
	}(RU_Label())
	
	private lazy var monthLabel: RU_Label = {
		$0.font = Fonts.Content.Text.Regular
		$0.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		$0.textAlignment = .right
		return $0
	}(RU_Label())
	
	private lazy var headerStackView: RU_StackView = {
		$0.axis = .horizontal
		$0.spacing = UI.Margins / 2
		$0.alignment = .firstBaseline
		$0.addArrangedSubview(titleLabel)
		$0.addArrangedSubview(monthLabel)
		return $0
	}(RU_StackView())
	
	private lazy var occupationProgressRow = MetricProgressRowView(
		icon: "chart.bar.fill",
		title: String(key: "home.monthProgress.occupation")
	)
	private lazy var profitabilityProgressRow = MetricProgressRowView(
		icon: "eurosign.circle.fill",
		title: String(key: "home.monthProgress.profitability")
	)
	
	private lazy var metricsCardView: UIView = {
		let card = UIView()
		card.backgroundColor = Colors.Background.View
		card.layer.cornerRadius = UI.CornerRadius
		card.layer.shadowColor = UIColor.black.cgColor
		card.layer.shadowOffset = CGSize(width: 0, height: 4)
		card.layer.shadowOpacity = 0.08
		card.layer.shadowRadius = UI.Margins
		
		let stack = RU_StackView(arrangedSubviews: [
			headerStackView,
			occupationProgressRow,
			profitabilityProgressRow
		])
		stack.axis = .vertical
		stack.spacing = UI.Margins
		stack.isLayoutMarginsRelativeArrangement = true
		stack.layoutMargins = .init(UI.Margins)
		
		card.addSubview(stack)
		stack.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		return card
	}()
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		axis = .vertical
		addArrangedSubview(metricsCardView)
		isHidden = true
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func update(bookings: [RU_Booking]?) {
		let list = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.eligibleBookings(bookings ?? [])
		guard !list.isEmpty else {
			isHidden = true
			return
		}
		
		isHidden = false
		
		let calendar = Calendar.current
		let now = Date()
		let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
		let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
		
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.dateFormat = "MMMM yyyy"
		monthLabel.text = formatter.string(from: monthStart).capitalized
		
		func nightsInMonth(_ booking: RU_Booking) -> Int {
			RU_Reporting_Detail_ViewController.ReportingMonthMetrics.nightsInMonth(
				booking: booking,
				monthStart: monthStart,
				calendar: calendar
			)
		}
		
		let pastBookings = list.filter { $0.dates.end < now }
		let pastNights = pastBookings.reduce(0) { $0 + nightsInMonth($1) }
		let allNights = list.reduce(0) { $0 + nightsInMonth($1) }
		let occActual = daysInMonth > 0 ? Double(pastNights) / Double(daysInMonth) * 100 : 0
		let occForecast = daysInMonth > 0 ? Double(allNights) / Double(daysInMonth) * 100 : 0
		
		occupationProgressRow.set(actual: occActual, forecast: occForecast)
		
		let hasFees = list.contains { ($0.classified?.fees ?? 0) > 0 }
		profitabilityProgressRow.isHidden = !hasFees
		if hasFees {
			let profitability = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.profitabilityPercentages(
				monthStart: monthStart,
				bookings: list,
				now: now,
				calendar: calendar
			)
			profitabilityProgressRow.set(actual: profitability.actual, forecast: profitability.forecast)
		}
	}
}

// MARK: - Progress row

private final class MetricProgressRowView: RU_StackView {
	
	/// Remplissage = actual / forecast (le track représente le prévisionnel = 100 %).
	private var fillRatio: Double = 0 {
		didSet {
			shouldAnimateProgress = true
			setNeedsLayout()
		}
	}
	
	private lazy var iconView: UIImageView = {
		$0.contentMode = .scaleAspectFit
		$0.tintColor = Colors.Secondary
		$0.snp.makeConstraints { make in
			make.size.equalTo(1.5 * UI.Margins)
		}
		return $0
	}(UIImageView())
	
	private lazy var titleLabel: RU_Label = {
		$0.font = Fonts.Content.Text.Regular
		return $0
	}(RU_Label())
	
	private lazy var percentageLabel: RU_Label = {
		$0.font = Fonts.Content.Title.H4
		$0.textAlignment = .right
		$0.setContentHuggingPriority(.required, for: .horizontal)
		return $0
	}(RU_Label())
	
	private lazy var headerStackView: RU_StackView = {
		$0.axis = .horizontal
		$0.spacing = UI.Margins / 2
		$0.alignment = .center
		$0.addArrangedSubview(iconView)
		$0.addArrangedSubview(titleLabel)
		$0.addArrangedSubview(UIView())
		$0.addArrangedSubview(percentageLabel)
		return $0
	}(RU_StackView())
	
	private lazy var progressTrackView: UIView = {
		$0.backgroundColor = Colors.Primary.withAlphaComponent(0.12)
		$0.layer.cornerRadius = 3
		$0.clipsToBounds = true
		$0.snp.makeConstraints { make in
			make.height.equalTo(6)
		}
		return $0
	}(UIView())
	
	private lazy var progressFillView: UIView = {
		$0.backgroundColor = Colors.Secondary
		$0.layer.cornerRadius = 3
		return $0
	}(UIView())
	
	private var progressFillWidthConstraint: Constraint?
	private var shouldAnimateProgress = true
	
	init(icon: String, title: String) {
		super.init(frame: .zero)
		
		axis = .vertical
		spacing = UI.Margins / 2
		
		iconView.image = UIImage(systemName: icon)?.applyingSymbolConfiguration(.init(scale: .medium))
		titleLabel.text = title
		
		addArrangedSubview(headerStackView)
		addArrangedSubview(progressTrackView)
		progressTrackView.addSubview(progressFillView)
		progressFillView.snp.makeConstraints { make in
			make.top.bottom.leading.equalToSuperview()
			progressFillWidthConstraint = make.width.equalTo(0).constraint
		}
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func set(actual: Double, forecast: Double) {
		percentageLabel.text = String(format: "%.0f%% (→ %.0f%%)", actual, forecast)
		fillRatio = forecast > 0 ? min(1, actual / forecast) : 0
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		guard progressTrackView.bounds.width > 0 else { return }
		
		let targetWidth = max(0, min(1, fillRatio)) * progressTrackView.bounds.width
		
		if shouldAnimateProgress {
			shouldAnimateProgress = false
			progressFillWidthConstraint?.update(offset: 0)
			progressTrackView.layoutIfNeeded()
			
			UIView.animate(
				withDuration: 0.55,
				delay: 0.05,
				usingSpringWithDamping: 0.82,
				initialSpringVelocity: 0.6,
				options: [.curveEaseOut]
			) {
				self.progressFillWidthConstraint?.update(offset: targetWidth)
				self.progressTrackView.layoutIfNeeded()
			}
		} else {
			progressFillWidthConstraint?.update(offset: targetWidth)
		}
	}
}
