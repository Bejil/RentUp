//
//  RU_Reporting_BookingDistribution.swift
//  RentUp
//

import Foundation

public enum RU_Reporting_BookingDistribution {
	
	public enum Dimension: CaseIterable {
		case travelers, doubleBeds, singleBeds, babyBeds, platforms, stayLength, revenue, checkInWeekday, checkInSeason, familyProfile, classified
		
		var title: String {
			switch self {
			case .travelers: return String(key: "reporting.detail.general.dimension.travelers")
			case .doubleBeds: return String(key: "reporting.detail.general.dimension.doubleBeds")
			case .singleBeds: return String(key: "reporting.detail.general.dimension.singleBeds")
			case .babyBeds: return String(key: "reporting.detail.general.dimension.babyBeds")
			case .platforms: return String(key: "reporting.detail.general.dimension.platforms")
			case .stayLength: return String(key: "reporting.detail.general.dimension.stayLength")
			case .revenue: return String(key: "reporting.detail.general.dimension.revenue")
			case .checkInWeekday: return String(key: "reporting.detail.general.dimension.checkInWeekday")
			case .checkInSeason: return String(key: "reporting.detail.general.dimension.checkInSeason")
			case .familyProfile: return String(key: "reporting.detail.general.dimension.familyProfile")
			case .classified: return String(key: "reporting.detail.general.dimension.classified")
			}
		}
		
		var icon: String {
			switch self {
			case .travelers: return "person.2.fill"
			case .doubleBeds: return "bed.double.fill"
			case .singleBeds: return "bed.double"
			case .babyBeds: return "stroller"
			case .platforms: return "square.grid.2x2"
			case .stayLength: return "moon.zzz.fill"
			case .revenue: return "eurosign.circle.fill"
			case .checkInWeekday: return "calendar"
			case .checkInSeason: return "leaf.fill"
			case .familyProfile: return "figure.2.and.child.holdinghands"
			case .classified: return "house.fill"
			}
		}
		
		var distributionSubtitle: String {
			switch self {
			case .revenue: return String(key: "reporting.detail.general.distribution.subtitle.revenue")
			default: return String(key: "reporting.detail.general.distribution.subtitle")
			}
		}
	}
	
	public enum SortOrder: CaseIterable {
		case percentageDesc, percentageAsc, countDesc, titleAsc
		
		var title: String {
			switch self {
			case .percentageDesc: return String(key: "reporting.detail.general.sort.percentageDesc")
			case .percentageAsc: return String(key: "reporting.detail.general.sort.percentageAsc")
			case .countDesc: return String(key: "reporting.detail.general.sort.countDesc")
			case .titleAsc: return String(key: "reporting.detail.general.sort.titleAsc")
			}
		}
	}
	
	public struct Item {
		let key: String
		let title: String
		let icon: String?
		let platform: RU_Platform?
		let count: Int
		let percentage: Double
		let detailText: String?
		
		init(key: String, title: String, icon: String?, platform: RU_Platform? = nil, count: Int, percentage: Double, detailText: String? = nil) {
			self.key = key
			self.title = title
			self.icon = icon
			self.platform = platform
			self.count = count
			self.percentage = percentage
			self.detailText = detailText
		}
	}
	
	public static func sort(_ items: [Item], by order: SortOrder) -> [Item] {
		switch order {
		case .percentageDesc:
			return items.sorted { $0.percentage == $1.percentage ? $0.title < $1.title : $0.percentage > $1.percentage }
		case .percentageAsc:
			return items.sorted { $0.percentage == $1.percentage ? $0.title < $1.title : $0.percentage < $1.percentage }
		case .countDesc:
			return items.sorted { $0.count == $1.count ? $0.title < $1.title : $0.count > $1.count }
		case .titleAsc:
			return items.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
		}
	}
	
