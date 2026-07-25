//
//  RU_DonutChart_View.swift
//  RentUp
//

import SwiftUI
import Charts
import UIKit
import SnapKit

public struct RU_DonutChart_View: View {
	
	public struct Segment: Identifiable, Equatable {
		public let id: String
		public let value: Double
		public let color: Color
		public let title: String?
		
		public init(id: String, value: Double, color: Color, title: String? = nil) {
			self.id = id
			self.value = value
			self.color = color
			self.title = title
		}
	}
	
	public enum Style: Equatable {
		case ring(centerText: String, subtitle: String?)
		case multi
	}
	
	let segments: [Segment]
	let style: Style
	let innerRadius: CGFloat
	let animationProgress: Double
	
	public init(
		segments: [Segment],
		style: Style,
		innerRadius: CGFloat = 0.62,
		animationProgress: Double = 1
	) {
		self.segments = segments
		self.style = style
		self.innerRadius = innerRadius
		self.animationProgress = animationProgress
	}
	
	private var chartSegments: [Segment] {
		segments.filter { $0.value > 0 }
	}
	
	public var body: some View {
		ZStack {
			Chart(chartSegments) { segment in
				SectorMark(
					angle: .value("Value", segment.value * animationProgress),
					innerRadius: .ratio(innerRadius),
					angularInset: chartSegments.count > 1 ? 1.5 : 0
				)
				.foregroundStyle(segment.color)
				.cornerRadius(chartSegments.count > 1 ? 2 : 0)
			}
			.chartLegend(.hidden)
			
			if case let .ring(centerText, subtitle) = style {
				VStack(spacing: 2) {
					Text(centerText)
						.font(.custom("TTInterphasesProTrl-Blk", size: Fonts.Size + 11))
						.foregroundStyle(Color(uiColor: Colors.Primary))
						.minimumScaleFactor(0.7)
						.lineLimit(1)
					if let subtitle, !subtitle.isEmpty {
						Text(subtitle)
							.font(.custom("TTInterphasesProTrl-Rg", size: Fonts.Size - 2))
							.foregroundStyle(Color(uiColor: Colors.Content.Text.withAlphaComponent(0.5)))
							.minimumScaleFactor(0.7)
							.lineLimit(1)
					}
				}
				.padding(.horizontal, 8)
			}
		}
	}
}

// MARK: - UIKit host

public final class RU_DonutChart_HostingView: UIView {
	
	private var hostingController: UIHostingController<RU_DonutChart_View>?
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .clear
		isOpaque = false
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func configure(
		segments: [RU_DonutChart_View.Segment],
		style: RU_DonutChart_View.Style,
		innerRadius: CGFloat = 0.62,
		animated: Bool = true
	) {
		let rootView = RU_DonutChart_View(
			segments: segments,
			style: style,
			innerRadius: innerRadius,
			animationProgress: animated ? 0 : 1
		)
		
		if let hostingController {
			hostingController.rootView = rootView
		} else {
			let controller = UIHostingController(rootView: rootView)
			controller.view.backgroundColor = .clear
			controller.view.isOpaque = false
			if #available(iOS 16.4, *) {
				controller.safeAreaRegions = []
			}
			addSubview(controller.view)
			controller.view.snp.makeConstraints { make in
				make.edges.equalToSuperview()
			}
			hostingController = controller
		}
		
		guard animated else { return }
		
		DispatchQueue.main.async {
			withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
				self.hostingController?.rootView = RU_DonutChart_View(
					segments: segments,
					style: style,
					innerRadius: innerRadius,
					animationProgress: 1
				)
			}
		}
	}
	
	public static func ringSegments(progress: Double, fill: UIColor = Colors.Secondary) -> [RU_DonutChart_View.Segment] {
		let clamped = max(0, min(1, progress))
		let remainder = max(0, 1 - clamped)
		var result: [RU_DonutChart_View.Segment] = []
		if clamped > 0 {
			result.append(.init(id: "fill", value: clamped, color: Color(uiColor: fill)))
		}
		if remainder > 0 {
			result.append(.init(
				id: "track",
				value: remainder,
				color: Color(uiColor: Colors.Primary.withAlphaComponent(0.12))
			))
		}
		if result.isEmpty {
			result.append(.init(
				id: "track",
				value: 1,
				color: Color(uiColor: Colors.Primary.withAlphaComponent(0.12))
			))
		}
		return result
	}
	
	public static func paletteColor(at index: Int, platform: RU_Platform? = nil) -> UIColor {
		if let platformColor = platform?.type?.backgroundColor {
			return platformColor
		}
		let palette = [Colors.Secondary, Colors.Primary, Colors.Tertiary]
		return palette[index % palette.count]
	}
}
