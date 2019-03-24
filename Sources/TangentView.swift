import PlaygroundSupport
import UIKit
import CoreGraphics



public class TangentView: UIView {
    
    public struct Function {
        let eval: (CGFloat) -> CGFloat
        let derivative: (CGFloat) -> CGFloat
        
        public init(eval: @escaping (CGFloat) -> CGFloat, derivative: @escaping (CGFloat) -> CGFloat) {
            self.eval = eval
            self.derivative = derivative
        }
    }
    
    public var context: Context
    
    var function: Function?
    
    var topCoordinateSystem: CoordinateSystem!
    var bottomCoordinateSystem: CoordinateSystem!
    
    var verticalIndicator: CAShapeLayer!
    var horizontalIndicator: CAShapeLayer!
    
    var tangentPoint: CGFloat = 0
    lazy var linearAffinePointView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        view.backgroundColor = UIColor(red: 250/255, green: 185/255, blue: 67/255, alpha: 1)
        view.layer.cornerRadius = view.frame.size.width / 2
        topCoordinateSystem.contentView.addSubview(view)
        return view
    }()
    var linearAffineFunction: Graph!
    
    var secantPoint: CGFloat = 0
    lazy var secantPointView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        view.backgroundColor = UIColor(red: 250/255, green: 185/255, blue: 67/255, alpha: 1)
        view.layer.cornerRadius = view.frame.size.width / 2
        topCoordinateSystem.contentView.addSubview(view)
        return view
    }()
    var secantFunction: Graph!
    
    var slopeLabel: UILabel!
    var bottomCoordinateSystemLabel: UILabel!
    var xCoordinateLabel: UILabel!
    
    public init(context: Context) {
        self.context = context
        super.init(frame: CGRect(x: 0, y: 0, width: context.width, height: context.height*2 + 50))
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        topCoordinateSystem = CoordinateSystem(context: context)
        topCoordinateSystem.axisSegmentIndicatorSize = 0
        topCoordinateSystem.drawGrid()
        topCoordinateSystem.frame = CGRect(x: 0, y: 0, width: 500, height: context.height)
        topCoordinateSystem.layer.masksToBounds = true
        topCoordinateSystem.axisSegmentIndicatorSize = 0
        addSubview(topCoordinateSystem)
        
        bottomCoordinateSystem = CoordinateSystem(context: context)
        bottomCoordinateSystem.frame = CGRect(x: 0, y: topCoordinateSystem.frame.maxY + 50, width: 500, height: context.height)
        bottomCoordinateSystem.layer.masksToBounds = true
        bottomCoordinateSystem.axisSegmentIndicatorSize = 0
        bottomCoordinateSystem.drawGrid()
        addSubview(bottomCoordinateSystem)
        
        let topTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(coordinateSystemTapped(sender:)))
        topCoordinateSystem.addGestureRecognizer(topTapGestureRecognizer)
        let bottomTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(coordinateSystemTapped(sender:)))
        bottomCoordinateSystem.addGestureRecognizer(bottomTapGestureRecognizer)

        slopeLabel = UILabel(frame: CGRect(x: 0, y: topCoordinateSystem.frame.maxY + 8, width: 480, height: 40))
        slopeLabel.textAlignment = NSTextAlignment.right
        slopeLabel.text = "⌳ Tangent slope: n.a."
        slopeLabel.textColor = UIColor.white
        addSubview(slopeLabel)
        
        bottomCoordinateSystemLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 40))
        bottomCoordinateSystemLabel.font = UIFont.boldSystemFont(ofSize: 12)
        bottomCoordinateSystemLabel.textColor = UIColor.white
        bottomCoordinateSystemLabel.text = ""
        bottomCoordinateSystem.contentView.addSubview(bottomCoordinateSystemLabel)
        
        xCoordinateLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 40))
        xCoordinateLabel.font = UIFont.boldSystemFont(ofSize: 12)
        xCoordinateLabel.textColor = UIColor.white
        xCoordinateLabel.text = ""
        bottomCoordinateSystem.contentView.addSubview(xCoordinateLabel)

    }
    
    @objc func coordinateSystemTapped(sender: UITapGestureRecognizer) {
        guard let function = self.function else { return }

        let location = sender.location(in: topCoordinateSystem)
        let denormalizedLocation = context.denormalize(point: CGPoint(x: location.x - context.width / 2, y: location.y - context.width / 2))
        
        tangentPoint = denormalizedLocation.x
        
        if (verticalIndicator == nil) {
            verticalIndicator = CAShapeLayer()
            verticalIndicator.strokeColor = UIColor(white: 1, alpha: 0.4).cgColor
            verticalIndicator.lineWidth = 2.0
            verticalIndicator.lineDashPattern = [NSNumber(integerLiteral: 10), NSNumber(integerLiteral: 5)]
            
            layer.addSublayer(verticalIndicator)
            
            horizontalIndicator = CAShapeLayer()
            horizontalIndicator.strokeColor = UIColor(white: 1, alpha: 0.4).cgColor
            horizontalIndicator.lineWidth = 2.0
            horizontalIndicator.lineDashPattern = [NSNumber(integerLiteral: 10), NSNumber(integerLiteral: 5)]
            horizontalIndicator.zPosition = 2
            
            bottomCoordinateSystem.contentView.layer.addSublayer(horizontalIndicator)
            
        }
        
        let vPath = CGMutablePath()
        vPath.move(to: CGPoint(x: location.x, y: 0))
        vPath.addLine(to: CGPoint(x: location.x, y: frame.size.height))
        verticalIndicator.path = vPath
        
        let denormalizedY = function.derivative(tangentPoint)
        let y = context.normalize(point: CGPoint(x: 0, y: denormalizedY)).y
        let hPath = CGMutablePath()
        hPath.move(to: CGPoint(x: -900, y: y))
        hPath.addLine(to: CGPoint(x: bottomCoordinateSystem.bounds.maxX, y: y))
        horizontalIndicator.path = hPath
        
        linearAffinePointView.center = context.normalize(point: CGPoint(x: tangentPoint, y: function.eval(tangentPoint)))
        showTangent()
        
    }
    
    private func showTangent() {
        guard let function = self.function else { return }

        var animationType = Graph.AnimationType.morph
        if (linearAffineFunction == nil) {
            linearAffineFunction = Graph()
            linearAffineFunction.strokeColor = UIColor(red: 250/255, green: 185/255, blue: 67/255, alpha: 1).cgColor
            topCoordinateSystem.contentView.layer.addSublayer(linearAffineFunction)
            var animationType = Graph.AnimationType.draw
        }
        
        let x = tangentPoint
        let slope = function.derivative(x)
        let y = function.eval(x)
        let n = y - slope * x
        
        func linearAffine(x: CGFloat) -> CGFloat {
            return slope * x + n
        }
        
        linearAffineFunction.plot(with: context.intermediateValues.map{ CGPoint(x: $0, y: linearAffine(x: $0)) }, context: context, animationType: animationType)
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let slopeStr = formatter.string(from: NSNumber(value: Double(slope))) ?? "0"
        slopeLabel.text = "⌳ Tangent slope: " + slopeStr
        
        bottomCoordinateSystemLabel.center = CGPoint(x: 0, y: context.normalize(point: CGPoint(x:0, y:slope)).y)
        bottomCoordinateSystemLabel.text = slopeStr
        
        let xStr = formatter.string(from: NSNumber(value: Double(x))) ?? "0"

        xCoordinateLabel.center = CGPoint(x: context.normalize(x: x), y: 10)
        xCoordinateLabel.text = "\(xStr)"
    }
    
    public func setFunction(_ function: Function, animated: Bool = true) {
        self.function = function
        
        let topGraph = Graph()
        topGraph.plot(with: context.intermediateValues.map{ CGPoint(x: $0, y: function.eval($0)) }, context: context, animationType: .draw)
        topGraph.strokeColor = UIColor(red: 1, green: 30/255, blue: 80/255, alpha: 1.0).cgColor
        topCoordinateSystem.contentView.layer.addSublayer(topGraph)
        
        let bottomGraph = Graph()
        bottomGraph.plot(with: context.intermediateValues.map{ CGPoint(x: $0, y: function.derivative($0)) }, context: context, animationType: .draw)
        bottomGraph.strokeColor = UIColor(red: 32/255, green: 209/255, blue: 1, alpha: 1).cgColor
        bottomCoordinateSystem.contentView.layer.addSublayer(bottomGraph)
        
    }
}
