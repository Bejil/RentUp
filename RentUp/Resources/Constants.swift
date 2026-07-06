//
//  Constants.swift
//  RentUp
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit

public struct UI {
	
	static var MainController :UIViewController {
		
		return UIApplication.shared.topMostViewController()!
	}
    
	public static let Margins:CGFloat = 15.0
	public static let CornerRadius:CGFloat = 18.0
	
	/// Largeur max du contenu sur iPad / Mac (évite l’étirement pleine largeur).
	public static let ContentMaxWidth: CGFloat = 760
	/// Largeur max du calendrier (grille 7 jours lisible).
	public static let CalendarMaxWidth: CGFloat = 680
	/// Largeur fixe de la sidebar iPad (max système, non redimensionnable).
	public static let SidebarWidth: CGFloat = 320
	
	public static func adaptiveMargins(for traitCollection: UITraitCollection) -> CGFloat {
		traitCollection.isRegularWidth ? 24 : Margins
	}
}

public struct Colors {
	
	public static let Primary:UIColor = UIColor(named: "Primary")!
	public static let Secondary:UIColor = UIColor(named: "Secondary")!
	public static let Tertiary:UIColor = UIColor(named: "Tertiary")!
	
	public struct Background {
		
		public static let Application:UIColor = UIColor(named: "ApplicationBackground")!
		public static let View:UIColor = UIColor(named: "ViewBackground")!
	}
	
	public struct Navigation {
		
		public static let Title:UIColor = UIColor(named: "NavigationTitle")!
        public static let Button:UIColor = Colors.Primary
	}
	
	public struct TabBar {
	
        public static let Badge:UIColor = Colors.Tertiary
        public static let Selected:UIColor = Colors.Primary
	}
	
	public struct SegmentedControl {
		
		public struct Background {
			
			public static let Default:UIColor = UIColor(named: "SegmentedControlBackgroundDefault")!
            public static let Selected:UIColor = Colors.Primary
		}
		
		public struct Text {
			
			public static let Default:UIColor = UIColor(named: "SegmentedControlTextDefault")!
			public static let Selected:UIColor = UIColor(named: "SegmentedControlTextSelected")!
		}
	}
	
	public struct Stepper {
		
        public static let TintColor:UIColor = Colors.Primary
	}
	
	public struct Tip {
		
        public static let Background:UIColor = Colors.Tertiary.withAlphaComponent(0.15)
        public static let Icon:UIColor = Colors.Tertiary
	}
	
	public struct TextField {
		
        public static let TintColor:UIColor = Colors.Primary
	}
	
	public struct TableView {
		
        public static let Tint:UIColor = Colors.Primary
	}
	
	public struct Content {
		
		public static let Title:UIColor = UIColor(named: "ContentTitle")!
		public static let Text:UIColor = UIColor(named: "ContentText")!
	}
	
	public struct DatePicker {
		
        public static let TintColor:UIColor = Colors.Primary
	}
	
	public struct Button {
		
		public static let Badge:UIColor = UIColor(named: "ButtonBadge")!
		
		public struct Primary {
			
            public static let Background:UIColor = Colors.Primary
			public static let Content:UIColor = UIColor(named: "ButtonPrimaryContent")!
		}
		
		public struct Secondary {
			
            public static let Background:UIColor = Colors.Secondary
			public static let Content:UIColor = UIColor(named: "ButtonSecondaryContent")!
		}
		
		public struct Tertiary {
			
            public static let Background:UIColor = Colors.Tertiary
			public static let Content:UIColor = UIColor(named: "ButtonTertiaryContent")!
		}
		
		public struct Delete {
			
			public static let Background:UIColor = UIColor(named: "ButtonDeleteBackground")!
			public static let Content:UIColor = UIColor(named: "ButtonDeleteContent")!
		}
		
		public struct Navigation {
			
			public static let Background:UIColor = UIColor(named: "ButtonNavigationBackground")!
            public static let Content:UIColor = Colors.Primary
		}
		
		public struct Text {
			
