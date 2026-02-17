//
//  RU_BookingsEntry.swift
//  RentUp
//
//  Created by Michaël Blin on 17/02/2026.
//

import WidgetKit

public class RU_Bookings_TimeLineEntry: TimelineEntry {

    public var date: Date = .init()
    public var currentBooking: RU_Booking?
    public var nextBooking: RU_Booking?
}
