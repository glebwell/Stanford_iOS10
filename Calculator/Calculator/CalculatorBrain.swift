//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Admin on 15.02.17.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

struct CalculatorBrain {

    private var formatter: NumberFormatter?

    private enum Operation {
        case constant(Double)
        case unaryOperation(function:(Double) -> Double, description: (String) -> String, validator: ((Double) -> Bool)?, errorText: String?)
        case binaryOperation(function: (Double, Double) -> Double, description: (String, String) -> String,
            priority: Int, validator: ((Double) -> Bool)?, errorText: String?)
        case randomNumberGeneration(function: () -> Double, description: String)
        case equals
    }

    private enum CalculationItem {
        case number(Double)
        case variable(String)
        case operationSymbol(String)
    }

    private var calculationSequence = Array<CalculationItem>()

    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(function: sqrt, description: {"√(" + $0 + ")"}, validator: {$0 >= 0.0}, errorText: "Fail to get sqrt from negative number"),
        "cos" : Operation.unaryOperation(function: cos, description: {"cos(" + $0 + ")"}, validator: {$0 >= -1.0 && $0 <= 1.0},
                                         errorText: "Number must be in range [-1, 1]"),
        "sin" : Operation.unaryOperation(function: sin, description: {"sin(" + $0 + ")"}, validator: {$0 >= -1.0 && $0 <= 1.0},
                                         errorText: "Number must be in range [-1, 1]"),
        "±" : Operation.unaryOperation(function: {-$0}, description: {"±(" + $0 + ")"}, validator: nil, errorText: nil),
        "㏑" : Operation.unaryOperation(function: log, description: {"ln(" + $0 + ")"}, validator: {$0 > 0.0}, errorText: "Fail to get logarithm of negative number"),
        "eˣ" : Operation.unaryOperation(function: exp, description: {"e^" + $0}, validator: nil, errorText: nil),
        "x⁻¹" : Operation.unaryOperation(function: {1.0/$0}, description: {"(" + $0 + ")⁻¹"}, validator: {$0 != 0.0}, errorText: "Devide by zero"),
        "×" : Operation.binaryOperation(function: *, description: {$0 + "×" + $1}, priority: 1, validator: nil, errorText: nil),
        "÷" : Operation.binaryOperation(function: /, description: {$0 + "÷" + $1}, priority: 1, validator: {$0 != 0.0}, errorText: "Devide by zero"),
        "+" : Operation.binaryOperation(function: +, description: {$0 + "+" + $1}, priority: 0, validator: nil, errorText: nil),
        "-" : Operation.binaryOperation(function: -, description: {$0 + "-" + $1}, priority: 0, validator: nil, errorText: nil),
        "xʸ" : Operation.binaryOperation(function: pow, description: {$0 + "^" + $1}, priority: 2, validator: nil, errorText: nil),
        "Rand" : Operation.randomNumberGeneration(function: {Double(arc4random()) / Double(UInt32.max)}, description: "rand()"),
        "=" : Operation.equals
    ]

    mutating func performOperation(_ symbol: String) {
        calculationSequence.append(.operationSymbol(symbol))
    }


    mutating func setOperand(variable named: String) {
        calculationSequence.append(.variable(named))
    }

    mutating func setOperand(_ operand: Double) {
        calculationSequence.append(.number(operand))
    }


    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String, error: String?) {
        var accumulator: Double?
        var descriptionOfAccumulator: String = " "
        var pendingInfo: PendingBinaryOperationInfo?
        var lastOperationPriority = Int.max
        var error: String?


        var resultIsPending: Bool {
            return pendingInfo != nil
        }

        struct PendingBinaryOperationInfo {
            let function: (Double, Double) -> Double
            let firstOperand: Double
            let descriptionFunction: (String, String) -> String
            let descriptionOperand: String

            func perform(with secondOperand: Double) -> Double {
                return function(firstOperand, secondOperand)
            }
            func performDescription(with secondOperand: String) -> String {
                return descriptionFunction(descriptionOperand, secondOperand)
            }
            func validate(what secondOperand: Double, errorText: inout String?) {
                if validator?(secondOperand) == false {
                    errorText = errorTextInValidation
                }
            }
            var validator: ((Double) -> Bool)?
            var errorTextInValidation: String?
        }

        func performPendingBinaryOperation(errorMessage: inout String?) {
            if (pendingInfo != nil) {
                pendingInfo!.validate(what: accumulator ?? 0.0, errorText: &errorMessage)
                accumulator = pendingInfo!.perform(with: accumulator ?? 0.0)
                descriptionOfAccumulator = pendingInfo!.performDescription(with: descriptionOfAccumulator)
                pendingInfo = nil
            }
        }

        var description: String {
            get {
                if resultIsPending {
                    let secondOperand = pendingInfo!.descriptionOperand != descriptionOfAccumulator ? descriptionOfAccumulator : ""
                    return pendingInfo!.performDescription(with: secondOperand)
                } else {
                    return descriptionOfAccumulator
                }
            }
        }

        func performOperation(_ symbol: String) {
            if let operation = operations[symbol] {
                switch operation {
                case .constant(let value):
                    accumulator = value
                    descriptionOfAccumulator = symbol
                case .randomNumberGeneration(let generator, let descriptionValue):
                    accumulator = generator()
                    descriptionOfAccumulator = descriptionValue
                case .unaryOperation(let function, let descriptionFunction, let validator, let errorText):
                    if validator?(accumulator ?? 0.0) == false {
                        error = errorText
                    }
                    descriptionOfAccumulator = descriptionFunction(descriptionOfAccumulator)
                    accumulator = function(accumulator ?? 0.0)
                case .binaryOperation(let function, let functionDescription, let operationPriority, let validator, let errorText):
                    performPendingBinaryOperation(errorMessage: &error)
                    if lastOperationPriority < operationPriority {
                        descriptionOfAccumulator = "(" + descriptionOfAccumulator + ")"
                    }
                    lastOperationPriority = operationPriority
                    if accumulator != nil {
                        pendingInfo = PendingBinaryOperationInfo(function: function, firstOperand: accumulator!, descriptionFunction: functionDescription, descriptionOperand: descriptionOfAccumulator, validator: validator, errorTextInValidation: errorText)
                    }
                case .equals:
                    performPendingBinaryOperation(errorMessage: &error)
                }
            }
        }

        func setOperand(operand: Double) {
            accumulator = operand
            if formatter != nil {
                descriptionOfAccumulator = formatter!.string(from: NSNumber(value: operand)) ?? ""
            } else {
                descriptionOfAccumulator = String(operand)
            }

        }

        func setOperand(variable named: String) {
            if variables == nil {
                accumulator = 0.0
            } else {
                accumulator = variables![named] ?? 0.0
            }
            descriptionOfAccumulator = named
        }

        guard !calculationSequence.isEmpty else {
            return (nil, false, " ", nil)
        }

        for calculationItem in calculationSequence {
            switch calculationItem {
            case .number(let value):
                setOperand(operand: value)
            case .variable(let name):
                setOperand(variable: name)
            case .operationSymbol(let symbol):
                performOperation(symbol)
            }
        }

        return (accumulator, resultIsPending, description, error)
    }

    mutating func undo() {
        if !calculationSequence.isEmpty {
            calculationSequence.removeLast()
        }
    }

    var result: Double? {
        get {
            return evaluate().result
        }
    }

    var resultIsPending: Bool {
        get {
            return evaluate().isPending
        }
    }

    var description: String {
        get {
            return evaluate().description
        }
    }

    mutating func clear() {
        calculationSequence.removeAll()
    }

    mutating func setFormatter(_ formatter: NumberFormatter) {
        self.formatter = formatter
    }
}