	public static func compute(for dimension: Dimension, bookings: [RU_Booking]) -> [Item] {
		switch dimension {
		case .revenue:
			return computeRevenueDistribution(bookings: bookings)
		case .platforms:
			return computePlatformsDistribution(bookings: bookings)
		default:
			break
		}
		
		let total = bookings.count
		guard total > 0 else { return [] }
		
		var counts: [String: (title: String, icon: String?, count: Int)] = [:]
		let calendar = Calendar.current
		
		func add(_ key: String, title: String, icon: String? = nil) {
			let existing = counts[key]
			counts[key] = (title, icon ?? existing?.icon, (existing?.count ?? 0) + 1)
		}
		
		for booking in bookings {
			switch dimension {
			case .travelers:
				let guests = max(1, (booking.travelers.adults ?? 0) + (booking.travelers.children ?? 0) + (booking.travelers.babies ?? 0))
				let key = guests >= 5 ? "5+" : "\(guests)"
				let title = guests >= 5
					? String(key: "reporting.detail.general.travelers.5plus")
					: String(format: String(key: "reporting.detail.general.travelers.format"), guests)
				add(key, title: title, icon: "person.fill")
				
			case .doubleBeds:
				let n = booking.beds.doubles ?? 0
				let key = n >= 3 ? "3+" : "\(n)"
				let title = n >= 3
					? String(key: "reporting.detail.general.beds.double.3plus")
					: String(format: String(key: "reporting.detail.general.beds.double.format"), n)
				add(key, title: title, icon: "bed.double.fill")
				
			case .singleBeds:
				let n = booking.beds.singles ?? 0
				let key = n >= 3 ? "3+" : "\(n)"
				let title = n >= 3
					? String(key: "reporting.detail.general.beds.single.3plus")
					: String(format: String(key: "reporting.detail.general.beds.single.format"), n)
				add(key, title: title, icon: "bed.double")
				
			case .babyBeds:
				let hasBabyBed = (booking.beds.babies ?? 0) > 0
				let key = hasBabyBed ? "yes" : "no"
				let title = hasBabyBed
					? String(key: "reporting.detail.general.beds.baby.yes")
					: String(key: "reporting.detail.general.beds.baby.no")
				add(key, title: title, icon: hasBabyBed ? "stroller" : "stroller.fill")
				
			case .platforms:
				break
				
			case .stayLength:
				let nights = max(0, calendar.dateComponents([.day], from: booking.dates.start, to: booking.dates.end).day ?? 0)
				let key: String
				let title: String
				switch nights {
				case 0...1:
					key = "1"; title = String(key: "reporting.detail.general.stayLength.1")
				case 2...3:
					key = "2-3"; title = String(key: "reporting.detail.general.stayLength.2_3")
				case 4...7:
					key = "4-7"; title = String(key: "reporting.detail.general.stayLength.4_7")
				case 8...14:
					key = "8-14"; title = String(key: "reporting.detail.general.stayLength.8_14")
				default:
					key = "15+"; title = String(key: "reporting.detail.general.stayLength.15plus")
				}
				add(key, title: title, icon: "moon.fill")
				
			case .revenue:
				break
				
			case .checkInWeekday:
				let weekday = calendar.component(.weekday, from: booking.dates.start)
				let key = "\(weekday)"
				let formatter = DateFormatter()
				formatter.locale = Locale(identifier: "fr_FR")
				let title = formatter.weekdaySymbols[weekday - 1].capitalized
				add(key, title: title, icon: "calendar")
				
			case .checkInSeason:
				let month = calendar.component(.month, from: booking.dates.start)
				let key = "\(month)"
				let formatter = DateFormatter()
				formatter.locale = Locale(identifier: "fr_FR")
				let title = formatter.monthSymbols[month - 1].capitalized
				add(key, title: title, icon: "leaf.fill")
				
			case .familyProfile:
				let children = booking.travelers.children ?? 0
				let babies = booking.travelers.babies ?? 0
				let key: String
				let title: String
				let icon: String
				if babies > 0 {
					key = "baby"; title = String(key: "reporting.detail.general.family.baby"); icon = "figure.and.child.holdinghands"
				} else if children > 0 {
					key = "children"; title = String(key: "reporting.detail.general.family.children"); icon = "figure.2.and.child.holdinghands"
				} else {
					key = "adults"; title = String(key: "reporting.detail.general.family.adults"); icon = "person.2.fill"
				}
				add(key, title: title, icon: icon)
				
			case .classified:
				let name = booking.classified?.name ?? String(key: "reporting.detail.general.unknown")
				add(booking.classified?.uuid ?? name, title: name, icon: "house.fill")
			}
		}
		
		return counts.map { key, value in
			Item(
				key: key,
				title: value.title,
				icon: value.icon,
				count: value.count,
				percentage: Double(value.count) / Double(total) * 100
			)
		}
	}
	
