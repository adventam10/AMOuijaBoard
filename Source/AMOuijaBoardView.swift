//
//  AMOuijaBoardView.swift
//  AMOuijaBoard, https://github.com/adventam10/AMOuijaBoard
//
//  Created by am10 on 2019/10/20.
//  Copyright © 2019 am10. All rights reserved.
//

import UIKit

public protocol AMOuijaBoardViewDelegate: AnyObject {
    func ouijaBoardView(_ ouijaBoardView: AMOuijaBoardView, didSelectKey key: AMOuijaBoardView.Key)
}

final public class AMOuijaBoardView: UIView {
    
    public enum Key {
        case yes
        case no
        case goodbye
        case alphabet(String)
        case number(String)
    }
    
    public weak var delegate: AMOuijaBoardViewDelegate?
    public var font: UIFont = UIFont(name: "AcademyEngravedLetPlain", size: 15) ?? .systemFont(ofSize: 15)
    public var textColor: UIColor = .init(red: 45/255, green: 49/255, blue: 56/255, alpha: 1.0)
    public var markColor: UIColor = .init(red: 45/255, green: 49/255, blue: 56/255, alpha: 1.0)
    public var borderLineColor: UIColor = .init(red: 45/255, green: 49/255, blue: 56/255, alpha: 1.0)
    public var starCircleColor: UIColor = .init(red: 61/255, green: 117/255, blue: 93/255, alpha: 1.0)
    public var boardStartColor: UIColor = .init(red: 247/255, green: 230/255, blue: 185/255, alpha: 1.0)
    public var boardEndColor: UIColor = .init(red: 229/255, green: 196/255, blue: 141/255, alpha: 1.0)
    public var cursorColor: UIColor = .init(red: 196/255, green: 194/255, blue: 195/255, alpha: 1.0)
    
    private let boardView = UIView()
    private var boardLayer: CAShapeLayer?
    private var goodByeLayer: CATextLayer?
    private var yesLayer: CATextLayer?
    private var noLayer: CATextLayer?
    private var cursorLayer: CAShapeLayer?
    private var alphabetLayers = [CATextLayer]()
    private var numberLayers = [CATextLayer]()
    private var innerBorderFrame: CGRect = .zero
    
    private static let aspectRatio: CGFloat = 1.414
    private let firstBorderLineWidth: CGFloat = 1.0
    private let secondBorderMargin: CGFloat = 8
    private let secondBorderWidth: CGFloat = 8
    private let thirdBorderMargin: CGFloat = 4
    private let thirdBorderLineWidth: CGFloat = 1
    private let cornerMarkMargin: CGFloat = 2
    private let minBoardWidth: CGFloat = 300
    private let minBoardHeight: CGFloat = 300 / AMOuijaBoardView.aspectRatio
    private let maxBoardWidth: CGFloat = 600
    private let maxBoardHeight: CGFloat = 600 / AMOuijaBoardView.aspectRatio
    
    enum SizePattern {
        case s
        case m
        case l
        
        var margin: CGFloat {
            switch self {
            case .s:
                return 8
            case .m:
                return 16
            case .l:
                return 24
            }
        }
        
        var cornerMarkRadius: CGFloat {
            switch self {
            case .s:
                return 12
            case .m:
                return 16
            case .l:
                return 20
            }
        }
        
        var backTextFontSize: CGFloat {
            switch self {
            case .s:
                return 16
            case .m:
                return 18
            case .l:
                return 24
            }
        }
        
        var alphabetFontSize: CGFloat {
            switch self {
            case .s:
                return 16
            case .m:
                return 20
            case .l:
                return 24
            }
        }
        
        var numberFontSize: CGFloat {
            switch self {
            case .s:
                return 14
            case .m:
                return 16
            case .l:
                return 20
            }
        }
    }
    
    private var sizePattern: SizePattern {
        if boardView.frame.size.width < 390 {
            return .s
        }
        if boardView.frame.size.width < 480 {
            return .m
        }
        return .l
    }
    
    override public var bounds: CGRect {
        didSet {
            reloadBoard()
        }
    }
    
    override public func draw(_ rect: CGRect) {
        reloadBoard()
    }
    
