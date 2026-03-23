//
//  String_Extension.swift
//  LettroLine
//
//  Created by BLIN Michael on 12/02/2025.
//

import Foundation
import CryptoKit

extension String {
	
	init(key:String) {
		
		self = NSLocalizedString(key, comment:"localizable string")
	}
    
    static var randomNonce:String {
        
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = 32
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    public var sha256:String {
        
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }

    public var isValidEmail:Bool {
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    public static var randomPassword:String {
        
        let lowercase = Array("abcdefghijklmnopqrstuvwxyz")
        let uppercase = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let digits = Array("0123456789")
        let specials = Array("!&^%$#@()/")
        
        let length = Int.random(in: 8...15)
        
        var characters: [Character] = []
        characters.append(lowercase.randomElement()!)
        characters.append(uppercase.randomElement()!)
        characters.append(digits.randomElement()!)
        characters.append(specials.randomElement()!)
        
        let all = lowercase + uppercase + digits + specials
        while characters.count < length {
            characters.append(all.randomElement()!)
        }
        
        return String(characters.shuffled())
    }
    
    public var isValidPassword:Bool {
        
        return isValidPasswordMinCharacters && isValidPasswordUppercaseCharacter && isValidPasswordLowercaseCharacter && isValidPasswordSpecialCharacter && isValidPasswordNumericCharacter
    }
    
    public var isValidPasswordMinCharacters:Bool {
        
        return count >= 8
    }
    
    public var isValidPasswordUppercaseCharacter:Bool {
        
        return rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil
    }
    
    public var isValidPasswordLowercaseCharacter:Bool {
        
        return rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil
    }
    
    public var isValidPasswordSpecialCharacter:Bool {
        
        let alphanumeric = CharacterSet.letters.union(CharacterSet.decimalDigits)
        return rangeOfCharacter(from: alphanumeric.inverted) != nil
    }
    
    public var isValidPasswordNumericCharacter:Bool {
        
        return rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }
}
