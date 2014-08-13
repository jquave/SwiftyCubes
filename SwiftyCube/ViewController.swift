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
    
    
    /// Creates a cube object and adds it to the view, as well as the physicsObjects array.
    func addCube(x : CGFloat, y: CGFloat, size cubeSize : CGFloat) {
        
        if(showCubes) {
            // Instantiate a new UIView
            var cube = UIView()
            
            // Set some properties of it's border (blue, 1 point wide, with a 25% corner radius.)
            // We have to do this on the UIView's backing layer, since it's just not available in UIView
            cube.layer.borderColor = UIColor.blueColor().CGColor
            cube.layer.borderWidth = 1
            cube.layer.cornerRadius = cubeSize/4.0
            
            // Set the x and y position, as well as the size of the view by setting the frame
            cube.frame = CGRectMake(x, y, cubeSize, cubeSize)
            
            // Set the background color to be colorPattern, which is define above as a UIColor containing a tiled image
            cube.backgroundColor = colorPattern
            
            // Set the tag of this view to the constant CUBE_TAG, so we can identify it later as a physics cube
            cube.tag = CUBE_TAG
            
            
            // Add the cube to the main view
            self.view.addSubview(cube)
            
            
            // Add the cube to the list of physicsObjects (a property of ViewController)
            physicsObjects.append(cube)
        }
        else {
        
            // This does nearly all the same things as above, but for a UILabel
            // This is only visible if showCubes is set to false.
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
    
    
    
    // ************************************
    // MARK: Touch callback methods
    // ************************************
    
    /// iOS calls this when the user places a finger (our clicks the mouse) on the screen
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        
        // See if we can get the view that was clicked by accessing the view property in touches.anyObject()
        if let tappedView = touches.anyObject().view {
            
            // If a view was found, check and see if it's tag is CUBE_TAG
            // Remember earlier? We set the tag of all views to CUBE_TAG?
            // That was so we can check it here.
            if(tappedView.tag == CUBE_TAG) {
                // Okay, this is a legit cube, store this view as the "selectedView" property
                selectedView = tappedView
            }
        }
    }
    
    /// iOS calls this when the user has already had a finger on the screen, and now they're moving it around
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        
        // activeSnapper is a property we created for the Snap behavior we want when the user drags around a cube
        // Since the user is now moving around their finger, we remove any existing snap behavior and create a fresh one
        if(activeSnapper != nil) {
            animator?.removeBehavior(activeSnapper)
        }
        
        // Since the user is dragging around their finger, we want to act upon the selectedView.
        // But, it might be nil since they could just be dragging around the background.
        // Imagine a user trying to grab a cube, but they have terrible aim.
        if(selectedView != nil) {
            // Create a new Snap behavior for the selectedView, and set the point to be whatever the location
            // of the user's touch is, inside of the main view (the whole screen in this case)
            activeSnapper = UISnapBehavior(item: selectedView, snapToPoint: touches.anyObject().locationInView(self.view))
            
            // Upping the damping makes the snap behavior more elastic and loose. It's a personal preference.
            activeSnapper?.damping = 2
            
            // Now add the behavior to our animator so it kicks in.
            animator?.addBehavior(activeSnapper)
        }
    }
    
    /// iOS calls this when the user slides their finger clear off the screen
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        selectedView = nil
        if(activeSnapper != nil) {
            animator?.removeBehavior(activeSnapper)
        }
    }

    
    /// iOS calls this when the user lifts their finger off the screen
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        selectedView = nil
        if(activeSnapper != nil) {
            animator?.removeBehavior(activeSnapper)
        }
    }

    

}








