    // MARK:- Initialize
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        initView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        initView()
    }
    
    private func initView() {
        boardView.frame = bounds
        boardView.layer.borderColor = borderLineColor.cgColor
        boardView.layer.borderWidth = firstBorderLineWidth
        addSubview(boardView)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(_:)))
        boardView.addGestureRecognizer(tap)
    }
    
    // MARK:- Tap Action
    @objc private func tapAction(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: boardView)
        if goodByeLayer?.frame.contains(point) == true {
            delegate?.ouijaBoardView(self, didSelectKey: .goodbye)
        }
        if yesLayer?.frame.contains(point) == true {
            cursorLayer?.position = revisePosition(yesLayer!.position)
            delegate?.ouijaBoardView(self, didSelectKey: .yes)
        }
        if noLayer?.frame.contains(point) == true {
            cursorLayer?.position = revisePosition(noLayer!.position)
            delegate?.ouijaBoardView(self, didSelectKey: .no)
        }
        alphabetLayers.forEach {
            if $0.frame.contains(point) {
                cursorLayer?.position = revisePosition($0.position)
                delegate?.ouijaBoardView(self, didSelectKey: .alphabet($0.string as! String))
            }
        }
        numberLayers.forEach {
            if $0.frame.contains(point) {
                cursorLayer?.position = revisePosition($0.position)
                delegate?.ouijaBoardView(self, didSelectKey: .number($0.string as! String))
            }
        }
    }
    
    private func revisePosition(_ point: CGPoint) -> CGPoint {
        return .init(x: point.x, y: point.y + 2)
    }
    
    // MARK:- Reload
    private func reloadBoard() {
        clearBoard()
        drawBoard()
    }
    
    private func drawBoard() {
        setBoardView()
        assertBoardSize(boardView.frame.size)
        boardLayer = makeBoardLayer()
        boardView.layer.addSublayer(boardLayer!)
        let cornerMarkRadius = sizePattern.cornerMarkRadius
        setBackLayers(cornerMarkRadius: cornerMarkRadius)
        setBackTextLayers(cornerMarkRadius: cornerMarkRadius)
        goodByeLayer = makeGoodByeLayer()
        boardLayer?.addSublayer(goodByeLayer!)
        var characterFrame = innerBorderFrame
        let margin = sizePattern.margin
        characterFrame.origin.x += cornerMarkRadius/2
        characterFrame.origin.y += cornerMarkRadius*2 + margin
        characterFrame.size.width -= cornerMarkRadius
        characterFrame.size.height -= (cornerMarkRadius*2 + margin)*2
        let fontSize: CGFloat = sizePattern.alphabetFontSize
        let numberFontSize: CGFloat = sizePattern.numberFontSize
        let largeRadius = 2 * (characterFrame.size.width/2 - fontSize)
        let topMargin = sizePattern.margin
        let center = CGPoint(x: characterFrame.midX, y: characterFrame.minY + largeRadius + fontSize/2 + topMargin)
        setTopAlphabetLayers(characterFrame: characterFrame, fontSize: fontSize,
                             center: center, largeRadius: largeRadius)
        setBottomAlphabetLayers(characterFrame: characterFrame, fontSize: fontSize,
                                center: center, largeRadius: largeRadius)
        setNumberLayers(characterFrame: characterFrame, fontSize: numberFontSize)
        cursorLayer = makeCursorLayer(radius: fontSize/2 + 2)
        cursorLayer?.position = revisePosition(alphabetLayers[6].position)
        boardLayer?.addSublayer(cursorLayer!)
    }
    
    private func clearBoard() {
        alphabetLayers.forEach { $0.removeFromSuperlayer() }
        alphabetLayers.removeAll()
        numberLayers.forEach { $0.removeFromSuperlayer() }
        numberLayers.removeAll()
        goodByeLayer?.removeFromSuperlayer()
        goodByeLayer = nil
        yesLayer?.removeFromSuperlayer()
        yesLayer = nil
        noLayer?.removeFromSuperlayer()
        noLayer = nil
        boardLayer?.sublayers?.forEach { $0.removeFromSuperlayer() }
        boardLayer?.removeFromSuperlayer()
        boardLayer = nil
        cursorLayer?.removeFromSuperlayer()
        cursorLayer = nil
    }
    
    // MARK:- Draw board
    private func setBoardView() {
        let ratio = frame.size.width / frame.size.height
        if ratio < AMOuijaBoardView.aspectRatio {
            let height = frame.size.width / AMOuijaBoardView.aspectRatio
            boardView.frame = .init(x: 0, y: frame.size.height/2 - height/2,
                                    width: frame.size.width, height: height)
        } else {
            let width = frame.size.height * AMOuijaBoardView.aspectRatio
            boardView.frame = .init(x: frame.size.width/2 - width/2, y: 0,
                                    width: width, height: frame.size.height)
        }
    }
    
    private func assertBoardSize(_ size: CGSize) {
        if size.width < minBoardWidth {
            print("AMOuijaBoard: min width is \(minBoardWidth)")
        }
        if size.width > maxBoardWidth {
            print("AMOuijaBoard: max width is \(maxBoardWidth)")
        }
        if size.height < minBoardHeight {
            print("AMOuijaBoard: min height is \(minBoardHeight)")
        }
        if size.height > maxBoardHeight {
            print("AMOuijaBoard: max height is \(maxBoardHeight)")
        }
    }
    
    private func setTopAlphabetLayers(characterFrame: CGRect, fontSize: CGFloat,
                                      center: CGPoint, largeRadius: CGFloat) {
        let alphabets = "ABCDEFGHIJKLM".map(String.init)
        let centerAngle = (CGFloat.pi + CGFloat.pi/2)
        let startAngle = centerAngle - (CGFloat.pi/6)
        let endAngle = centerAngle + (CGFloat.pi/6)
        let angleUnit = (centerAngle - startAngle)/CGFloat(6)
        var angle = startAngle
        alphabets.prefix(6).forEach {
            let textLayer = makeCharacterLayer($0, size: fontSize)
            textLayer.position = CGPoint(x: largeRadius * cos(angle) + center.x,
                                         y: largeRadius * sin(angle) + center.y)
            textLayer.transform = CATransform3DMakeRotation(angle+CGFloat.pi/2, 0.0, 0.0, 1.0)
            boardLayer?.addSublayer(textLayer)
            angle += angleUnit
            alphabetLayers.append(textLayer)
        }
        
        let textLayer = makeCharacterLayer("G", size: fontSize)
        textLayer.position = CGPoint(x: largeRadius * cos(centerAngle) + center.x,
                                     y: largeRadius * sin(centerAngle) + center.y)
        boardLayer?.addSublayer(textLayer)
        angle = endAngle
        alphabetLayers.append(textLayer)
        
        alphabets.suffix(6).reversed().forEach {
            let textLayer = makeCharacterLayer($0, size: fontSize)
            textLayer.position = CGPoint(x: largeRadius * cos(angle) + center.x,
                                         y: largeRadius * sin(angle) + center.y)
            textLayer.transform = CATransform3DMakeRotation(angle+CGFloat.pi/2, 0.0, 0.0, 1.0)
            boardLayer?.addSublayer(textLayer)
            angle -= angleUnit
            alphabetLayers.append(textLayer)
        }
    }
    
    private func setBottomAlphabetLayers(characterFrame: CGRect, fontSize: CGFloat,
                                         center: CGPoint, largeRadius: CGFloat) {
        let topSpace = sizePattern.margin
        let alphabets = "NOPQRSTUVWXYZ".map(String.init)
        let centerAngle = (CGFloat.pi + CGFloat.pi/2)
        let startAngle = centerAngle - ((CGFloat.pi/6) + ((CGFloat.pi*2)/60))
        let endAngle = centerAngle + ((CGFloat.pi/6) + ((CGFloat.pi*2)/60))
        let angleUnit = (centerAngle - startAngle)/CGFloat(6)
        var angle = startAngle
        let radius = largeRadius - fontSize - topSpace
        alphabets.prefix(6).forEach {
            let textLayer = makeCharacterLayer($0, size: fontSize)
            textLayer.position = CGPoint(x: radius * cos(angle) + center.x,
                                         y: radius * sin(angle) + center.y)
            textLayer.transform = CATransform3DMakeRotation(angle+CGFloat.pi/2, 0.0, 0.0, 1.0)
            boardLayer?.addSublayer(textLayer)
            angle += angleUnit
            alphabetLayers.append(textLayer)
        }
        
        let textLayer = makeCharacterLayer("T", size: fontSize)
        textLayer.position = CGPoint(x: radius * cos(centerAngle) + center.x,
                                     y: radius * sin(centerAngle) + center.y)
        boardLayer?.addSublayer(textLayer)
        angle = endAngle
        alphabetLayers.append(textLayer)
        
        alphabets.suffix(6).reversed().forEach {
            let textLayer = makeCharacterLayer($0, size: fontSize)
            textLayer.position = CGPoint(x: radius * cos(angle) + center.x,
                                         y: radius * sin(angle) + center.y)
            textLayer.transform = CATransform3DMakeRotation(angle+CGFloat.pi/2, 0.0, 0.0, 1.0)
            boardLayer?.addSublayer(textLayer)
            angle -= angleUnit
            alphabetLayers.append(textLayer)
        }
    }
    
    private func setNumberLayers(characterFrame: CGRect, fontSize: CGFloat) {
        let sideMargin: CGFloat = 8
        let bottomMargin = sizePattern.margin
        let numbers = "1234567890".map(String.init)
        let width = fontSize*CGFloat(numbers.count) + sideMargin*CGFloat(numbers.count-1)
        var x: CGFloat = characterFrame.midX - width/2 + fontSize/2
        numbers.forEach {
            let textLayer = makeCharacterLayer($0, size: fontSize)
            textLayer.position = .init(x: x, y: characterFrame.maxY - fontSize/2 - bottomMargin)
            boardLayer?.addSublayer(textLayer)
            x += fontSize + sideMargin
            numberLayers.append(textLayer)
        }
    }
    
    private func setBackTextLayers(cornerMarkRadius: CGFloat) {
        let topMargin = sizePattern.margin
        let subTextTopMargin: CGFloat = sizePattern == .s ? 4 : 8
        let subTextSideMargin: CGFloat = sizePattern == .s ? 4 : 8
        let titleLayer = makeBackTextLayer("OUIJA")
        boardLayer?.addSublayer(titleLayer)
        titleLayer.frame = CGRect(origin: .init(x: innerBorderFrame.maxX - innerBorderFrame.width/2 - titleLayer.frame.size.width/2,
                                                y: innerBorderFrame.minY + topMargin),
                                  size: titleLayer.frame.size)
        yesLayer = makeBackTextLayer("YES")
        yesLayer?.frame = CGRect(origin: .init(x: innerBorderFrame.minX + cornerMarkMargin + cornerMarkRadius*2 + subTextSideMargin,
                                              y: innerBorderFrame.minY + topMargin + subTextTopMargin),
                                size: yesLayer!.frame.size)
        boardLayer?.addSublayer(yesLayer!)
        noLayer = makeBackTextLayer("NO ")
        noLayer?.frame = CGRect(origin: .init(x: innerBorderFrame.maxX - noLayer!.frame.size.width - (cornerMarkMargin + cornerMarkRadius*2 + subTextSideMargin),
                                                     y: innerBorderFrame.minY + topMargin + subTextTopMargin),
                                       size: noLayer!.frame.size)
        boardLayer?.addSublayer(noLayer!)
    }
    
    private func setBackLayers(cornerMarkRadius: CGFloat) {
        let triangleLength: CGFloat = 8
        let borderLayer = makeBorderLayer(triangleLength: triangleLength)
        boardLayer?.addSublayer(borderLayer)
        setInnerBorderFrame(borderLayerFrame: borderLayer.frame)
        let sunLayer = makeSunLayer(radius: cornerMarkRadius)
        let moonLayer = makeMoonLayer(radius: cornerMarkRadius)
        let leftStarLayer = makeStarLayer(radius: cornerMarkRadius)
        let rightStarLayer = makeStarLayer(radius: cornerMarkRadius)
        boardLayer?.addSublayer(sunLayer)
        boardLayer?.addSublayer(moonLayer)
        boardLayer?.addSublayer(leftStarLayer)
        boardLayer?.addSublayer(rightStarLayer)
        sunLayer.position = .init(x: innerBorderFrame.minX + cornerMarkRadius + cornerMarkMargin,
                                  y: innerBorderFrame.minY + cornerMarkRadius + cornerMarkMargin)
        moonLayer.position = .init(x: innerBorderFrame.maxX - cornerMarkRadius - cornerMarkMargin,
                                   y: innerBorderFrame.minY + cornerMarkRadius + cornerMarkMargin)
        leftStarLayer.position = .init(x: innerBorderFrame.minX + cornerMarkRadius + cornerMarkMargin,
                                       y: innerBorderFrame.maxY - cornerMarkRadius - cornerMarkMargin)
        rightStarLayer.position = .init(x: innerBorderFrame.maxX - cornerMarkRadius - cornerMarkMargin,
                                        y: innerBorderFrame.maxY - cornerMarkRadius - cornerMarkMargin)
    }
    
    private func setInnerBorderFrame(borderLayerFrame: CGRect) {
        innerBorderFrame = borderLayerFrame
        innerBorderFrame.origin.x += secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2
        innerBorderFrame.origin.y += secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2
        innerBorderFrame.size.width -= (secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2)*2
        innerBorderFrame.size.height -= (secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2)*2
    }
    
    private func makeBoardLayer() -> CAShapeLayer {
        let boardLayer = CAShapeLayer()
        boardLayer.frame = boardView.bounds
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = boardLayer.bounds
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.colors = [boardStartColor.cgColor, boardEndColor.cgColor]
        boardLayer.addSublayer(gradientLayer)
        return boardLayer
    }
    
    private func makeBorderLayer(triangleLength: CGFloat) -> CAShapeLayer {
        let borderLayer = CAShapeLayer()
        borderLayer.frame = .init(x: firstBorderLineWidth + secondBorderMargin,
                                  y: firstBorderLineWidth + secondBorderMargin,
                                  width: boardView.bounds.size.width - secondBorderMargin*2 - firstBorderLineWidth*2,
                                  height: boardView.bounds.size.height - secondBorderMargin*2 - firstBorderLineWidth*2)
        borderLayer.borderWidth = secondBorderWidth
        borderLayer.borderColor = borderLineColor.cgColor
        let path = UIBezierPath()
        let vertex1 = CGPoint(x: secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2,
                              y: secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2)
        let vertex2 = CGPoint(x: borderLayer.bounds.size.width - (secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2),
                              y: secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2)
        let vertex3 = CGPoint(x: borderLayer.bounds.size.width - (secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2),
                              y: borderLayer.bounds.size.height - (secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2))
        let vertex4 = CGPoint(x: secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2,
                              y: borderLayer.bounds.size.height - (secondBorderWidth + thirdBorderMargin + thirdBorderLineWidth/2))
        path.move(to: .init(x: vertex1.x, y: vertex1.y + triangleLength))
        path.addLine(to: .init(x: vertex1.x + triangleLength, y: vertex1.y))
        path.addLine(to: .init(x: vertex2.x - triangleLength, y: vertex2.y))
        path.addLine(to: .init(x: vertex2.x, y: vertex2.y + triangleLength))
        path.addLine(to: .init(x: vertex3.x, y: vertex3.y - triangleLength))
        path.addLine(to: .init(x: vertex3.x - triangleLength, y: vertex3.y))
        path.addLine(to: .init(x: vertex4.x + triangleLength, y: vertex4.y))
        path.addLine(to: .init(x: vertex4.x, y: vertex4.y - triangleLength))
        path.close()
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = borderLineColor.cgColor
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = thirdBorderLineWidth
        return borderLayer
    }
    
    private func makeCursorLayer(radius: CGFloat) -> CAShapeLayer {
        let cursorLayer = CAShapeLayer()
        let lineWidth: CGFloat = 4.0
        let r = radius - (lineWidth / 2)
        cursorLayer.frame = CGRect(origin: .zero, size: CGSize(width: radius * 2, height: radius * 2))
        let ringLayer = CAShapeLayer()
        ringLayer.frame = CGRect(origin: .zero, size: CGSize(width: radius * 2, height: radius * 2))
        ringLayer.path = UIBezierPath(ovalIn: CGRect(x: lineWidth/2, y: lineWidth/2, width: r * 2, height: r * 2)).cgPath
        ringLayer.strokeColor = cursorColor.cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = lineWidth
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = CGRect(origin: .zero, size: CGSize(width: radius * 2, height: radius * 2))
        shadowLayer.frame.origin.y = 3
        shadowLayer.path = UIBezierPath(ovalIn: CGRect(x: lineWidth/2, y: lineWidth/2, width: r * 2, height: r * 2)).cgPath
        shadowLayer.strokeColor = UIColor.black.cgColor
        shadowLayer.fillColor = UIColor.clear.cgColor
        shadowLayer.opacity = 0.3
        shadowLayer.lineWidth = 3
        cursorLayer.addSublayer(shadowLayer)
        cursorLayer.addSublayer(ringLayer)
        return cursorLayer
    }
    
    private func makeSunLayer(radius: CGFloat) -> CAShapeLayer {
        let sunLayer = CAShapeLayer()
        sunLayer.frame = CGRect(origin: .zero, size: CGSize(width: radius*2, height: radius*2))
        sunLayer.cornerRadius = radius
        sunLayer.backgroundColor = markColor.cgColor
        return sunLayer
    }
    
    private func makeStarLayer(radius: CGFloat) -> CAShapeLayer {
        let starLayer = CAShapeLayer()
        starLayer.frame = CGRect(origin: .zero, size: CGSize(width: radius*2, height: radius*2))
        starLayer.cornerRadius = radius
        starLayer.backgroundColor = starCircleColor.cgColor
        let vertexes = starVertexes(radius: radius, center: .init(x: radius, y: radius))
        let path = UIBezierPath()
        path.move(to: vertexes.first!)
        vertexes[1..<vertexes.count].forEach { path.addLine(to: $0) }
        path.close()
        starLayer.fillColor = markColor.cgColor
        starLayer.path = path.cgPath
        return starLayer
    }
    
    private func starVertexes(radius: CGFloat, center: CGPoint) -> [CGPoint] {
        let vertexes = 10
        return (0...vertexes).map { offset in
            let r = (offset % 2 == 0) ? radius : 0.4 * radius
            let θ = CGFloat(offset)/CGFloat(vertexes) * (2 * CGFloat.pi) - CGFloat.pi/2
            return CGPoint(x: r * cos(θ) + center.x, y: r * sin(θ) + center.y)
        }
    }
    
    private func makeMoonLayer(radius: CGFloat) -> CAShapeLayer {
        let moonLayer = CAShapeLayer()
        moonLayer.frame = CGRect(origin: .zero, size: CGSize(width: radius*2, height: radius*2))
        let path = UIBezierPath()
        let center = CGPoint(x: radius, y: radius)
        let startAngle = CGFloat.pi + CGFloat.pi/2 - ((CGFloat.pi*2)/60)*2
        let endAngle = CGFloat.pi/2 + (CGFloat.pi*2)/60 + CGFloat.pi*2
        path.addArc(withCenter: center, radius: radius, startAngle: startAngle,
                    endAngle: endAngle, clockwise: true)
        let controlAngle = startAngle + (endAngle - startAngle)/2
        let start = CGPoint(x: radius * cos(startAngle) + center.x, y: radius * sin(startAngle) + center.y)
        path.addQuadCurve(to: start, controlPoint: CGPoint(x: radius * cos(controlAngle) + center.x,
                                                           y: radius * sin(controlAngle) + center.y))
        moonLayer.fillColor = markColor.cgColor
        moonLayer.path = path.cgPath
        
        let starRadius = radius/2
        let starLayer = CAShapeLayer()
        starLayer.frame = CGRect(origin: .zero, size: CGSize(width: starRadius*2, height: starRadius*2))
        let vertexes = starVertexes(radius: starRadius, center: .init(x: starRadius, y: starRadius))
        let starPath = UIBezierPath()
        starPath.move(to: vertexes.first!)
        vertexes[1..<vertexes.count].forEach { starPath.addLine(to: $0) }
        starPath.close()
        starLayer.fillColor = markColor.cgColor
        starLayer.path = starPath.cgPath
        moonLayer.addSublayer(starLayer)
        starLayer.position = .init(x: center.x - starRadius, y: center.y)
        return moonLayer
    }
    
    private func makeCharacterLayer(_ text: String, size: CGFloat) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(origin: .zero, size: CGSize(width: size, height: size))
        textLayer.alignmentMode = .center
        textLayer.string = text
        textLayer.font = font
        textLayer.fontSize = size
        textLayer.foregroundColor = textColor.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
    
    private func makeBackTextLayer(_ text: String) -> CATextLayer {
        let fontSize = sizePattern.backTextFontSize
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(origin: .zero, size: CGSize(width: fontSize*CGFloat(text.count), height: fontSize))
        textLayer.alignmentMode = .center
        textLayer.string = text
        textLayer.font = font
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = textColor.cgColor
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
    
    private func makeGoodByeLayer() -> CATextLayer {
        let bottomMargin = sizePattern.margin
        let goodByeLayer = makeBackTextLayer("GOOD BYE")
        let lineLayer = CALayer()
        let lineWidth: CGFloat = 1
        lineLayer.frame = .init(x: 0, y: goodByeLayer.frame.size.height - lineWidth,
                                width: goodByeLayer.frame.size.width, height: lineWidth)
        lineLayer.backgroundColor = textColor.cgColor
        goodByeLayer.addSublayer(lineLayer)
        goodByeLayer.frame = CGRect(origin: .init(x: innerBorderFrame.maxX - innerBorderFrame.width/2 - goodByeLayer.frame.size.width/2,
                      y: innerBorderFrame.maxY - bottomMargin - goodByeLayer.frame.size.height),
        size: goodByeLayer.frame.size)
        return goodByeLayer
    }
}
