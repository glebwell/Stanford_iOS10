//
//  ViewController.swift
//  Calculator
//
//  Created by Admin on 13.02.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var displayM: UILabel!

    private lazy var formatter: NumberFormatter = {
        var form = NumberFormatter()
        //form.minimumIntegerDigits = 1
        form.numberStyle = .decimal
        form.maximumFractionDigits = 6
        form.notANumberSymbol = "Error"
        form.groupingSeparator = " "
        form.locale = Locale.current
        self.brain.setFormatter(form)
        return form
    }()

    private enum LastOperation {
        case performOperation
        case setVariable
    }

    private var lastOperation: LastOperation?
    private var lastVariable: (name: String, value: Double)?

    var userIsInTheMiddleOfTyping = false

    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        variableValues.removeAll()
        allDisplaysResult = brain.evaluate(using: variableValues)
    }

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if (userIsInTheMiddleOfTyping == false) {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        } else {
            let textCurrentlyInDisplay = display.text!
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

    @IBAction func touchUndo(_ sender: UIButton) {
        userIsInTheMiddleOfTyping ? backspace() : undo()
    }

    @IBAction func touchBackspace(_ sender: UIButton) {
        backspace()
    }

    private func undo() {
        if let operation = lastOperation {
            switch operation {
            case .setVariable:
                if lastVariable != nil { // back to previous variable value
                    variableValues[lastVariable!.name] = lastVariable!.value
                }
            case .performOperation:
                brain.undo()
                allDisplaysResult = brain.evaluate(using: variableValues)
            }
        }
    }

    private func backspace() {
        if display.text?.characters.count == 1 {
            display.text = "0"
        } else {
            display.text?.characters.removeLast()
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
            display.text = formatter.string(from: NSNumber(value: newValue))
        }
    }

    var allDisplaysResult: (result: Double?, isPending: Bool, description: String, error: String?) = (nil, false, " ", nil) {
        didSet {
            if allDisplaysResult.error == nil {
                displayValue = allDisplaysResult.result ?? 0.0
                if allDisplaysResult.description == " " {
                    history.text = " "
                } else {
                    history.text = allDisplaysResult.description + (allDisplaysResult.isPending ? "..." : "=")
                }
            } else {
                display.text = allDisplaysResult.error
                history.text = " "
            }

            displayM.text = "M = " + (formatter.string(from: NSNumber(value: variableValues["M"] ?? 0.0)) ?? "0")
        }
    }


    private var brain = CalculatorBrain()
    private var variableValues = Dictionary<String, Double>()

    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        allDisplaysResult = brain.evaluate(using: variableValues)
        lastOperation = .performOperation
    }

    @IBAction func putM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        allDisplaysResult = brain.evaluate(using: variableValues)
        userIsInTheMiddleOfTyping = false
    }
    @IBAction func setM(_ sender: UIButton) {
        let variableName = String(sender.currentTitle!.characters.dropFirst())
        lastVariable = (name: variableName, value: variableValues[variableName] ?? 0.0) // save old variable
        variableValues[variableName] = displayValue
        allDisplaysResult = brain.evaluate(using: variableValues)
        lastOperation = .setVariable
    }

    private let graphSegueIdentifier = "Show graph"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destination = segue.destination
        if let navigationController = destination as? UINavigationController {
            destination = navigationController.visibleViewController ?? destination
        }
        if let identifier = segue.identifier,
            identifier == graphSegueIdentifier,
            let vc = destination as? GraphingViewController {
            vc.graphingFunction = { 1/$0 }
            vc.navigationItem.title = "y = " + brain.description

        }
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == graphSegueIdentifier {
            let evalResult = brain.evaluate()
            return !evalResult.isPending && evalResult.result != nil
        }
        return false
    }

}


