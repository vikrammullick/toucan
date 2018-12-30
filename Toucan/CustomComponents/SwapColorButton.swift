//
//  SwapColorButton.swift
//  Toucan
//
//  Created by Vikram Mullick on 12/29/18.
//  Copyright © 2018 Vikram Mullick. All rights reserved.
//

import UIKit

class SwapColorButton: UIButton {
    
    var primaryColor : UIColor!
    var secondaryColor : UIColor!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.primaryColor = self.backgroundColor!
        self.secondaryColor = self.tintColor!
    }
    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted) {
                self.backgroundColor = self.secondaryColor
                self.tintColor = self.primaryColor
            }
            else {
                self.backgroundColor = self.primaryColor
                self.tintColor = self.secondaryColor
            }

        }
    }
}
