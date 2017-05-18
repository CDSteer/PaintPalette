//
//  ShapeView.swift
//  IOS10DrawShapesTutorial
//
//  Created by Cameron Steer on 05/05/2017.
//  Copyright © 2017 Cameron Steer. All rights reserved.
//

import UIKit



class ShapeView: UIView {
    
    let paintBlue: UIView = UIView()
    let paintRed: UIView = UIView()
    let paintGreen: UIView = UIView()
    var spread:Bool = false
    var brushColor:CGColor = UIColor.init(red: CGFloat(0), green: CGFloat(0), blue: CGFloat(0), alpha: 0).cgColor
    var newColour:UIColor = UIColor()
    var touchingscreen:Bool = false
    var longPressed = false
    var selectedRow = 0
    
    var longPressBeginTime: TimeInterval = 0.0
    var gestureTime:Float = 0.0
    
    var lastPoint: CGPoint!
    
    
    var paintSections=[UIView]()
    var onScreenPaints = [CAShapeLayer]()
    var onCanvasPaints = [UIView]()

    var currentShapeType: Int = 0
    var lines: [Line] = []
    

    

    
    init() {
        super.init(frame: UIScreen.main.bounds);
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap(_:)))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(longGesture)
        
        paintSectionSetUp()

        
        // Instantiate a new Plot_Demo object (inherits and has all properties of UIView)
        let k = Plot_Demo(frame: CGRect(x: 75, y: 75, width: 150, height: 150))
        
        // Put the rectangle in the canvas in this new object
        k.draw(CGRect(x: 50, y: 50, width: 100, height: 100))
        
        // view: UIView was created earlier using StoryBoard
        // Display the contents (our rectangle) by attaching it
        self.addSubview(k)
        return;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func paintSectionSetUp() {
        
        var xPlace:Int = 0
        var yPlace:Int = 150
        
        for i in 0...2000 {
            paintSections.append(UIView())
            paintSections[i].frame = CGRect(x: xPlace, y: yPlace, width: 50, height: 50)
            paintSections[i].backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
            
            self.addSubview(paintSections[i])
            
            
            xPlace = xPlace+50
            if (xPlace>=400){
                yPlace = yPlace+50
                xPlace=0
            }
        }
        
        paintSections[0].backgroundColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        for _ in 0...2500{
            drawCircle(CGPoint(x: paintSections[0].frame.origin.x+25, y: paintSections[0].frame.origin.y+25), paintColour: (paintSections[0].backgroundColor?.cgColor)!)
        }
        paintSections[1].backgroundColor = UIColor.init(red: 0, green: 255, blue: 0, alpha: 1)
        for _ in 0...2500{
            drawCircle(CGPoint(x: paintSections[1].frame.origin.x+25, y: paintSections[1].frame.origin.y+25), paintColour: (paintSections[1].backgroundColor?.cgColor)!)
        }
        paintSections[2].backgroundColor = UIColor.init(red: 0, green: 0, blue: 225, alpha: 1)
        for _ in 0...2500{
            drawCircle(CGPoint(x: paintSections[2].frame.origin.x+25, y: paintSections[2].frame.origin.y+25), paintColour: (paintSections[2].backgroundColor?.cgColor)!)
        }
        
        drawPaintsections()
        
    }
    
    func drawPaintsections() {
        for paintSection in paintSections {
            self.addSubview(paintSection)
        }
        
    }
    
    func normalTap(_ sender: UIGestureRecognizer){
        
        print("Normal tap")
    }
    
    func longTap(_ sender: UILongPressGestureRecognizer){
        print("Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
        }
        
        if (sender.state == UIGestureRecognizerState.ended)
        {
            gestureTime = Float(NSDate.timeIntervalSinceReferenceDate - longPressBeginTime + sender.minimumPressDuration)
            print("Gesture time = \(gestureTime)")
        }
        else if (sender.state == UIGestureRecognizerState.began)
        {
            print("Began")
            longPressBeginTime = NSDate.timeIntervalSinceReferenceDate
        }
        
        print("alpha", map(value: gestureTime, istart: 0, istop: 2, ostart: 0, ostop: 1))
        // brushColor = UIColor.init(red: (brushColor.components?[0])!, green: (brushColor.components?[1])!, blue: (brushColor.components?[2])!, alpha: CGFloat(map(value: gestureTime, istart: 0, istop: 2, ostart: 0, ostop: 1))).cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = touches.first?.location(in: self)
        if let touch = touches.first {
            let position = touch.location(in: self)
            //print(position.x)
            //print(position.y)
            
            paintSeletion(position: position)
            spread = true
            
            for paintSection in paintSections {
                if (paintSection.frame.contains(position)){
                    
                    let newColour:CGColor = (paintSection.backgroundColor?.cgColor)!
                    let components:[CGFloat] = newColour.components!
                    
                    brushColor = UIColor.init(red: components[0], green: components[1], blue: components[2], alpha: 1).cgColor
                    
                    let newBrushColour:CGColor = brushColor
                    
                    let newBrushColourComponents:[CGFloat] = newBrushColour.components!
                    
                    print("red",newBrushColourComponents[0]*255)
                    print("green",newBrushColourComponents[1]*255)
                    print("blue",newBrushColourComponents[2]*255)
                    
                }
            }
            
        }
        print("touchesBegan end")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let newPoint = touches.first?.location(in: self)
        lines.append(Line(start: lastPoint, end: newPoint!))
        
        if let touch = touches.first {
            let position = touch.location(in: self)
            
            if (spread){
                drawCircle(position, paintColour: brushColor)
            }
            paintSeletion(position: position)
            
            for i in 0...onScreenPaints.count-1 {
                if (onScreenPaints[i].frame.contains(position)){
                    let components:[CGFloat] = newColour.cgColor.components!
                    
                    print("red",components[0]*255)
                    print("green",components[1]*255)
                    print("blue",components[2]*255)
                    
                    self.onScreenPaints[i].fillColor! = UIColor.init(red: CGFloat(0), green: CGFloat(0), blue: CGFloat(0), alpha: 0).cgColor
                }
            }
            
            for i in 0...onScreenPaints.count-1 {
                if (onScreenPaints[i].frame.contains(position)){
                    let components:[CGFloat] = newColour.cgColor.components!
                    
                    print("red",components[0]*255)
                    print("green",components[1]*255)
                    print("blue",components[2]*255)
                    
                    self.onScreenPaints[i].fillColor! = UIColor.init(red: CGFloat(0), green: CGFloat(0), blue: CGFloat(0), alpha: 0).cgColor
                }
            }
            
            var totalRed:Int = 0
            var totalGreen:Int = 0
            var totalBlue:Int = 0
            
            var countRed:Int = 0
            var countGreen:Int = 0
            var countBlue:Int = 0
            
            var overRed:Int = 0
            var overGreen:Int = 0
            var overBlue:Int = 0
            
            var paintInSection:Int = 1
            
            for paintSection in paintSections {
                if (paintSection.frame.contains(position)){
                    for onCanvasPaint in onCanvasPaints {
                        // if (paintSection.frame.contains(CGPoint(x: (onCanvasPaint.path?.currentPoint.x)!, y: (onCanvasPaint.path?.currentPoint.y)!))){
                        if (paintSection.frame.contains(CGPoint(x: (onCanvasPaint.frame.origin.x), y: (onCanvasPaint.frame.origin.y)))){
                            
                            // let newColour:CGColor = onCanvasPaint.fillColor!
                            
                            let newColour:CGColor = (onCanvasPaint.backgroundColor?.cgColor)!
                            
                            let components:[CGFloat] = newColour.components!
                            
                            if ((components[0])>0.0){ countRed = countRed + 1}
                            if ((components[1])>0.0){ countGreen = countGreen + 1}
                            if ((components[2])>0.0){ countBlue = countBlue + 1}
                            
                            
                            if (countRed > 255){ overRed = countRed - 255}
                            if (countGreen > 255){ overGreen = countGreen - 255}
                            if (countBlue > 255){ overBlue = countBlue - 255}
                            
                            // 765
                            // 2500 pixels in a section
                            // totalRed = totalRed + Int(Float(components[0]*255))
                            // totalGreen = totalGreen + Int(Float(components[1]*255))
                            // totalBlue = totalBlue + Int(Float(components[2]*255))
                            
                            
                        }
                        var newRed:Float
                        var newGreen:Float
                        var newBlue:Float
                        
                        paintInSection=(countBlue+countGreen+countBlue)
                        
                        newRed = map(value: Float((Float(countRed)/Float(2500))*100), istart: 0, istop: 100, ostart: 0, ostop: 255)
                        newGreen = map(value: Float((Float(countGreen)/Float(2500))*100), istart: 0, istop: 100, ostart: 0, ostop: 255)
                        newBlue = map(value: Float((Float(countBlue)/Float(2500))*100), istart: 0, istop: 100, ostart: 0, ostop: 255)
                        
                        //                        newRed = Float(totalRed/countRed)
                        //                        newGreen = Float(totalGreen/countGreen)
                        //                        newBlue = Float(totalBlue/countBlue)
                        //                        print("newRed test", newRed*255)
                        
                        newColour = UIColor.init(red: CGFloat(newRed)/255, green: CGFloat(newGreen)/255, blue: CGFloat(newBlue)/255, alpha: 1)
                        paintSection.backgroundColor = newColour
                    }
                }
            }
        }
        
        
        
    }
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        
        //design the path
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        spread = false
    }
    
    func isObjectNotNil(object:AnyObject!) -> Bool {
        if let _:AnyObject = object {
            return true
        }
        
        return false
    }
    
    
    
    func drawCircle(_ touchPoint:CGPoint, paintColour:CGColor) {
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: touchPoint.x, y: touchPoint.y), radius: CGFloat(10), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        
        
        shapeLayer.fillColor = paintColour
        onScreenPaints.append(shapeLayer)
        
        // view.layer.addSublayer(CGRect(x: touchPoint.x, y: touchPoint, width: 1, height: 1))
        let k = UIView()
        k.frame = CGRect(x: touchPoint.x, y: touchPoint.y, width: 1, height: 1)
        k.backgroundColor = UIColor.init(red: (paintColour.components?[0])!, green: (paintColour.components?[1])!, blue: (paintColour.components?[2])!, alpha: 1)
        onCanvasPaints.append(k)
        self.addSubview(k)
        
        
    }
    
    
    func paintSeletion(position: CGPoint) {
        let isPointInRed:Bool = paintRed.frame.contains(position)
        let isPointInGreen:Bool = paintGreen.frame.contains(position)
        let isPointInBlue:Bool = paintBlue.frame.contains(position)
        
        if (isPointInRed == true){
            brushColor = UIColor.red.cgColor
            spread = true
        }
        if (isPointInGreen == true){
            brushColor = UIColor.green.cgColor
            spread = true
        }
        if (isPointInBlue == true){
            brushColor = UIColor.blue.cgColor
            spread = true
        }
        
    }
    
    
    func map(value:Float, istart:Float, istop:Float, ostart:Float, ostop:Float) -> Float {
        return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))
    }
    
    
    
}
