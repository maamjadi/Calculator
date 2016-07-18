//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Amin Amjadi on 6/12/16.
//  Copyright © 2016 MDJD. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible
    {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double) //so Double -> Double is func and that's enough
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get{
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var knownOps = [String:Op]()  //this lines means exactly same as: Dictionary<String, Op>()
    
    
    private var opStack = [Op]()  // it means exactly same as: Array<Op>() which is more understandable
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        // then by function above we can instead of this :knownOps["×"]=Op.BinaryOperation("×", *) , type like below
        learnOp(Op.BinaryOperation("×", *))
        knownOps["÷"]=Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"]=Op.BinaryOperation("+", +)
        knownOps["−"]=Op.BinaryOperation("−") { $1 - $0 }
        knownOps["√"]=Op.UnaryOperation("√", sqrt)
        
        //we can't do the same for the division and substraction because
        //the order of them is different
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList { //guaranteed to be a PropertyList
        get {
            return opStack.map { $0.description } //so we don't need these below lines by saying this single line
            //this is just a little closure that gets opportunity to convert every single thing inside opStack (which is an Op)
            //into a string and take this string, maps them all and return a new array
            
//            var returnValue = [String]() //this is the PropertyList
//            for op in opStack {
//                returnValue.append(op.description)
//            }
//            return returnValue
        }
        set {
            if let opSymbols = newValue as? Array<String> { //to make sure that newValue which is AnyObject has the type array of strings
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    }
                    else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) { //here we use tuple to return the number and them the remaining Ops in array
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            //if we just say this, we get error cz ops is read only type so we should say var before it if we want to change it
            //but is it not the best solution so instead we make another variable like: remainingOps = ops and by = it makes copy of ops
            switch op {
                
            case .Operand(let operand): //here "." before Operand is just for that, that it knows Operand is for Op (Op.Operand)
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation): //here we don't care about symbol so we just type _
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return(operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return(operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil,ops)
    }
    
    func evaluate() -> Double? {
        let (rslt, reminder) = evaluate(opStack) //here we use tuple and we can notice that the names can be different
        print("\(opStack) = \(rslt) with \(reminder) left over")
        return rslt
        
    }
    
    
    func pushOperand(operand: Double) ->Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] { //the type of operation is optional if we don't say if before it cz we may have no knownOps for one symbol
            opStack.append(operation)
        }
        return evaluate()
    }
    
}