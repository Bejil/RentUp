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
	
	private lazy var revenueTile: MetricStatTileView = .init(
		icon: UIImage(systemName: "eurosign.circle.fill"),
		caption: String(key: "home.dashboard.kpi.revenue")
	)
	private lazy var nightsTile: MetricStatTileView = .init(
		icon: UIImage(systemName: "moon.stars.fill"),
		caption: String(key: "home.dashboard.kpi.nights")
	)
	private lazy var bookingsTile: MetricStatTileView = .init(
		icon: UIImage(systemName: "calendar.badge.clock"),
		caption: String(key: "home.dashboard.kpi.bookings")
	)
	
	private lazy var kpiDivider1: UIView = {
		$0.backgroundColor = Colors.Content.Text.withAlphaComponent(0.12)
		return $0
	}(UIView())
	
	private lazy var kpiDivider2: UIView = {
		$0.backgroundColor = Colors.Content.Text.withAlphaComponent(0.12)
		return $0
	}(UIView())
	
	private lazy var kpiRow: RU_StackView = {
		$0.axis = .horizontal
		$0.distribution = .fillEqually
		$0.alignment = .fill
		$0.addArrangedSubview(revenueTile)
		$0.addArrangedSubview(nightsTile)
		$0.addArrangedSubview(bookingsTile)
		return $0
	}(RU_StackView())
	
	private lazy var kpiContainerView: UIView = {
		let container = UIView()
		container.addSubview(kpiRow)
		container.addSubview(kpiDivider1)
		container.addSubview(kpiDivider2)
		kpiRow.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}
		return container
	}()
	
	private lazy var occupationRing = MetricRingView(
		title: String(key: "home.monthProgress.occupation")
	)
	private lazy var profitabilityRing = MetricRingView(
		title: String(key: "home.monthProgress.profitability")
	)
	
	private lazy var ringsStackView: RU_StackView = {
		$0.axis = .horizontal
		$0.distribution = .fillEqually
		$0.spacing = UI.Margins
		$0.alignment = .top
		$0.addArrangedSubview(occupationRing)
		$0.addArrangedSubview(profitabilityRing)
		return $0
	}(RU_StackView())
	
	private lazy var contentStackView: RU_StackView = {
		$0.axis = .vertical
		$0.spacing = UI.Margins
		$0.isLayoutMarginsRelativeArrangement = true
		$0.layoutMargins = .init(UI.Margins)
		$0.addArrangedSubview(headerStackView)
		$0.addArrangedSubview(kpiContainerView)
		$0.addArrangedSubview(ringsStackView)
		return $0
	}(RU_StackView())
	
	private lazy var metricsCardView: UIView = {
		let card = UIView()
		card.backgroundColor = Colors.Background.View
		card.layer.cornerRadius = UI.CornerRadius
		card.layer.shadowColor = UIColor.black.cgColor
		card.layer.shadowOffset = CGSize(width: 0, height: 4)
		card.layer.shadowOpacity = 0.08
		card.layer.shadowRadius = UI.Margins
		
		card.addSubview(contentStackView)
		contentStackView.snp.makeConstraints { make in
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
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		layoutKPIDividers()
	}
	
	private func layoutKPIDividers() {
		guard kpiContainerView.bounds.width > 0 else { return }
		let inset = UI.Margins
		let width = kpiContainerView.bounds.width
		let height = max(0, kpiContainerView.bounds.height - 2 * inset)
		kpiDivider1.frame = CGRect(x: width / 3, y: inset, width: 1, height: height)
		kpiDivider2.frame = CGRect(x: 2 * width / 3, y: inset, width: 1, height: height)
	}
	
	public func update(bookings: [RU_Booking]?) {
		let metrics = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.self
		let list = metrics.eligibleBookings(bookings ?? [])
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
			metrics.nightsInMonth(
				booking: booking,
				monthStart: monthStart,
				calendar: calendar
			)
		}
		
		let inMonth = list.filter { nightsInMonth($0) > 0 }
		let revenue = inMonth.reduce(0.0) {
			$0 + metrics.proratedHostTotal(booking: $1, monthStart: monthStart, calendar: calendar)
		}
		let nights = inMonth.reduce(0) { $0 + nightsInMonth($1) }
		
		revenueTile.value = metrics.formatNetEUR(revenue)
		nightsTile.value = Self.formatCount(nights)
		bookingsTile.value = Self.formatCount(inMonth.count)
		
		let pastBookings = list.filter { $0.dates.end < now }
		let pastNights = pastBookings.reduce(0) { $0 + nightsInMonth($1) }
		let allNights = list.reduce(0) { $0 + nightsInMonth($1) }
		let occActual = daysInMonth > 0 ? Double(pastNights) / Double(daysInMonth) * 100 : 0
		let occForecast = daysInMonth > 0 ? Double(allNights) / Double(daysInMonth) * 100 : 0
		
		occupationRing.set(actual: occActual, forecast: occForecast)
		
		let hasFees = list.contains { ($0.effectiveClassifiedFees ?? 0) > 0 }
		profitabilityRing.isHidden = !hasFees
		if hasFees {
			let profitability = metrics.profitabilityPercentages(
				monthStart: monthStart,
				bookings: list,
				now: now,
				calendar: calendar
			)
			profitabilityRing.set(actual: profitability.actual, forecast: profitability.forecast)
		}
	}
	
	private static func formatCount(_ value: Int) -> String {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.numberStyle = .decimal
		formatter.groupingSeparator = " "
		formatter.maximumFractionDigits = 0
		return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
	}
}

