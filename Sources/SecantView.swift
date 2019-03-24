import PlaygroundSupport
import UIKit
import CoreGraphics



public class SecantView: UIView {
    
    public struct Function {
        let eval: (CGFloat) -> CGFloat
        
        public init(eval: @escaping (CGFloat) -> CGFloat) {
            self.eval = eval
        }
    }
    
    public var context: Context
    
    var function: Function?
    
    var coordinateSystem: CoordinateSystem!
    
    var secantGraph: Graph!

    var point: UIView!
    var secPoint: UIView!
    var hIndicator: CAShapeLayer!
    var vIndicator: CAShapeLayer!
    
    var dxLabel: UILabel!
    var dyLabel: UILabel!
    var slopeLabel: UILabel!
    
    
    public init(context: Context) {
        self.context = context
        super.init(frame: CGRect(x: 0, y: 0, width: context.width, height: context.height))
        setup()
    }
    /*
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        coordinateSystem = CoordinateSystem(context: context)
        coordinateSystem.axisSegmentIndicatorSize = 0.1
        coordinateSystem.drawGrid()
        coordinateSystem.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        coordinateSystem.layer.masksToBounds = true
        addSubview(coordinateSystem)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(coordinateSystemTapped(sender:)))
        coordinateSystem.addGestureRecognizer(tapGestureRecognizer)
        
        point = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        point.backgroundColor = UIColor.white
        point.layer.cornerRadius = point.frame.size.width / 2
        point.layer.zPosition = 3
        coordinateSystem.contentView.addSubview(point)
        
        secPoint = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        secPoint.backgroundColor = UIColor.white
        secPoint.layer.cornerRadius = point.frame.size.width / 2
        secPoint.layer.zPosition = 3
        coordinateSystem.contentView.addSubview(secPoint)
        
        
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: .zero)
        
        hIndicator = CAShapeLayer()
        hIndicator.strokeColor = UIColor(white: 1, alpha: 0.4).cgColor
        hIndicator.lineWidth = 2
        hIndicator.path = path
        coordinateSystem.contentView.layer.addSublayer(hIndicator)
        
        vIndicator = CAShapeLayer()
        vIndicator.strokeColor = UIColor(white: 1, alpha: 0.4).cgColor
        vIndicator.lineWidth = 2
        vIndicator.path = path
        coordinateSystem.contentView.layer.addSublayer(vIndicator)
        
        dxLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 40))
        dxLabel.font = UIFont.boldSystemFont(ofSize: 12)
        dxLabel.textColor = UIColor.white
        dxLabel.text = ""
        coordinateSystem.contentView.addSubview(dxLabel)
        
        dyLabel = UILabel(frame: CGRect(x: 0, y: 50, width: 80, height: 40))
        dyLabel.font = UIFont.boldSystemFont(ofSize: 12)
        dyLabel.textColor = UIColor.white
        dyLabel.text = ""
        coordinateSystem.contentView.addSubview(dyLabel)
        
        slopeLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 150, height: 40))
        slopeLabel.font = UIFont.boldSystemFont(ofSize: 17)
        slopeLabel.textColor = UIColor.white
        slopeLabel.text = "Slope: n.a."
        addSubview(slopeLabel)
    }
    
    @objc func coordinateSystemTapped(sender: UITapGestureRecognizer) {        guard let function = self.function else { return }

        let location = sender.location(in: coordinateSystem)
        let denormalizedLocation = context.denormalize(point: CGPoint(x: location.x - context.width / 2, y: location.y - context.width / 2))
        
        let x = denormalizedLocation.x
        let y = function.eval(x)
        let p =  context.normalize(point: CGPoint(x: x, y: y))
        secPoint.center = p
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x:0, y: point.center.y))
        path.addLine(to: CGPoint(x: p.x, y: point.center.y))
        hIndicator.path = path
        
        let vPath = CGMutablePath()
        vPath.move(to: CGPoint(x:p.x, y: point.center.y))
        vPath.addLine(to: CGPoint(x: p.x, y: p.y))
        vIndicator.path = vPath

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let dx = context.denormalize(x: p.x)
        let h = formatter.string(from: NSNumber(value: Double(dx))) ?? "0"
        dxLabel.center = CGPoint(x: p.x / 2.0, y: point.center.y + 10)
        dxLabel.text = "dx = \(h)"
        
        let dy = context.denormalize(y: p.y - point.center.y)
        let dyStr = formatter.string(from: NSNumber(value: Double(dy))) ?? "0"
        dyLabel.center = CGPoint(x: p.x, y: -(p.y - point.center.y)/2 + p.y)
        dyLabel.text = "dy = \(dyStr)"
        
        slopeLabel.text = "Slope: \(dy / dx)"
        
        secantGraph.plot(with: context.intermediateValues.map{ CGPoint(x: $0, y: secant($0)) }, context: context, animationType: Graph.AnimationType.morph)
    }
    
    public func setFunction(_ function: Function, animated: Bool = true) {
        self.function = function
        
        let graph = Graph()
        graph.plot(with: context.intermediateValues.map{ CGPoint(x: $0, y: function.eval($0)) }, context: context, animationType: .draw)
        graph.strokeColor = UIColor(red: 1, green: 30/255, blue: 80/255, alpha: 1.0).cgColor
        coordinateSystem.contentView.layer.addSublayer(graph)
        
        point.center = CGPoint(x: 0, y: context.normalize(y: function.eval(0)))
        secPoint.center = CGPoint(x: 0, y: context.normalize(y: function.eval(0)))
        
        secantGraph = Graph()
        secantGraph.strokeColor = UIColor(red: 250/255, green: 185/255, blue: 67/255, alpha: 1).cgColor
        secantGraph.plot(with: context.intermediateValues.map{ CGPoint(x: $0, y: secant($0)) }, context: context, animationType: Graph.AnimationType.draw)
        coordinateSystem.contentView.layer.addSublayer(secantGraph)
    }
    
    func secant(_ x: CGFloat) -> CGFloat {
        let point1 = context.denormalize(point: self.point.center)
        let point2 = context.denormalize(point: self.secPoint.center)
        return point2.y * ( x - point1.x) / (point2.x - point1.x) + point1.y * (x-point2.x) / (point1.x - point2.x)
    }
}
