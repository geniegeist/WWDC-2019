import PlaygroundSupport
import UIKit
import CoreGraphics

public class TaylorView: UIView {
    
    public struct Function {
        let identifier: String
        let eval: (CGFloat) -> CGFloat
        let derivative: (CGFloat, Int) -> CGFloat
        let inDomain: (CGFloat) -> Bool
        let defaultTaylorPoint: CGFloat
        
        public init(identifier: String, eval: @escaping (CGFloat) -> CGFloat, derivative: @escaping (CGFloat, Int) -> CGFloat, inDomain: @escaping (CGFloat) -> Bool, defaultTaylorPoint: CGFloat = 0) {
            self.identifier = identifier
            self.eval = eval
            self.derivative = derivative
            self.inDomain = inDomain
            self.defaultTaylorPoint = defaultTaylorPoint
        }
    }
    
    private var orderLabel: UILabel!
    private var selectOptionsView: UIStackView!
    private var taylorPointIndicator: UIView!
    
    private var context: Context
    private var coordinateSystem: CoordinateSystem!
    
    private var graph: Graph!
    private var graphColor: UIColor = UIColor(red: 1, green: 30/255, blue: 80/255, alpha: 1.0)
    private var taylorGraph: Graph!
    private var taylorGraphColor = UIColor(red: 32/255, green: 209/255, blue: 1, alpha: 1)
    private var taylorExpansion: TaylorExpansion?
    private var taylorPoint: CGFloat = 0
    
    private var customFunction: Function?
    private var options: [Function] = []
    private var selectedIndex: Int = 0 {
        didSet {
            computeGraph()
            computeTaylor()
        }
    }
    private var order: Int = 1 {
        didSet {
            DispatchQueue.main.async {
                self.orderLabel.text = "Order of the Taylor polynomial: \(self.order)"
            }
            computeTaylor()
        }
    }
    
    public init(context: Context, customFunction: Function?) {
        self.context = context
        self.customFunction = customFunction
        super.init(frame: CGRect(x: 0, y:0, width: context.width, height: context.height + 200))
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        coordinateSystem = CoordinateSystem(context: context)
        coordinateSystem.contentView.backgroundColor = UIColor.clear
        coordinateSystem.contentView.layer.masksToBounds = true
        coordinateSystem.drawGrid()
        coordinateSystem.frame = coordinateSystem.frame.offsetBy(dx: 0, dy: 100)
        addSubview(coordinateSystem)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(coordinateSystemTapped(sender:)))
        coordinateSystem.addGestureRecognizer(tapGestureRecognizer)
        
        options = [Function(identifier: "Exp",
                            eval: { Exp.eval(x: $0) },
                            derivative: { Exp.derivative(x: $0, order: $1) },
                            inDomain: { Exp.isInDomain(x: $0) }),
                   Function(identifier: "Cosine",
                            eval: { Cosine.eval(x: $0) },
                            derivative: { Cosine.derivative(x: $0, order: $1) },
                            inDomain: { Sine.isInDomain(x: $0) }),
                   Function(identifier: "Sine",
                            eval: { Sine.eval(x: $0) },
                            derivative: { Sine.derivative(x: $0, order: $1) },
                            inDomain: { Sine.isInDomain(x: $0) }),
                   Function(identifier: "Log(x+1)",
                            eval: { LogXPlus1.eval(x: $0) },
                            derivative: { LogXPlus1.derivative(x: $0, order: $1) },
                            inDomain: { LogXPlus1.isInDomain(x: $0) })]
        
        if let customFunction = self.customFunction {
            options.append(customFunction)
        }
        
        selectOptionsView = UIStackView(frame: CGRect(x: 20, y: 20, width: bounds.size.width - 20 * 2, height: 30))
        selectOptionsView.spacing = 12
        selectOptionsView.distribution = .fillEqually
        addSubview(selectOptionsView)
        
