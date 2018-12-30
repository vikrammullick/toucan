//
//  ButtonEnabledScrollView.swift
//  Toucan
//
//  Created by Vikram Mullick on 12/29/18.
//  Copyright © 2018 Vikram Mullick. All rights reserved.
//

import UIKit

class ButtonEnabledScrollView: UIScrollView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }

}

