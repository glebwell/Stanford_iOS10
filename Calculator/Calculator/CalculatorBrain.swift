//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Admin on 15.02.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

func changeSign(_ value: Double) -> Double {
    return -value
}

func makeRandomNumber() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

struct CalculatorBrain {

    private var formatter: NumberFormatter?

    private var accumulatorTuple: (value: Double?, repr: String) = (nil, "")

    private var secondOperandWasSet = false

    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case randomNumberGeneration(() -> Double)
        case equals
    }

    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "±" : Operation.unaryOperation(changeSign),
        "㏑" : Operation.unaryOperation(log),
        "eˣ" : Operation.unaryOperation(exp),
        "x⁻¹" : Operation.unaryOperation({ 1.0 / $0 }),
        "×" : Operation.binaryOperation(*),
        "÷" : Operation.binaryOperation(/),
        "+" : Operation.binaryOperation(+),
        "-" : Operation.binaryOperation(-),
        "xʸ" : Operation.binaryOperation(pow),
        "Rand" : Operation.randomNumberGeneration(makeRandomNumber),
        "=" : Operation.equals
    ]

    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulatorTuple.value = value
            case .randomNumberGeneration(let generator):
                let randomNumber = generator()
                var formattingSuccess = false
                if formatter != nil {
                    if let optionalFormattedString = formatter!.string(from: randomNumber as NSNumber) {
                        if let optionalFormattedDouble = formatter!.number(from: optionalFormattedString) as Double? {
                            accumulatorTuple.value = optionalFormattedDouble
                            formattingSuccess = true
                        }
                    }
                }
                if formattingSuccess == false {
                    accumulatorTuple.value = randomNumber
                }
            case .unaryOperation(let function):
                if accumulatorTuple.value == nil {
                    accumulatorTuple.value = 0.0
                }
                if descriptionValue.isEmpty {
                    descriptionValue = String(format: "%@(%@)", symbol, accumulatorToString()!)
                } else if secondOperandWasSet {
                    descriptionValue = String(format: "%@(%@)", symbol, descriptionValue)
                } else {
                    // TODO: make possible to do unaryOperations more than 1 time
                    accumulatorTuple.repr = String(format: "%@(%@)", symbol, accumulatorToString()!)
                    descriptionValue.append(accumulatorTuple.repr)
                    secondOperandWasSet = true
                }
                accumulatorTuple.value = function(accumulatorTuple.value!)

            case .binaryOperation(let function):
                if accumulatorTuple.value == nil {
                    accumulatorTuple.value = 0.0
                }
                let secondOperandString = accumulatorToString()!
                performPendingBinaryOperation()
                pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulatorTuple.value!)

                if descriptionValue.isEmpty {
                    descriptionValue += convertToStringForDescription(pendingBinaryOperation!.firstOperand) + symbol
                } else if secondOperandWasSet {
                    descriptionValue += symbol
                    secondOperandWasSet = false
                } else {
                    descriptionValue += secondOperandString + symbol
                }
            case .equals:
                let secondOperandString = accumulatorToString()!
                performPendingBinaryOperation()
                if secondOperandWasSet == false {
                    descriptionValue += secondOperandString
                }
                secondOperandWasSet = true
            }
        }
    }

    private mutating func convertToStringForDescription(_ value: Double) -> String {
        switch value {
        case Double.pi:
            return "π"
        case M_E:
            return "e"
        default:
            if formatter != nil {
                if let optionalFormattedString = formatter!.string(from: value as NSNumber) {
                    return optionalFormattedString
                } else {
                    return String(value)
                }
            } else {
                return String(value)
            }
        }
    }

    private mutating func accumulatorToString() -> String? {
        if let value = accumulatorTuple.value {
            return convertToStringForDescription(value)
        } else {
            return nil
        }
    }


    private mutating func performPendingBinaryOperation() {
        if (pendingBinaryOperation != nil && accumulatorTuple.value != nil) {
            accumulatorTuple.value = pendingBinaryOperation!.perform(with: accumulatorTuple.value!)
            pendingBinaryOperation = nil
        }
    }

    private var descriptionValue = ""

    var description: String {
        get {
            return descriptionValue
        }
    }
    private var pendingBinaryOperation: PendingBinaryOperation?

    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }

    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double

        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }

    mutating func setOperand(_ operand: Double) {
        accumulatorTuple = (value: operand, repr: String(operand))
    }

    var result: Double? {
        get {
            return accumulatorTuple.value
        }
    }

    mutating func clear() {
        descriptionValue = ""
        secondOperandWasSet = false
        pendingBinaryOperation = nil
        accumulatorTuple = (value: nil, repr: "")
    }

    mutating func setFormatter(_ formatter: NumberFormatter) {
        self.formatter = formatter
    }
}