	private static func computePlatformsDistribution(bookings: [RU_Booking]) -> [Item] {
		let total = bookings.count
		guard total > 0 else { return [] }
		
		struct Bucket {
			var platform: RU_Platform?
			var title: String
			var count: Int = 0
		}
		
		var buckets: [String: Bucket] = [:]
		
		for booking in bookings {
			let name = booking.platform?.type?.name ?? String(key: "reporting.detail.general.unknown")
			let key = booking.platform?.uuid ?? name
			var bucket = buckets[key] ?? Bucket(platform: booking.platform, title: name)
			if bucket.platform == nil { bucket.platform = booking.platform }
			bucket.count += 1
			buckets[key] = bucket
		}
		
		return buckets.map { key, bucket in
			Item(
				key: key,
				title: bucket.title,
				icon: nil,
				platform: bucket.platform,
				count: bucket.count,
				percentage: Double(bucket.count) / Double(total) * 100
			)
		}
	}
	
	private static func computeRevenueDistribution(bookings: [RU_Booking]) -> [Item] {
		guard !bookings.isEmpty else { return [] }
		
		struct Bucket {
			var platform: RU_Platform?
			var title: String
			var count: Int = 0
			var revenue: Double = 0
			var nights: Int = 0
		}
		
		var buckets: [String: Bucket] = [:]
		let calendar = Calendar.current
		var totalRevenue: Double = 0
		
		for booking in bookings {
			let name = booking.platform?.type?.name ?? String(key: "reporting.detail.general.unknown")
			let key = booking.platform?.uuid ?? name
			let nights = max(1, calendar.dateComponents([.day], from: booking.dates.start, to: booking.dates.end).day ?? 1)
			let revenue = booking.platform?.calculatePrice(for: booking)?.hostTotal ?? 0
			totalRevenue += revenue
			
			var bucket = buckets[key] ?? Bucket(platform: booking.platform, title: name)
			if bucket.platform == nil { bucket.platform = booking.platform }
			bucket.count += 1
			bucket.revenue += revenue
			bucket.nights += nights
			buckets[key] = bucket
		}
		
		return buckets.map { key, bucket in
			let avgPerNight = bucket.nights > 0 ? bucket.revenue / Double(bucket.nights) : 0
			let percentage = totalRevenue > 0 ? bucket.revenue / totalRevenue * 100 : 0
			let detailText = String(
				format: String(key: "reporting.detail.general.revenue.platformDetailFormat"),
				formatNetEUR(bucket.revenue),
				formatNetEUR(avgPerNight),
				bucket.count
			)
			return Item(
				key: key,
				title: bucket.title,
				icon: nil,
				platform: bucket.platform,
				count: bucket.count,
				percentage: percentage,
				detailText: detailText
			)
		}
	}
	
	private static func formatNetEUR(_ value: Double) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = Locale(identifier: "fr_FR")
		formatter.currencyCode = "EUR"
		formatter.maximumFractionDigits = 0
		return formatter.string(from: NSNumber(value: value)) ?? "—"
	}
}
