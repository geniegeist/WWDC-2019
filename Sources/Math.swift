import UIKit

public func factorial(_ n: Int) -> Int {
    if (n == 0) {
        return 1
    }
    
    var res = 1
    for i in 1...n {
        res = res * i
    }
    
    return res
}

public protocol MathFunction {
    static func eval(x: CGFloat) -> CGFloat
    static func graph(x: [CGFloat]) -> [CGPoint]
    static func derivative(x: CGFloat, order: Int) -> CGFloat
    static func isInDomain(x: CGFloat) -> Bool
}

public extension MathFunction {
    public static func graph(x: [CGFloat]) -> [CGPoint] {
        return x
            .filter{ isInDomain(x: $0) }
            .map { CGPoint(x: $0, y: eval(x: $0)) }
    }
    
    public static func isInDomain(x: CGFloat) -> Bool {
        return true
    }
    
    public static func derivative(x: CGFloat, order: Int) -> CGFloat {
        return 0
    }
}

public struct Sine: MathFunction {
    public static func eval(x: CGFloat) -> CGFloat {
        return sin(x)
    }
    
    public static func derivative(x: CGFloat, order: Int) -> CGFloat {
        let type = order % 4
        if (type == 0) {
            return eval(x: x)
        } else if (type == 1) {
            return Cosine.eval(x: x)
        } else if (type == 2) {
            return -eval(x: x)
        } else {
            return -Cosine.eval(x: x)
        }
    }
}

public struct Cosine: MathFunction {
    public static func eval(x: CGFloat) -> CGFloat {
        return cos(x)
    }
    
    public static func derivative(x: CGFloat, order: Int) -> CGFloat {
        let type = order % 4
        if (type == 0) {
            return Cosine.eval(x: x)
        } else if (type == 1) {
            return -Sine.eval(x: x)
        } else if (type == 2) {
            return -Cosine.eval(x: x)
        } else {
            return Sine.eval(x: x)
        }
    }
}

public struct Exp: MathFunction {
    public static func eval(x: CGFloat) -> CGFloat {
        return exp(x)
    }
    
    public static func derivative(x: CGFloat, order: Int) -> CGFloat {
        return exp(x)
    }
}

public struct LogXPlus1: MathFunction {
    public static func eval(x: CGFloat) -> CGFloat {
        return log(x + 1)
    }
    
    public static func derivative(x: CGFloat, order: Int) -> CGFloat {
        if (order == 0) {
            return eval(x: x)
        }
        
        return pow(-1.0, CGFloat(order) + 1.0) * CGFloat(factorial(order - 1)) / pow(1+x, CGFloat(order))
    }
    
    public static func isInDomain(x: CGFloat) -> Bool {
        return x > -1
    }
}


public struct TaylorExpansion {
    var coefficients: [CGFloat] = []
    let point: CGFloat
    
    init(point: CGFloat, order: Int, derivative: (CGFloat, Int) -> CGFloat) {
        self.point = point
        for n in 0...order {
            coefficients.append(derivative(point, n)/CGFloat(factorial(n)))
        }
    }
    
    func eval(x: CGFloat) -> CGFloat {
        return coefficients.enumerated().reduce(0, { (accumulator, value) -> CGFloat in
            let (index, coefficient) = value
            return accumulator + coefficient * pow(x - point, CGFloat(index))
        })
    }
}
