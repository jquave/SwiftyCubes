//
//  ViewController.swift
//  SwiftyCube
//
//  Created by Jameson Quave on 8/13/14.
//  Copyright (c) 2014 JQ Software. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    
    /// How many cubes?
    let numCubes: Float = 50.0
    
    // An animator is used to store various UIDynamics behavior (gravity, for example)
    var animator = UIDynamicAnimator()
    
    // The gravity behavior, makes stuf fall
    var gravity = UIGravityBehavior()
    
    // The collision behavior makes things collide with each other.
    // Without this they just sort of pass through each other.
    var collisionBehavior = UICollisionBehavior()
    
    /// The "texture" on our cubes.
    let colorPattern = UIColor(patternImage: UIImage(named: "checkered")!)
    
    /// For each cube that is being dragged, we have a snapper. There can be multiple snappers because multitouch!
    var snappers = [UIView: UISnapBehavior]()
    
    // The color of the background in the very beginning
    var bgColor = UIColor(hue: 1, saturation: 0.5, brightness: 0.9, alpha: 1.0)
    // This is used to measure the time, which is used to select a color for the background
    var frameTime = 0.0
    
    /// This is called when the view loads. Why? Because iOS just does that in View Controllers.
    override func viewDidLoad() {
        
        // Create a timer that fires every 60th of a second to call the function changeColor(), its declared below...
        NSTimer.scheduledTimerWithTimeInterval(1.0/60.0, target: self, selector: "changeColor", userInfo: nil, repeats: true)
        
        // Get the width of the iPhone screen. UIScreen.mainScreen() pretty much always gives you the only screen.
        // Occasionally (like if on AirPlay) there are two screens, but it's not an issue here.
        // We use the bounds to get the width of the screen and set the size of our cubes to be
        // whatever that is divided by the square root of the number of cubes. This gives us a
        // size of cube we know we can fit numCubes of on to the screen.
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let cubeSize = screenWidth / CGFloat(sqrt(numCubes))
        
        // Just a few pixels of spacing to go between the cubes
        let spacing: CGFloat = 2.0
        
        // Will hold all of our cubes.
        var cubes = [UIView]()
        
        // Nested loop, goes through and creates a bunch of cubes by stepping through, adding
        // the appropriate spacing and widths as needed.
        for (var x = spacing; x<screenWidth; x+=cubeSize + spacing) {
            for (var y = spacing; y<screenWidth; y+=cubeSize + spacing) {
                // Calls our addCube method above with our x and y locations, and the cubeSize we figured out earlier.
                cubes.append(createCube(x, y: y, size: cubeSize))
            }
        }
        
        // Add the cubes to the main view
        for cube in cubes {
            self.view.addSubview(cube)
        }
        
        // An animator is needed for any of this to work
        animator = UIDynamicAnimator(referenceView: self.view)
        
        // Create an empty gravity behavior, we need this for the cubes to fall
        gravity = UIGravityBehavior()
        
        // Create a collision behavior with all of our cubes
        collisionBehavior = UICollisionBehavior(items: cubes)
        
        // Set the references bounds in to boundaries.
        // Basically this means just take the area that the cube takes up as a View, and turn that in to
        // collision boundaries. This includes the screen edges.
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        
        
        // Add all cubes to the gravity behavior.
        for cube in cubes {
            gravity.addItem(cube)
        }
        
        // Finally, add the gravity and collision behaviors on to the animator. iOS takes over from here.
        animator.addBehavior(gravity)
        animator.addBehavior(collisionBehavior)
        
        // Call the superclass method for viewDidLoad()
        super.viewDidLoad()
    }
    
    
    /// Update the color of the background by shifting the hue
    func changeColor() {
        // How much time has passed since the last frame?
        var dt = CACurrentMediaTime() - frameTime
        
        var hue = CGFloat(0.0)
        var saturation = CGFloat(0.0)
        var brightness = CGFloat(0.0)
        var alpha = CGFloat(0.0)
        if(bgColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)) {
            hue -= CGFloat(dt*0.1)
            bgColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
            self.view.backgroundColor = bgColor
        }
        frameTime = CACurrentMediaTime()
    }
    
    // This method is called whenever one of the gesture recognizers created in the addCube method detects a drag gesture.
    func onDrag(recognizer: UIPanGestureRecognizer) {
        // The recognizer's view is the view we added the gesture recognizer to - that is the cube view!
        if let cubeView = recognizer.view {
         
            // The snappers dictionary contains the snap behaviours for each cube that is being dragged around.
            // Since a drag gesture was performed, we want to remove the snap behaviour for that cube. We create a new one later.
            if let snapper = snappers[cubeView] {
                animator.removeBehavior(snapper)
                snappers[cubeView] = nil
            }
            
            // In case the gesture changed (it might also just have started, stopped, or been cancelled), we create a new UISnapBehavior.
            if recognizer.state == .Changed {
                let snapper = UISnapBehavior(
                    item: cubeView,
                    // We can get the point of the finger by asking the gesture recognizer for it's position in the view.
                    snapToPoint: recognizer.locationInView(self.view)
                )
                
                // Save the snapping behaviour in the dictionary so we can remove it when the finger moves next time.
                snappers[cubeView] = snapper
                    
                // Upping the damping makes the snap behavior more elastic and loose. It's a personal preference.
                snapper.damping = 3
                
                // Now add the behavior to our animator so it kicks in.
                animator.addBehavior(snapper)
            }
        }
    }
    
    /// Creates a cube object.
    func createCube(x : CGFloat, y: CGFloat, size cubeSize : CGFloat) -> UIView {
        
        // Instantiate a new UIView
        var cube = UIView()
        
        // Set some properties of it's border (blue, 1 point wide, with a 25% corner radius.)
        // We have to do this on the UIView's backing layer, since it's just not available in UIView
        cube.layer.borderColor = UIColor(red: 0.0, green: 0.1, blue: 0.6, alpha: 1).CGColor
        cube.layer.borderWidth = 1
        cube.layer.cornerRadius = cubeSize/4.0
        
        // Set the x and y position, as well as the size of the view by setting the frame
        cube.frame = CGRectMake(x, y, cubeSize, cubeSize)
        
        // Set the background color to be colorPattern, which is define above as a UIColor containing a tiled image
        cube.backgroundColor = colorPattern
        
        // We add a pan-gesture recognizer to drag a cube, for each cube separately.
        // "Pan"ning is basically equivalent to dragging in our case.
        // The gesture recognizer will call our onDrag: method whenever the finger moves.
        cube.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onDrag:"))
        
        
        // Turn on anti-aliasing
        // - OR -
        // Make jaggedy edges more smoothy
        cube.layer.allowsEdgeAntialiasing = true

        return cube
        
    }
}
