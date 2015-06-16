//
//  ViewController.swift
//  Dice
//
//  Created by Sergio Palomo on 27/04/2015.
//  Copyright (c) 2015 Example. All rights reserved.
//

import UIKit
import HoneIOS


class ViewController: UIViewController {
    
    @IBOutlet weak var diceValueLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var circleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleHeightConstraint: NSLayoutConstraint!
    var rollInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupTapGestureRecognizer()
        
        setupHone()
        
        
    }
    
    func setupHone() {
        hintLabel.bindToHoneObject("hint", options: [ HNEOnlyValueIdentifiers: Set([ "font", "textColor", "text" ]) ])
        diceValueLabel.bindToHoneObject("circle", options: [ HNEOnlyValueIdentifiers: Set([ "font", "textColor" ]) ])
        
        
        HNE.bindUIColorIdentifier("container.background", object: view, keyPath: "backgroundColor")
        HNE.bindUIColorIdentifier("circle.background", object: circleView, keyPath: "backgroundColor")
        
        HNE.bindCGFloatIdentifier("circle.diameter", defaultValue: 200, object: self) {
            (viewController, newValue) in
            
            if let viewController = viewController as? ViewController {
                viewController.circleWidthConstraint.constant = newValue
                viewController.circleHeightConstraint.constant = newValue
                viewController.circleView.layer.cornerRadius = newValue / 2
            }
        }
    }

    
    
    // MARK: - Gesture recognizers, motion handlers
    
    func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapped:"))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func tapped(tapper: UITapGestureRecognizer) {
        if tapper.state == .Ended {
            diceRoll()
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        super.motionEnded(motion, withEvent: event)
        if motion == .MotionShake {
            diceRoll()
        }
    }
    
    // MARK: - Custom behavior
    
    func diceRoll() {
        
        if rollInProgress { return }
        
        let rollLengthInSeconds = Double(HNE.CGFloatWithHoneIdentifier("circle.animationDuration", defaultValue: 2.0))
        let rollCount = HNE.NSIntegerWithHoneIdentifier("circle.animationIterationCount", defaultValue: 10)
        
        
        let oneRollDuration = rollLengthInSeconds / Double(rollCount)
        
        rollInProgress = true
        
        diceRollStep(rollCount, oneRollDuration: oneRollDuration)
    }
    
    func diceRollStep(remainingSteps: Int, oneRollDuration: Double) {
        
        let newValue = arc4random_uniform(6) + 1
        self.diceValueLabel.text = String(newValue)
        if remainingSteps > 0 {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(oneRollDuration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.diceRollStep(remainingSteps - 1, oneRollDuration: oneRollDuration)
            })
        } else {
            rollInProgress = false
        }
    }
}
