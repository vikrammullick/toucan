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

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 10
        
        self.primaryColor = self.backgroundColor!
    }
    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted) {
                self.backgroundColor = self.primaryColor.withAlphaComponent(0.75)
            }
            else {
                self.backgroundColor = self.primaryColor
            }

        }
    }
}
