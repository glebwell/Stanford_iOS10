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

    private var accumulatorTuple: (value: Double, repr: String) = (0.0, "0")

    private var lastOperationPriority = Int.max

    private enum Operation {
        case constant(Double)
        case unaryOperation(function:(Double) -> Double, description: (String) -> String)
        case binaryOperation(function: (Double, Double) -> Double, description: (String, String) -> String, priority: Int)
        case randomNumberGeneration(function: () -> Double, description: String)
        case equals
    }

    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(function: sqrt, description: {"√(" + $0 + ")"}),
        "cos" : Operation.unaryOperation(function: cos, description: {"cos(" + $0 + ")"}),
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
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulatorTuple = (value: value, repr: symbol)
            case .randomNumberGeneration(let generator, let descriptionValue):
                accumulatorTuple = (value: generator(), repr: descriptionValue)
            case .unaryOperation(let function, let descriptionFunction):
                accumulatorTuple = (value: function(accumulatorTuple.value), repr: descriptionFunction(accumulatorTuple.repr))
            case .binaryOperation(let function, let functionDescription, let operationPriority):
                performPendingBinaryOperation()
                if lastOperationPriority < operationPriority {
                    accumulatorTuple.repr = "(" + accumulatorTuple.repr + ")"
                }
                lastOperationPriority = operationPriority
                pendingInfo = PendingBinaryOperationInfo(function: function, firstOperand: accumulatorTuple.value, descriptionFunction: functionDescription, descriptionOperand: accumulatorTuple.repr)

            case .equals:
                performPendingBinaryOperation()
            }
        }
    }

    private mutating func performPendingBinaryOperation() {
        if (pendingInfo != nil) {
            accumulatorTuple.value = pendingInfo!.perform(with: accumulatorTuple.value)
            accumulatorTuple.repr = pendingInfo!.descriptionFunction(pendingInfo!.descriptionOperand, accumulatorTuple.repr)
            pendingInfo = nil
        }
    }

    var description: String {
        get {
            if resultIsPending {
                let secondOperand = pendingInfo!.descriptionOperand != accumulatorTuple.repr ? accumulatorTuple.repr : ""
                return pendingInfo!.descriptionFunction(pendingInfo!.descriptionOperand, secondOperand)
            } else {
                return accumulatorTuple.repr
            }
        }
    }
    private var pendingInfo: PendingBinaryOperationInfo?

    var resultIsPending: Bool {
        return pendingInfo != nil
    }

    private struct PendingBinaryOperationInfo {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        let descriptionFunction: (String, String) -> String
        let descriptionOperand: String

        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }

    mutating func setOperand(_ operand: Double) {
        accumulatorTuple.value = operand
        if formatter != nil {
            accumulatorTuple.repr = formatter!.string(from: NSNumber(value: operand)) ?? ""
        } else {
            accumulatorTuple.repr = String(operand)
        }
    }

    var result: Double? {
        get {
            return accumulatorTuple.value
        }
    }

    mutating func clear() {
        pendingInfo = nil
        accumulatorTuple = (value: 0.0, repr: "0")
    }

    mutating func setFormatter(_ formatter: NumberFormatter) {
        self.formatter = formatter
    }
}