			public static let Background:UIColor = UIColor(named: "ButtonTextBackground")!
            public static let Content:UIColor = Colors.Primary
		}
	}
	
	public struct Platform {
		
		public struct Background {
			
			public static let Airbnb:UIColor = UIColor(named: "PlatformBackgroundAirbnb")!
			public static let Booking:UIColor = UIColor(named: "PlatformBackgroundBooking")!
			public static let Abritel:UIColor = UIColor(named: "PlatformBackgroundAbritel")!
            public static let Direct:UIColor = UIColor(named: "PlatformBackgroundDirect")!
		}
		
		public struct Text {
			
			public static let Airbnb:UIColor = UIColor(named: "PlatformTextAirbnb")!
			public static let Booking:UIColor = UIColor(named: "PlatformTextBooking")!
			public static let Abritel:UIColor = UIColor(named: "PlatformTextAbritel")!
            public static let Direct:UIColor = UIColor(named: "PlatformTextDirect")!
		}
	}
	
	public struct Booking {
		
		public struct Status {
			
			public struct Current {
				
				public static let Background:UIColor = UIColor(named: "BookingStatusCurrentBackground")!
				public static let Text:UIColor = UIColor(named: "BookingStatusCurrentText")!
			}
			
			public struct Past {
				
				public static let Background:UIColor = UIColor(named: "BookingStatusPastBackground")!
				public static let Text:UIColor = UIColor(named: "BookingStatusPastText")!
			}
			
			public struct Upcoming {
				
				public static let Background:UIColor = UIColor(named: "BookingStatusUpcomingBackground")!
				public static let Text:UIColor = UIColor(named: "BookingStatusUpcomingText")!
			}
            
            public struct Cancelled {
                
                public static let Background:UIColor = UIColor(named: "BookingStatusCancelledBackground")!
                public static let Text:UIColor = UIColor(named: "BookingStatusCancelledText")!
            }
		}
	}
}

public struct Fonts {
	
	private struct Name {
		
		static let Regular:String = "TTInterphasesProTrl-Rg"
		static let Bold:String = "TTInterphasesProTrl-Bd"
		static let Black:String = "TTInterphasesProTrl-Blk"
	}
	
	public static let Size:CGFloat = 13
	
	public struct Navigation {
		
		public struct Title {
			
			public static let Large:UIFont = UIFont(name: Name.Black, size: Fonts.Size+25)!
			public static let Small:UIFont = UIFont(name: Name.Black, size: Fonts.Size+12)!
		}
		
		public static let Button:UIFont = UIFont(name: Name.Black, size: Fonts.Size)!
	}
	
	public struct TabBar {
		
		static let Default:UIFont = UIFont(name: Name.Regular, size: Fonts.Size-4)!
		static let Selected:UIFont = UIFont(name: Name.Black, size: Fonts.Size-4)!
	}
	
	public struct SegmentedControl {
		
		static let Default:UIFont = UIFont(name: Name.Regular, size: Fonts.Size)!
		static let Selected:UIFont = UIFont(name: Name.Black, size: Fonts.Size)!
	}
	
	public struct Content {
		
		public struct Text {
			
			public static let Regular:UIFont = UIFont(name: Name.Regular, size: Fonts.Size)!
			public static let Bold:UIFont = UIFont(name: Name.Bold, size: Fonts.Size)!
		}
		
		public struct Button {
			
			public static let Title:UIFont = UIFont(name: Name.Black, size: Fonts.Size+4)!
			public static let Subtitle:UIFont = UIFont(name: Name.Bold, size: Fonts.Size)!
		}
		
		public struct Title {
			
			public static let H1:UIFont = UIFont(name: Name.Black, size: Fonts.Size+30)!
			public static let H2:UIFont = UIFont(name: Name.Black, size: Fonts.Size+11)!
			public static let H3:UIFont = UIFont(name: Name.Black, size: Fonts.Size+8)!
			public static let H4:UIFont = UIFont(name: Name.Black, size: Fonts.Size+5)!
		}
	}
}
