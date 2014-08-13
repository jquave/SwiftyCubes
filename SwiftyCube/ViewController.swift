//
//  ViewController.swift
//  SwiftyCube
//
//  Created by Jameson Quave on 8/13/14.
//  Copyright (c) 2014 JQ Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /// How many cubes?
    let numCubes = 50.0
    
    // Show cubes? (Shows text labels if false)
    let showCubes = true
    
    // Tag for cube views
    let CUBE_TAG = 100
    
    var animator : UIDynamicAnimator?
    var gravity : UIGravityBehavior?
    var collisionBehavior : UICollisionBehavior?
    var physicsObjects = [UIView]()
    
    var activeSnapper : UISnapBehavior?
    
    let colorPattern = UIColor(patternImage: UIImage(named: "checkered"))
    
    var selectedView : UIView? = nil
    
    /// This is called when the view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var screenWidth = CGFloat(UIScreen.mainScreen().bounds.size.width)
        var cubeSize = CGFloat(screenWidth) / CGFloat(sqrt(Float(numCubes)))
        
        let spacing = CGFloat(2.0)
        
        for (var x : CGFloat = spacing; x<screenWidth; x+=cubeSize + spacing) {
            for (var y : CGFloat = spacing; y<screenWidth; y+=cubeSize + spacing) {
                addCube(x, y: y, size: cubeSize)
            }
        }
        
        animator = UIDynamicAnimator(referenceView: self.view)
        
        gravity = UIGravityBehavior()
        
        
        
        collisionBehavior = UICollisionBehavior(items: physicsObjects)
        collisionBehavior?.translatesReferenceBoundsIntoBoundary = true
        
        for physicsObject in self.physicsObjects {
            gravity?.addItem(physicsObject)
        }
        
        animator!.addBehavior(gravity)
        animator!.addBehavior(collisionBehavior)
        
    }
    
    
    
    func addCube(x : CGFloat, y: CGFloat, size cubeSize : CGFloat) {
        
        if(showCubes) {
            var cube = UIView()
            cube.layer.borderColor = UIColor.blueColor().CGColor
            cube.layer.borderWidth = 1
            cube.layer.cornerRadius = cubeSize/4.0
            cube.frame = CGRectMake(x, y, cubeSize, cubeSize)
            cube.backgroundColor = colorPattern
            cube.tag = CUBE_TAG
            
            
            self.view.addSubview(cube)
            
            physicsObjects.append(cube)
        }
        else {
        
            var txtLabel = UILabel(frame: CGRectMake(x, y, cubeSize, cubeSize))
            txtLabel.text = "Hello!"
            txtLabel.userInteractionEnabled = true
            txtLabel.tag = CUBE_TAG
            txtLabel.layer.borderColor = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1).CGColor
            txtLabel.layer.borderWidth = 1
            txtLabel.textColor = UIColor.blueColor()
            txtLabel.layer.cornerRadius = cubeSize/4.0
            
            self.view.addSubview(txtLabel)
            
            physicsObjects.append(txtLabel)
        }
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        if let tappedView = touches.anyObject().view {
            if(tappedView.tag == CUBE_TAG) {
                selectedView = tappedView
            }
        }
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        //selectedView?.center = touches.anyObject().locationInView(self.view)
        if(activeSnapper != nil) {
            animator?.removeBehavior(activeSnapper)
        }
        if(selectedView != nil) {
            activeSnapper = UISnapBehavior(item: selectedView, snapToPoint: touches.anyObject().locationInView(self.view))
            activeSnapper?.damping = 2
            animator?.addBehavior(activeSnapper)
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        selectedView = nil
        if(activeSnapper != nil) {
            animator?.removeBehavior(activeSnapper)
        }
    }

    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        selectedView = nil
        if(activeSnapper != nil) {
            animator?.removeBehavior(activeSnapper)
        }
    }


}

