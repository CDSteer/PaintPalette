//  ViewController.swift
//  IOS10DrawShapesTutorial
//
//  Created by Cameron Steer on 05/05/2017.
//  Copyright © 2017 Cameron Steer. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    var bluetoothIO: BluetoothIO!
    @IBOutlet weak var dataLbl: UILabel!
    let paletteW:Int = 40
    let paletteH:Int = 40

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
    
    var lines: [Line] = []
    var lastPoint: CGPoint!
    

    var paintSections = [UIView]()

    var onScreenPaints = [CAShapeLayer]()
    var onCanvasPaints = [UIView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // paintRed.backgroundColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        // paintRed.frame = CGRect(x: 50, y: 100, width: 50, height: 50)
        
        // paintGreen.backgroundColor = UIColor.init(red: 0, green: 255, blue: 0, alpha: 1)
        // paintGreen.frame = CGRect(x: 150, y: 100, width: 50, height: 50)
        
        
        // paintBlue.backgroundColor = UIColor.init(red: 0, green: 0, blue: 255, alpha: 1)
        // paintBlue.frame = CGRect(x: 250, y: 100, width: 50, height: 50)
        
        // self.view.addSubview(paintRed)
        // self.view.addSubview(paintGreen)
        // self.view.addSubview(paintBlue)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap(_:)))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGesture)
        self.view.addGestureRecognizer(longGesture)
        
        paintSectionSetUp()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if (bluetoothIO != nil) {
            print(bluetoothIO)
            bluetoothIO.delegate = self
        } else {
            bluetoothIO = BluetoothIO(serviceUUID: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E", delegate: self)
        }
        
    }
    
    
    
    func paintSectionSetUp() {
        
        var xPlace:Int = 0
        var yPlace:Int = 150

        
        for y in 0...paletteH {
            for x in 0...paletteW {
                let i:Int = x+(y*paletteW)
                paintSections.append(UIView())
                paintSections[i].frame = CGRect(x: xPlace, y: yPlace, width: 10, height: 10)
                paintSections[i].backgroundColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 1)
                
                self.view.addSubview(paintSections[i])
                
                
                xPlace = xPlace+10
                if (xPlace>=400){
                    yPlace = yPlace+10
                    xPlace=0
                }
            }
        }
        
        paintSections[0].backgroundColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        for _ in 0...250{
            drawCircle(CGPoint(x: paintSections[0].frame.origin.x+25, y: paintSections[0].frame.origin.y+25), paintColour: (paintSections[0].backgroundColor?.cgColor)!)
        }
        paintSections[1].backgroundColor = UIColor.init(red: 0, green: 255, blue: 0, alpha: 1)
        for _ in 0...250{
            drawCircle(CGPoint(x: paintSections[1].frame.origin.x+25, y: paintSections[1].frame.origin.y+25), paintColour: (paintSections[1].backgroundColor?.cgColor)!)
        }
        paintSections[2].backgroundColor = UIColor.init(red: 0, green: 0, blue: 225, alpha: 1)
        for _ in 0...250{
            drawCircle(CGPoint(x: paintSections[2].frame.origin.x+25, y: paintSections[2].frame.origin.y+25), paintColour: (paintSections[2].backgroundColor?.cgColor)!)
        }
        
        drawPaintsections()
        
    }
    
    func drawPaintsections() {
        for i in 0...paletteW {
            for j in 0...paletteH {
                self.view.addSubview(paintSections[i*j])
            }
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastPoint = touches.first?.location(in: self.view)
        if let touch = touches.first {
            let position = touch.location(in: self.view)
            //print(position.x)
            //print(position.y)
            
            paintSeletion(position: position)
            spread = true
            
            for y in 0...paletteH {
                for x in 0...paletteW {
                    let i:Int = x+(y*paletteW)
                    if (paintSections[i].frame.contains(position)){
                        
                        let newColour:CGColor = (paintSections[i].backgroundColor?.cgColor)!
                        let components:[CGFloat] = newColour.components!
                        
                        let newColor:[Float] = reverseColors(colors: components)
                        
                        brushColor = UIColor.init(red: CGFloat(newColor[0]), green: CGFloat(newColor[1]), blue: CGFloat(newColor[2]), alpha: 1).cgColor
                        
                        let newBrushColour:CGColor = brushColor
                        
                        let newBrushColourComponents:[CGFloat] = newBrushColour.components!
                        
                        print("red",newBrushColourComponents[0]*255)
                        print("green",newBrushColourComponents[1]*255)
                        print("blue",newBrushColourComponents[2]*255)
                        
                    }
                }
            }
            
        }
        print("touchesBegan end")
    }
    func reverseColors(colors: [CGFloat]) -> [Float] {
        var color:[Float]=[0,0,0]
        print("reverseColors:red", colors[0])
        print("reverseColors:green", colors[1])
        print("reverseColors:blue", colors[2])
        
        color[0]=(255 - (255-Float(colors[0])))
        color[1]=(255 - (255-Float(colors[1])))
        color[2]=(255 - (255-Float(colors[2])))
        
        print("reverseColor:red", color[0])
        print("reverseColor:green", color[1])
        print("reverseColor:blue", color[2])
        return color
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let newPoint = touches.first?.location(in: self.view)
        lines.append(Line(start: lastPoint, end: newPoint!))
        
        if let touch = touches.first {
            let position = touch.location(in: self.view)
            
            if (spread){
                drawCircle(position, paintColour: brushColor)
            }
            paintSeletion(position: position)
            
            for onCanvasPaint in onCanvasPaints {
                
                if (onCanvasPaint.frame.contains(position)){
                    // let components:[CGFloat] = newColour.cgColor.components!
                    // print("red",components[0]*255)
                    // print("green",components[1]*255)
                    // print("blue",components[2]*255)
                    
                    onCanvasPaint.backgroundColor = UIColor.init(red: (brushColor.components?[0])!, green: (brushColor.components?[1])!, blue: (brushColor.components?[2])!, alpha: 1)
                }
            }
            
            for y in 0...paletteH {
                for x in 0...paletteW {
                    let i:Int = x+(y*paletteW)
                    if (paintSections[i].frame.contains(position) ){
                        
                        let newColour:CGColor = (paintSections[i].backgroundColor?.cgColor)!
                        let components:[CGFloat] = newColour.components!
                        
                        // brushColor = UIColor.init(red: components[0], green: components[1], blue: components[2], alpha: 1).cgColor
                        
                        
                    }
            }
            

            
            var countRed:Int = 0
            var countGreen:Int = 0
            var countBlue:Int = 0
            
            
            for y in 0...paletteH {
                for x in 0...paletteW {
                    let i:Int = x+(y*paletteW)
                    if (paintSections[i].frame.contains(position)){
                        for onCanvasPaint in onCanvasPaints {
                            // if (paintSection.frame.contains(CGPoint(x: (onCanvasPaint.path?.currentPoint.x)!, y: (onCanvasPaint.path?.currentPoint.y)!))){
                            if (paintSections[i].frame.contains(CGPoint(x: (onCanvasPaint.frame.origin.x), y: (onCanvasPaint.frame.origin.y)))){
                                
                                // let newColour:CGColor = onCanvasPaint.fillColor!
                                
                                let newColour:CGColor = (onCanvasPaint.backgroundColor?.cgColor)!
                                
                                let components:[CGFloat] = newColour.components!
                                
                                if ((components[0])>0.0){ countRed = countRed + 1}
                                if ((components[1])>0.0){ countGreen = countGreen + 1}
                                if ((components[2])>0.0){ countBlue = countBlue + 1}
                                
                                

                                
                                // 765
                                // 2500 pixels in a section
                                // totalRed = totalRed + Int(Float(components[0]*255))
                                // totalGreen = totalGreen + Int(Float(components[1]*255))
                                // totalBlue = totalBlue + Int(Float(components[2]*255))
                                
                                
                            }
                            var newRed:Float
                            var newGreen:Float
                            var newBlue:Float
                            
                            // var paintInSection:Int =(countBlue+countGreen+countBlue)
                            
                            newRed = map(value: Float((Float(countRed)/Float(5))*100), istart: 0, istop: 100, ostart: 0, ostop: 255)
                            newGreen = map(value: Float((Float(countGreen)/Float(5))*100), istart: 0, istop: 100, ostart: 0, ostop: 255)
                            newBlue = map(value: Float((Float(countBlue)/Float(5))*100), istart: 0, istop: 100, ostart: 0, ostop: 255)
      
                            
                            var a:CGFloat = 1.0
                            if (newRed>0){ a = CGFloat(map(value: newRed, istart: 0, istop: 255, ostart: 0, ostop: 1)) }
                            if (newGreen>0){ a = CGFloat(map(value: newGreen, istart: 0, istop: 255, ostart: 0, ostop: 1)) }
                            if (newBlue>0){ a = CGFloat(map(value: newBlue, istart: 0, istop: 255, ostart: 0, ostop: 1)) }

                            
                            // newRed = Float(totalRed/countRed)
                            // newGreen = Float(totalGreen/countGreen)
                            // newBlue = Float(totalBlue/countBlue)
                            // print("newRed test", newRed*255)
                            
                            newColour = UIColor.init(red: CGFloat(newRed)/255, green: CGFloat(newGreen)/255, blue: CGFloat(newBlue)/255, alpha: a)
                            paintSections[i].backgroundColor = newColour
                        }
                    }
                    }
                }
            }
        }
        

        
        // drawLineFromPoint(start: lastPoint, toPoint: newPoint!, ofColor: UIColor.init(red: (brushColor.components?[0])!, green: (brushColor.components?[1])!, blue: (brushColor.components?[2])!, alpha: 1), inView: self.view)
        
        lastPoint = touches.first?.location(in: self.view)

        
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
        shapeLayer.lineWidth = 10.0
        
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
        
        k.frame = CGRect(x: touchPoint.x, y: touchPoint.y, width: 50, height: 50)
        k.backgroundColor = UIColor.init(red: (paintColour.components?[0])!, green: (paintColour.components?[1])!, blue: (paintColour.components?[2])!, alpha: 1)
        onCanvasPaints.append(k)
        // self.view.addSubview(k)
        
        
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
    @IBAction func clearTaped(){
        viewDidLoad()
    }
    @IBAction func red(){
        brushColor = UIColor.red.cgColor
    }
    @IBAction func green(){
        brushColor = UIColor.green.cgColor
    }
    @IBAction func blue(){
        brushColor = UIColor.blue.cgColor
    }
    


    
    func showValues(_ fullString: String) {
        print(fullString)
        if (fullString == "clear"){
            viewDidLoad()
        }
    }
    
    func recievedValues(_ value: String) {
        print("recievedValues")
        showValues(value)
    }
    
}

extension ViewController: BluetoothIODelegate {
    func bluetoothIO(_ bluetoothIO: BluetoothIO, didReceiveValue value: String) {
        self.recievedValues(value)
    }
}

extension CALayer {
    
    func colorOfPoint(point:CGPoint) -> CGColor {
        
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        self.render(in: context!)
        
        let red: CGFloat   = CGFloat(pixel[0]) / 255.0
        let green: CGFloat = CGFloat(pixel[1]) / 255.0
        let blue: CGFloat  = CGFloat(pixel[2]) / 255.0
        let alpha: CGFloat = CGFloat(pixel[3]) / 255.0
        
        let color = UIColor(red:red, green: green, blue:blue, alpha:alpha)
        
        return color.cgColor
    }
}


