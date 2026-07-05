//
//  RU_Reporting_General_KPI_View.swift
//  RentUp
//

import UIKit
import SnapKit

public class RU_Reporting_General_KPI_View: RU_StackView {
	
	private lazy var totalNightsTile: MetricStatTileView = .init(
		icon: UIImage(systemName: "moon.stars.fill"),
		caption: String(key: "reporting.main.totalNights.short")
	)
	private lazy var bookingCountTile: MetricStatTileView = .init(
		icon: UIImage(systemName: "calendar.badge.clock"),
		caption: String(key: "reporting.main.bookingCount.short")
	)
	
	private lazy var metricsDivider: UIView = {
		$0.backgroundColor = Colors.Content.Text.withAlphaComponent(0.12)
		return $0
	}(UIView())
	
	private lazy var metricsRow: RU_StackView = {
		$0.axis = .horizontal
		$0.distribution = .fillEqually
		$0.alignment = .fill
		$0.addArrangedSubview(totalNightsTile)
		$0.addArrangedSubview(bookingCountTile)
		return $0
	}(RU_StackView())
	
	private lazy var metricsCardView: UIView = {
		$0.backgroundColor = Colors.Background.View
		$0.layer.cornerRadius = UI.CornerRadius
		$0.layer.shadowColor = UIColor.black.cgColor
		$0.layer.shadowOffset = CGSize(width: 0, height: 4)
		$0.layer.shadowOpacity = 0.08
		$0.layer.shadowRadius = UI.Margins
		$0.addSubview(metricsRow)
		$0.addSubview(metricsDivider)
		metricsRow.snp.makeConstraints { make in
			make.edges.equalToSuperview().inset(UI.Margins)
		}
		metricsDivider.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.bottom.equalToSuperview().inset(UI.Margins * 1.5)
			make.width.equalTo(1)
		}
		return $0
	}(UIView())
	
	private lazy var sectionStackView: RU_Section_StackView = {
		$0.title = String(key: "reporting.section.main")
		$0.addArrangedSubview(metricsCardView)
		return $0
	}(RU_Section_StackView())
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		
		axis = .vertical
		spacing = UI.Margins
		addArrangedSubview(sectionStackView)
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func update(bookings: [RU_Booking]) {
		let metrics = RU_Reporting_Detail_ViewController.ReportingMonthMetrics.mainKPIs(bookings: bookings)
		
		if metrics.bookingCount > 0 {
			totalNightsTile.value = Self.formatCount(metrics.totalNights)
			bookingCountTile.value = Self.formatCount(metrics.bookingCount)
		} else {
			totalNightsTile.value = String(key: "reporting.main.value.noData")
			bookingCountTile.value = String(key: "reporting.main.value.noData")
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
		$0.font = Fonts.Content.Title.H2
		$0.textColor = Colors.Primary
		$0.textAlignment = .center
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.7
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
		layoutMargins = .init(top: UI.Margins / 2, left: UI.Margins / 2, bottom: UI.Margins / 2, right: UI.Margins / 2)
		
		iconView.image = icon?.applyingSymbolConfiguration(.init(pointSize: Fonts.Size + 4, weight: .semibold))
		captionLabel.text = caption
		
		addArrangedSubview(iconView)
		addArrangedSubview(valueLabel)
		addArrangedSubview(captionLabel)
	}
	
	@MainActor required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
