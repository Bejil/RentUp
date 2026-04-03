//
//  MB_Confetti.swift
//  CurseCounter
//
//  Created by BLIN Michael on 14/02/2025.
//

import SPConfetti

public class MB_Confetti {
	
	public static func start() {
		
		SPConfettiConfiguration.particlesConfig.birthRate = 50
		
		let colors = [Colors.Primary,Colors.Secondary,Colors.Tertiary]
		SPConfettiConfiguration.particlesConfig.colors = colors
		SPConfetti.startAnimating(.fullWidthToDown, particles: [.arc])
	}
	
	public static func stop() {
		
		SPConfetti.stopAnimating()
	}
}