// MARK: - KPI tile

private final class MetricStatTileView: RU_StackView {
	
	var value: String? {
		get { valueLabel.text }
		set { valueLabel.text = newValue }
	}
	
	private lazy var iconView: UIImageView = {
		$0.contentMode = .scaleAspectFit
		$0.tintColor = Colors.Secondary
		$0.snp.makeConstraints { make in
			make.size.equalTo(2 * UI.Margins)
		}
		return $0
	}(UIImageView())
	
	private lazy var valueLabel: RU_Label = {
		$0.font = Fonts.Content.Title.H3
		$0.textColor = Colors.Primary
		$0.textAlignment = .center
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.55
		return $0
	}(RU_Label())
	
	private lazy var captionLabel: RU_Label = {
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size - 1)
		$0.textColor = Colors.Content.Text.withAlphaComponent(0.5)
		$0.textAlignment = .center
		$0.numberOfLines = 2
		return $0
	}(RU_Label())
	
	init(icon: UIImage?, caption: String) {
		super.init(frame: .zero)
		
		axis = .vertical
		spacing = UI.Margins / 3
		alignment = .center
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(top: UI.Margins / 2, left: UI.Margins / 3, bottom: UI.Margins / 2, right: UI.Margins / 3)
		
		iconView.image = icon?.applyingSymbolConfiguration(.init(pointSize: Fonts.Size + 2, weight: .semibold))
		captionLabel.text = caption
		
		addArrangedSubview(iconView)
		addArrangedSubview(valueLabel)
		addArrangedSubview(captionLabel)
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Ring metric

private final class MetricRingView: RU_StackView {
	
	private lazy var chartView: RU_DonutChart_HostingView = {
		let view = RU_DonutChart_HostingView()
		view.snp.makeConstraints { make in
			make.height.equalTo(view.snp.width)
		}
		return view
	}()
	
	private lazy var titleLabel: RU_Label = {
		$0.font = Fonts.Content.Text.Regular
		$0.textAlignment = .center
		$0.numberOfLines = 2
		return $0
	}(RU_Label())
	
	init(title: String) {
		super.init(frame: .zero)
		
		axis = .vertical
		spacing = UI.Margins / 2
		alignment = .fill
		
		titleLabel.text = title
		addArrangedSubview(chartView)
		addArrangedSubview(titleLabel)
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func set(actual: Double, forecast: Double) {
		// Remplissage = avancement vers le prévisionnel (comme les barres d’origine).
		// Important pour la rentabilité, souvent > 100 %.
		let progress = forecast > 0 ? actual / forecast : 0
		let center = String(format: "%.0f%%", actual)
		let subtitle = String(format: "→ %.0f%%", forecast)
		chartView.configure(
			segments: RU_DonutChart_HostingView.ringSegments(progress: progress),
			style: .ring(centerText: center, subtitle: subtitle),
			innerRadius: 0.68,
			animated: true
		)
	}
}
