/*:
 [Previous](@previous) | [Next](@next)
 ### Chapter 2.1
 - - -
 
 ## Difference Quotient
 
 Before we explore the Taylor expansion, we need to revisit the **difference quotient**. You have probably seen the quotient in high school but let's revise the key concepts anyway.
 
 The average rate of change of a function is expressed as
 ![The difference quotient](dydx.png)
 
 Given two points `P(x_0, y_0)` and `Q(x_1, y_1)` we draw a secant combining these two points. We examine the slope of this linear affine function which is interpreted as the ***average rate of change***. The slope can be determined with the formula above.
 
 - Experiment:Let's do some practical stuff. You see a coordinate system on the right. Click anywhere in the coordinate system to draw a secant.
- - -
 However, we are more interested in the ***local rate of change*** at any arbitrary point `p`. If we would have a tangent at `p` we could examine the slope of the tangent, and this would be the local slope.
 - - -
 ### How do we obtain the tangent?
 We use secants to **approximate** the tangent! Just reduce the horizontal distance of the two points that connect the secant. The smaller the distance the better the approximation!
 
 - Experiment:Use the ***live view*** to find out the local rate of change of the function `f(x) = x^3 -x^2 +x` for `x = 0`.
 - - -
 - Note:You know your solution is correct if it solves equation `x^3 -3x^2 +3x - 1 = 0` 🤗.
 - - -
 You can also examine other functions using this live view. Feel free to skip to the next page to explore more about the **taylor expansion**.
 - - -
 ### Code
 */
import UIKit
import PlaygroundSupport
/*:
`MathFunction` is a protocol for any mathematical function. `eval` defines the formula of the function. Given an input `x`, `eval` returns `f(x)`.
 
 - Experiment: Change the formula to explore other functions. Try the exponential function `exp(x)`. What is so special about `exp(x)`?
 */
struct RandomPolynomial: MathFunction {
    static func eval(x: CGFloat) -> CGFloat {
        return 1*pow(x, 3) + (-1)*pow(x,2) + 1*x + 0
    }
}

/*:
 - Note: Adjust the settings of the coordinate system by setting the `context` object.
   - `maxX` is the largest (absolute) value on the x-axis.
   - `maxY` is the largest (absolute) value on the y-axis.
   - `numberOfSamples` defines the number of interpolation points that are drawn. The higher the value the smoother looks the function.
 */
let maxX: CGFloat = 1.5
let maxY: CGFloat = 4
let numberOfSamples: Int = 100

let context = Context(maxX: maxX,
                      maxY: maxY,
                      numberOfSamples: numberOfSamples,
                      width: 500,
                      height: 500)
/*:
Set the live view.
 */
let liveView = SecantView(context: context)
PlaygroundPage.current.liveView = liveView
/*:
 Set what function we like to plot. The function receives a parameter `eval` which is a closure `(CGFloat) -> CGFloat`. For any value `x` the closure `eval` should return `f(x)`.
 */
liveView.setFunction(SecantView.Function(eval: { RandomPolynomial.eval(x: $0) }))
/*:
 - - -
 [Previous](@previous) | [Next](@next)
 */

