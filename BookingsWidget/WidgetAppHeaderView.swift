//
//  WidgetAppHeaderView.swift
//  BookingsWidget
//

import SwiftUI

enum WidgetBranding {
	static let appName = "BienGéré"
}

struct WidgetAppHeaderView: View {
	
	let classifiedName: String?
	let monthTitle: String?
	let isCompact: Bool
	
	private var iconSize: CGFloat { isCompact ? 18 : 22 }
	private var appNameFontSize: CGFloat { isCompact ? 12 : 14 }
	private var classifiedFontSize: CGFloat { isCompact ? 11 : 13 }
	private var iconCornerRadius: CGFloat { isCompact ? 4 : 5 }
	
	var body: some View {
		HStack(alignment: .center, spacing: 8) {
			HStack(spacing: 6) {
				Image("AppIcon")
					.resizable()
					.scaledToFit()
					.frame(width: iconSize, height: iconSize)
					.clipShape(RoundedRectangle(cornerRadius: iconCornerRadius, style: .continuous))
				
				Text(WidgetBranding.appName)
					.font(.system(size: appNameFontSize, weight: .black))
					.foregroundStyle(WidgetColors.text)
					.lineLimit(1)
					.minimumScaleFactor(0.85)
			}
			
			Spacer(minLength: 8)
			
			if classifiedName != nil || monthTitle != nil {
				VStack(alignment: .trailing, spacing: 1) {
					if let classifiedName {
						Text(classifiedName)
							.font(.system(size: classifiedFontSize, weight: .black))
							.foregroundStyle(WidgetColors.text)
							.lineLimit(1)
							.minimumScaleFactor(0.8)
					}
					if let monthTitle {
						Text(monthTitle)
							.font(.system(size: isCompact ? 10 : 12, weight: .bold))
							.foregroundStyle(WidgetColors.mutedText)
							.lineLimit(1)
							.minimumScaleFactor(0.85)
					}
				}
			}
		}
	}
}
