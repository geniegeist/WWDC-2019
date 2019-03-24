/*:
 [Previous](@previous) | [Next](@next)
 ### Chapter 2.2
 - - -
 
 ## Differential Quotient
 
 We have seen that a tangent can be approximated by a secant. How can we express this concept in mathematics? The answer is the ***limit*** process.
 
 ![The differential quotient](1differentialquotient.png)
 
 That formula is the **differential quotient**. It is almost the same as the difference quotient. Instead of `P(x_0, y_0)` and `Q(x_1, y_1)`, we write `x_1 = x_0 + h` where `h` is the horizontal difference between `x_1` and `x_0`.

 The magic ✨ happens in the limit process `lim -> 0`. It states that the distance `h` should get smaller and smaller. As we have seen so far, this reflects in an approximation that becomes better and better!
 - - -
 ## Derivative
 Now for a given function `f` we can plot the local rate of change of `f` for any arbitrary `x`. Indeed, this is again a function which is called the first **derivative** of `f` and is denoted by `f'` (called f prime).
 
 - Example: If a function has a local rate of change of 4 at `x = 2` the value of the derivative would be `f'(2) = 4`.
 
 If the graph of derivative lies under the x-axis then the function `f` decreases. If the graph of the derivative is above the x-axis the function `f` increases.
 
 - Experiment: On the right hand side, you see a function `f` (red) and its derivative (blue). You can see from the blue graph (the derivative) that `f` increases between -0.95 and 0. Try it yourself by tapping the red graph to display the tangent.
- - -
 ## Now what?
 Why would we ever be interested in the derivative? The answer is: the derivative is often much easier to handle than the original function.
 
- Example: The derivative of `x^4` is `4x^3`. We see that the degree decreases!
 
 However, the most important property is that the derivative encodes a lot of useful information about the original function. That means, we get a simpler function, and we can use this function to derive properties from the original function.
 - - -
 - Experiment:Look at the extremes of the red function `f`. What is the slope there?
 
 We find two extrema at `x=0` and `x=-0.95` by looking at the graph, and as we can see the slope vanishes there (if the slope is nonzero, the graph would continue decreasing or increasing and the point would not be an extrema anymore).
 
 Don't forget this concept. This is key for the Taylor expansion.
 
 - Important: We can use the derivative to simplify the original function, and the derivative encodes innate properties of the original function.
 ### Code
 */
import UIKit
import PlaygroundSupport
/*:
 `MathFunction` is a protocol for any mathematical function.
 
 - `eval` defines the formula of the function. Given an input `x`, `eval` returns `f(x)`.
 - `derivative` receives two parameters `x` and `order`. It returns `f^n(x)` where `n` is the order of the derivative specified by `order`
 
 - Experiment: Change the formula to explore the graph of other derivatives.
 */
struct RandomPolynomial: MathFunction {
    static func eval(x: CGFloat) -> CGFloat {
        return -1 * pow(x,9) + 1.5*pow(x,3) + 1*pow(x,8) - 4*pow(x,2)
    }
    
    static func derivative(x: CGFloat, order: Int) -> CGFloat {
//: We need to specify the first derivative.
        if (order == 1) {
            return -1 * 9 * pow(x,8) + 1.5*3*pow(x,2) + 8*1*pow(x,7) - 4*2*pow(x,1)
        }
//: Since we are only interested in the first derivative we return 0 for any other higher derivative.
        return 0
    }
}
/*:
 Set the live view. The live view consists of a top coordinate and bottom coordinate system.
 
 - Note: `height` specifies the height of the top and bottom coordinate system.
 */
let context = Context(maxX: 1.5, maxY: 7, numberOfSamples: 100, width: 500, height: 250)
let liveView = TangentView(context: context)
PlaygroundPage.current.liveView = liveView
/*:
 Set the function and its derivative. Both functions will be plotted.
 
 - Important: We are only interested in the first derivative. Therefore, the `order` is set to `1`.
 */
liveView.setFunction(TangentView.Function(eval: { RandomPolynomial.eval(x: $0) }, derivative: { RandomPolynomial.derivative(x: $0, order: 1) } ), animated: true)
/*:
 - - -
 [Previous](@previous) | [Next](@next)
 */

