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
        case unaryOperation(function:(Double) -> Double, description: (String) -> String)
        case binaryOperation(function: (Double, Double) -> Double, description: (String, String) -> String, priority: Int)
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
        "√" : Operation.unaryOperation(function: sqrt, description: {"√(" + $0 + ")"}),
        "cos" : Operation.unaryOperation(function: cos, description: {"cos(" + $0 + ")"}),
        "sin" : Operation.unaryOperation(function: sin, description: {"sin(" + $0 + ")"}),
        "±" : Operation.unaryOperation(function: {-$0}, description: {"±(" + $0 + ")"}),
        "㏑" : Operation.unaryOperation(function: log, description: {"ln(" + $0 + ")"}),
        "eˣ" : Operation.unaryOperation(function: exp, description: {"e^" + $0}),
        "x⁻¹" : Operation.unaryOperation(function: {1.0/$0}, description: {"(" + $0 + ")⁻¹"}),
        "×" : Operation.binaryOperation(function: *, description: {$0 + "×" + $1}, priority: 1),
        "÷" : Operation.binaryOperation(function: /, description: {$0 + "÷" + $1}, priority: 1),
        "+" : Operation.binaryOperation(function: +, description: {$0 + "+" + $1}, priority: 0),
        "-" : Operation.binaryOperation(function: -, description: {$0 + "-" + $1}, priority: 0),
        "xʸ" : Operation.binaryOperation(function: pow, description: {$0 + "^" + $1}, priority: 2),
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


    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var accumulator: Double?
        var descriptionOfAccumulator: String = " "
        var pendingInfo: PendingBinaryOperationInfo?
        var lastOperationPriority = Int.max


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
        }

        func performPendingBinaryOperation() {
            if (pendingInfo != nil) {
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
                case .unaryOperation(let function, let descriptionFunction):
                    if accumulator != nil {
                        accumulator = function(accumulator!)
                    }
                    descriptionOfAccumulator = descriptionFunction(descriptionOfAccumulator)
                case .binaryOperation(let function, let functionDescription, let operationPriority):
                    performPendingBinaryOperation()
                    if lastOperationPriority < operationPriority {
                        descriptionOfAccumulator = "(" + descriptionOfAccumulator + ")"
                    }
                    lastOperationPriority = operationPriority
                    if accumulator != nil {
                        pendingInfo = PendingBinaryOperationInfo(function: function, firstOperand: accumulator!, descriptionFunction: functionDescription, descriptionOperand: descriptionOfAccumulator)
                    }
                case .equals:
                    performPendingBinaryOperation()
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
            return (nil, false, " ")
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

        return (accumulator, resultIsPending, description)
    }

    func undo() {
        if !calculationSequence.isEmpty {
           let _ = calculationSequence.dropLast()
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
