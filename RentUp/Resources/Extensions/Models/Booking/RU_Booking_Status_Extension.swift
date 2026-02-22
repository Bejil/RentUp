//
//  RU_Booking.swift
//  RentUp
//
//  Created by BLIN Michael on 21/01/2026.
//

import UIKit

extension RU_Booking.Status {
    
    public var backgroundColor: UIColor {
        
        switch self {
        case .past:
            return Colors.Booking.Status.Past.Background
        case .current:
            return Colors.Booking.Status.Current.Background
        case .upcoming:
            return Colors.Booking.Status.Upcoming.Background
        case .cancelled:
            return Colors.Booking.Status.Cancelled.Background
        }
    }
    
    public var textColor: UIColor {
        
        switch self {
        case .past:
            return Colors.Booking.Status.Past.Text
        case .current:
            return Colors.Booking.Status.Current.Text
        case .upcoming:
            return Colors.Booking.Status.Upcoming.Text
        case .cancelled:
            return Colors.Booking.Status.Cancelled.Text
        }
    }
}
