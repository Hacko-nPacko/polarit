//
//  AngleSliderDataSource.swift
//  polarit
//
//  Created by Atanas Balevsky on 6/26/14.
//  Copyright (c) 2014 Atanas Balevsky. All rights reserved.
//

import Foundation

class AngleSliderDataSource: NSObject, ASValueTrackingSliderDataSource {
    func slider(slider: ASValueTrackingSlider!, stringForValue value: CFloat) -> String! {
        return NSString(format:"%@°", slider.numberFormatter.stringFromNumber(value))
    }
}