        options.enumerated().forEach { (index, option) in
            let optionButton = UIButton(type: .system)
            optionButton.setTitle(option.identifier, for: .normal)
            optionButton.setTitleColor(graphColor, for: .normal)
            optionButton.layer.borderColor = graphColor.cgColor
            optionButton.layer.borderWidth = 1
            optionButton.sizeToFit()
            optionButton.layer.cornerRadius = optionButton.frame.size.height / 2
            optionButton.tag = index
            optionButton.addTarget(self, action: #selector(optionButtonTapped(sender:)), for: .touchUpInside)
            selectOptionsView.addArrangedSubview(optionButton)
        }
        
        
        let taylorStepper = UIStepper(frame: CGRect(x: 380, y: selectOptionsView.frame.maxY + 24, width: 0, height: 0))
        taylorStepper.addTarget(self, action: #selector(stepperValueChanged(_ :)), for: .valueChanged)
        taylorStepper.tintColor = UIColor.white
        taylorStepper.value = 1
        taylorStepper.maximumValue = 20
        addSubview(taylorStepper)
        
        orderLabel = UILabel(frame: CGRect(x:20, y: selectOptionsView.frame.maxY + 24, width: 300, height: taylorStepper.frame.size.height))
        orderLabel.text = "Order of the Taylor expansion: \(order)"
        orderLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        orderLabel.textColor = UIColor.white
        addSubview(orderLabel)
        
        taylorPointIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        taylorPointIndicator.backgroundColor = UIColor.white
        taylorPointIndicator.layer.cornerRadius = taylorPointIndicator.frame.size.width / 2
        taylorPointIndicator.center = .zero
        coordinateSystem.contentView.addSubview(taylorPointIndicator)
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        order = Int(sender.value)
        
        if (graph == nil) {
            computeGraph()
        }
    }
    
    @objc func optionButtonTapped(sender: UIButton) {
        selectedIndex = sender.tag
    }
    
    @objc func coordinateSystemTapped(sender: UITapGestureRecognizer) {
        let location = sender.location(in: coordinateSystem)
        var denormalizedLocation = context.denormalize(point: CGPoint(x: location.x - context.width / 2, y: location.y - context.width / 2))
        
        if (!options[selectedIndex].inDomain(denormalizedLocation.x)) {
            denormalizedLocation = .zero
        }
        
        if (graph == nil) {
            computeGraph()
        }
        
        DispatchQueue.main.async {
            let point = CGPoint(x: denormalizedLocation.x, y: self.options[self.selectedIndex].eval(denormalizedLocation.x))
            
            self.taylorPointIndicator.center = self.context.normalize(point: point)
        }
        
        
        taylorPoint = denormalizedLocation.x
        computeTaylor()
    }
    
    private func computeGraph() {
        var animationType = Graph.AnimationType.morph
        if graph == nil {
            animationType = .draw
            graph = Graph()
            graph.strokeColor = graphColor.cgColor
            coordinateSystem.contentView.layer.addSublayer(graph)
        }
        
        let option = options[selectedIndex]
        graph.plot(with: context.intermediateValues
            .filter{ option.inDomain($0) }
            .map{ CGPoint(x: $0, y: option.eval($0)) }
            .filter{ $0.y.isFinite },
                   context: context,
                   animationType: animationType)
    }
    
    private func computeTaylor() {
        var animationType = Graph.AnimationType.morph
        if taylorGraph == nil {
            animationType = .draw
            taylorGraph = Graph()
            taylorGraph.strokeColor = taylorGraphColor.cgColor
            taylorGraph.zPosition = 1
            coordinateSystem.contentView.layer.addSublayer(taylorGraph)
        }
        
        if (!options[selectedIndex].inDomain(taylorPoint)) {
            taylorPoint = options[selectedIndex].defaultTaylorPoint
        }
        
        let taylorExpansion = TaylorExpansion(point: taylorPoint, order: order, derivative: options[selectedIndex].derivative)
        let taylorSample = context.intermediateValues
            .filter{ options[selectedIndex].inDomain($0) }
            .map { CGPoint(x: $0, y: taylorExpansion.eval(x: $0)) }
            .filter{ $0.y.isFinite }
        taylorGraph.plot(with: taylorSample, context: context, animationType: animationType)
        
        
        
        let point = CGPoint(x: taylorPoint, y: options[selectedIndex].eval(taylorPoint))
        taylorPointIndicator.center = self.context.normalize(point: point)
        
        
        self.taylorExpansion = taylorExpansion
    }
}
