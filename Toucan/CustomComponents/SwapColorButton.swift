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
        
        self.layer.cornerRadius = 20
        self.layer.borderWidth = 5
        self.layer.borderColor = self.backgroundColor?.cgColor
        self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.75)
        
        self.primaryColor = self.backgroundColor!
    }
    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted) {
                self.backgroundColor = self.primaryColor.withAlphaComponent(1)
            }
            else {
                self.backgroundColor = self.primaryColor
            }

        }
    }
}
