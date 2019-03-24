import PlaygroundSupport
import UIKit
import CoreGraphics



public struct Context {
    let maxX: CGFloat
    let maxY: CGFloat
    let numberOfSamples: Int
    let width: CGFloat
    let height: CGFloat
    
    public init(maxX: CGFloat, maxY: CGFloat, numberOfSamples: Int, width: CGFloat, height: CGFloat) {
        self.maxX = maxX
        self.maxY = maxY
        self.numberOfSamples = numberOfSamples
        self.width = width
        self.height = height
    }
    
    public var intermediateValues: [CGFloat] {
        let step = maxX / CGFloat(numberOfSamples)
        return Array(stride(from: -maxX, through: maxX, by: step))
    }
    
    public func normalize(point: CGPoint) -> CGPoint {
        let x = normalize(x: point.x)
        let y = normalize(y: point.y)
        return CGPoint(x: x, y: y)
    }
    
    public func normalize(y: CGFloat) -> CGFloat {
        let y = height / (2*maxY) * y * (-1)
        return y
    }
    
    public func normalize(x: CGFloat) -> CGFloat {
        return width / (2*maxX) * x
    }
    
    public func denormalize(point: CGPoint) -> CGPoint {
        let x = denormalize(x: point.x)
        let y = denormalize(y: point.y)
        return CGPoint(x: x, y: y)
    }
    
    public func denormalize(x: CGFloat) -> CGFloat {
        return (2*maxX) / width * x
    }
    
    public func denormalize(y: CGFloat) -> CGFloat {
        return (2*maxY) / height * y * (-1)
    }

}

public class Graph: CAShapeLayer {
    
    public enum AnimationType {
        case none
        case draw
        case morph
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(layer: Any) {
        super.init(layer: layer)
    }
    
    override public init() {
        super.init()
    }
    
    public func plot(with samples: [CGPoint], context: Context, animationType: AnimationType = .none) {
        let samples = samples.map { context.normalize(point: $0) }
        guard let firstSample = samples.first else { return }
        let drawPath = CGMutablePath()
        drawPath.move(to: firstSample)
        
        samples.suffix(from: 1).forEach {
            drawPath.addLine(to: $0)
        }
        
        fillColor = UIColor.clear.cgColor
        lineWidth = 2.0
        strokeStart = 0
        strokeEnd = animationType == .draw ? 0 : 1
        
        if (animationType == .draw) {
            path = drawPath
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.toValue = 1
            animation.duration = 1.5
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            
            add(animation, forKey: "line")
        } else if (animationType == .morph) {
            let animation = CABasicAnimation(keyPath: "path")
            animation.toValue = drawPath
            animation.duration = 1
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.fillMode = CAMediaTimingFillMode.both
            animation.isRemovedOnCompletion = false
            animation.setValue("morph", forKey: "animationId")
            animation.setValue(UIBezierPath(cgPath: drawPath), forKey: "finalPath")
            animation.delegate = self
            
            add(animation, forKey: "line")
        } else {
            path = drawPath
        }
    }
}

extension Graph: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let key = anim.value(forKey: "animationId") as? String, let drawPath = anim.value(forKey: "finalPath") as? UIBezierPath, key == "morph" else { return }
        path = drawPath.cgPath
    }
}

public class CoordinateSystem: UIView {
    var context: Context
    var grid: CAShapeLayer = CAShapeLayer()
    public var contentView: UIView = UIView()
    
    public var axisColor: UIColor = UIColor(white: 0.75, alpha: 1)
    public var axisWidth: CGFloat = 2.0
    public var axisSegmentIndicatorSize: CGFloat = 0.1
    
    public init(context: Context) {
        self.context = context
        super.init(frame: CGRect(x: 0, y:0, width: context.width, height: context.height))
        
        contentView.frame = bounds
        contentView.bounds = CGRect(x: -frame.midX, y: -frame.midY, width: frame.size.width, height: frame.size.height)
        contentView.backgroundColor = UIColor.black
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func drawGrid() {
        let yAxisPath = CGMutablePath()
        yAxisPath.move(to: CGPoint(x: 0, y: -bounds.maxY))
        yAxisPath.addLine(to: CGPoint(x: 0, y: bounds.maxY))
        
        let yAxis = CAShapeLayer()
        yAxis.path = yAxisPath
        yAxis.fillColor = UIColor.clear.cgColor
        yAxis.strokeColor = axisColor.cgColor
        yAxis.lineWidth = axisWidth
        
        let xAxisPath = CGMutablePath()
        xAxisPath.move(to: CGPoint(x: -bounds.maxX, y:0))
        xAxisPath.addLine(to: CGPoint(x: bounds.maxX, y:0))
        
        let xAxis = CAShapeLayer()
        xAxis.path = xAxisPath
        xAxis.fillColor = UIColor.clear.cgColor
        xAxis.strokeColor = axisColor.cgColor
        xAxis.lineWidth = axisWidth
        
        contentView.layer.addSublayer(yAxis)
        contentView.layer.addSublayer(xAxis)
        
        let rangeY = Int(round(context.maxY))
        let rangeX = Int(round(context.maxX))
        let markerIndicator = CAShapeLayer()
        let markerPath = CGMutablePath()
        for x in -rangeX...rangeX {
            let p1 = CGPoint(x: CGFloat(x), y: -axisSegmentIndicatorSize / 2.0)
            let p2 = CGPoint(x: CGFloat(x), y: axisSegmentIndicatorSize / 2.0)
            markerPath.move(to: context.normalize(point: p1))
            markerPath.addLine(to: context.normalize(point: p2))
        }
        for y in -rangeY...rangeY {
            let p1 = CGPoint(x: -axisSegmentIndicatorSize / 2.0, y: CGFloat(y))
            let p2 = CGPoint(x: axisSegmentIndicatorSize / 2.0, y: CGFloat(y))
            markerPath.move(to: context.normalize(point: p1))
            markerPath.addLine(to: context.normalize(point: p2))
        }
        markerIndicator.path = markerPath
        markerIndicator.lineWidth = axisWidth
        markerIndicator.strokeColor = axisColor.cgColor
        contentView.layer.addSublayer(markerIndicator)
    }
}
