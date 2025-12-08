//
//  PhotoEditor+Drawing.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/16/17.
//
//
import UIKit

extension PhotoEditorViewController {

    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            circularLayer.isHidden = true
            hideDrawingControls(hide: true)
            swiped = false
            if let touch = touches.first {
                lines.append(Line(color: drawColor, points: [], width: lineWidth))
                lastPoint = touch.location(in: self.canvasImageView)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.sliderView.alpha = 0
            }) { (finished) in
                self.sliderView.isHidden = true
            }
        }
            //Hide stickersVC if clicked outside it
        else if stickersVCIsVisible == true {
            if let touch = touches.first {
                let location = touch.location(in: self.view)
                if !stickersViewController.view.frame.contains(location) {
                    removeStickersView()
                }
            }
        }

    }

    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: canvasImageView)
                guard var lastLine = lines.popLast() else { return }
                lastLine.points.append(currentPoint)
                lines.append(lastLine)
                drawLineFrom(lastPoint, toPoint: currentPoint)
                lastPoint = currentPoint
            }
        }
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDrawing {
            hideDrawingControls(hide: false)
            UIView.animate(withDuration: 0.3, animations: {
                self.sliderView.alpha = 1.0
            }) { (finished) in
                self.sliderView.isHidden = false
            }
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            hideDrawingControls(hide: false)
            if !swiped {
                if let touch = touches.first {
                    let currentPoint = touch.location(in: canvasImageView)
                    guard var lastLine = lines.popLast() else { return }
                    lastLine.points.append(currentPoint)
                    lines.append(lastLine)
                    drawLineFrom(lastPoint, toPoint: lastPoint)
                }
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.sliderView.alpha = 1.0
            }) { (finished) in
                self.sliderView.isHidden = false
            }
        }

    }

    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
        let canvasSize = canvasImageView.frame.integral.size
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
            // 2
            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            // 3
            context.setLineCap( CGLineCap.round)
            context.setLineJoin(.round)
            context.setLineWidth(lineWidth)
            context.setStrokeColor(drawColor.cgColor)
            context.setBlendMode( CGBlendMode.normal)
            // 4
            context.strokePath()
            // 5
            canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }

    func redrawLineFrom() {
        let canvasSize = canvasImageView.frame.integral.size
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))

            lines.forEach { (line) in
                context.setStrokeColor(line.color.cgColor)
                context.setLineWidth(line.width)
                context.setLineJoin(.round)
                context.setLineCap(.round)
                for(i, p) in line.points.enumerated() {
                    if i == 0 {
                        context.move(to: p)
                    } else {
                        context.addLine(to: p)
                    }
                }
                context.strokePath()
            }

            context.setBlendMode( CGBlendMode.normal)
            canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
    }

}
