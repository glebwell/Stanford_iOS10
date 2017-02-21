//
//  ViewController.swift
//  Calculator
//
//  Created by Admin on 13.02.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if (userIsInTheMiddleOfTyping == false) {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        } else {
            let textCurrentlyInDisplay = display.text!
            //display.text = textCurrentlyInDisplay + digit
            appendSymbolToDisplay(textCurrentlyInDisplay: textCurrentlyInDisplay, inputText: digit)
        }
    }
    @IBAction func touchDot(_ sender: UIButton) {
        let textCurrentlyInDisplay = display.text!
        if textCurrentlyInDisplay.contains(".") == false {
            display.text = textCurrentlyInDisplay + sender.currentTitle!
            userIsInTheMiddleOfTyping = true
        }
    }

    private func appendSymbolToDisplay(textCurrentlyInDisplay displayText:String, inputText textToInsert:String) {
        if displayValue == 0.0 && display.text!.contains(".") == false { // flush and insert new symbol
            display.text = textToInsert
        } else { // append digits in floating point number
            display.text = displayText + textToInsert
        }
    }
    
    var displayValue : Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
    }
}


