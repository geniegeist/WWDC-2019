/*:
 [Previous](@previous) | [Next](@next)
 ### Chapter 3
 - - -
 ## Taylor Expansion
 Remember the key principle from the last chapter? It is so important that I will repeat it.
 
 - Important: We can use the derivative to simplify the original function, and the derivative encodes innate properties of the original function.
 
 That is the idea of the **Taylor expansion**. Choose any point `a` and expand the function around the point `a` step by step. That's the Taylor formula
 
 ![The Taylor expansion](taylor.png)
 
 What do I mean by _expand_? We build a polynomial whose derivatives around the point `a` equal the derivatives of the original function. Since the derivatives are the same and the derivatives encode properties of the original function (remember 👻?), we should get a good approximation! And the best thing is: ***the approximation is a polynomial!*** For almost all _smooth_ functions, the Taylor expansion is a good approximation.
 
 - Note: There are functions that cannot be approximated by the Taylor expansion though 😿
 - - -
 - Experiment: Tap one of the given functions. Use the stepper to increase the degree of the Taylor expansion. The blue function is the Taylor expansion of the red function.

 The higher the degree the better the Taylor expansion.
 
  - For `cosine` and `sine` you should see that the even/ uneven degress have no effect on the polynomial.
  - For `log(x+1)` you see that the function cannot be approximated beyond `x > 1`, no matter how high the degree of the Taylor expansion is.
 
 - Important: The maximum degree for the Taylor expansion is limited to 20, for `Int` value cannot hold a value as big as `21!`
 - - -
 - Experiment: Click anywhere in the coordinate system to change the expansion point `a`.
 - - -
 ### Code
 */
import UIKit
import PlaygroundSupport
/*:
 - Note: Adjust the settings of the coordinate system by setting the `context` object.
 - `maxX` is the largest (absolute) value on the x-axis.
 - `maxY` is the largest (absolute) value on the y-axis.
 - `numberOfSamples` defines the number of interpolation points that are drawn. The higher the value the smoother looks the function.
 */
let maxX: CGFloat = 2*CGFloat.pi + 0.2
let maxY: CGFloat = 3
let numberOfSamples = 100

let context = Context(maxX: maxX, maxY: maxY, numberOfSamples: numberOfSamples, width: 500, height: 500)

/*:
 You can define your own function. This function will be displayed when the button `Custom` is selected.
 
 - Note:
    - `eval` receives a value `x` and returns `f(x)`. `x` is in the domain specified by the context, i.e. `-maxX < x < maxX`
    - `derivative` receives two parameters `x` and `order`. It returns `f^n(x)` where `n` is the order of the derivative specified by `order`
    - `isInDomain` receives a value `x` and returns `true` if `f` is defined for `x`. Otherwise `false`.
 */
public struct MyFunction: MathFunction {
//: Define a function with `f(x) = 1/x`
    public static func eval(x: CGFloat) -> CGFloat {
        return 1/(x)
    }
//: The nth derivative is given by this [formula](https://www.wolframalpha.com/input/?i=nth+derivative+of+1%2F(x))
    public static func derivative(x: CGFloat, order: Int) -> CGFloat {
        if (order == 0) {
            return eval(x: x)
        }
        
        return pow(-1, CGFloat(order)) * pow(x, -1-CGFloat(order)) * CGFloat(factorial(order))
    }
//: `1/x` is not defined for `x=0`. Only draw the graph for `x < -0.01`.
    public static func isInDomain(x: CGFloat) -> Bool {
        return -x > 0.01
    }
}
//: Define the custom function which is then forwarded to the live view.
let customFunction =  TaylorView.Function(identifier: "Custom",
                               eval: { MyFunction.eval(x: $0) },
                               derivative: { (x, order) in MyFunction.derivative(x: x, order: order) },
                               inDomain: { MyFunction.isInDomain(x: $0) },
                               defaultTaylorPoint: -1.0)
/*:
 Set the live view.
 */
let liveView = TaylorView(context: context, customFunction: customFunction)
PlaygroundPage.current.liveView = liveView
/*:
 ### That's it 👻🥳✨
 */

/*:
 - - -
 [Previous](@previous) | [Next](@next)
 */
