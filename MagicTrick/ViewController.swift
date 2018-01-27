//
//  ViewController.swift
//  MagicTrick
//
//  Created by JAY PATEL on 1/7/18.
//  Copyright © 2018 Jay. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var note: UILabel!
    
    // MARK: Properties
    var floorNode: SCNNode?
    var hatNode: SCNNode?
    var ballNode: SCNNode?
    var omniLight: SCNLight?
    
    // Clone of `hatNode` present in the scene at any given moment
    var hatInScene: SCNNode?
    
    // set this value to true when hat is added to the sceneView's rootnode
    var isHatPlaced: Bool = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                let isHatPlaced = self?.isHatPlaced ?? false
                self?.note?.text = isHatPlaced ? "Tap on Screen or `Throw Ball`" : "Please scan a horizontal surface for hat"
                self?.sceneView?.debugOptions = isHatPlaced ? [] : [ARSCNDebugOptions.showFeaturePoints]
            }
        }
    }
    
    // new balls added to the sceneView rootnode
    var balls = [SCNNode]()
    
    var configuration: ARConfiguration?
    
    // force to be applied when we throw a ball
    let force = SCNVector4(0, 0, -2, 0)
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        isHatPlaced = false
        note.layer.cornerRadius = 4.0
        note.clipsToBounds = true
        
        // scene
        setupSceneView()
        
        // floor, hat, light, and ball
        loadAllNodes()
        
        // session configuration
        loadTracking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseTracking()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        makeAndThrowBall()
    }
    
    // MARK: Scene view
    func setupSceneView() {
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create new scene
        sceneView.scene = SCNScene()
        
        // Yellow points for UX
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func loadAllNodes() {
        guard let magic = SCNScene(named: "art.scnassets/magic.scn") else { return }
        if let floor = magic.rootNode.childNode(withName: "floor", recursively: true) {
            floorNode = floor
        }
        if let hat = magic.rootNode.childNode(withName: "hat", recursively: true) {
            hatNode = hat
        }
        if let light = magic.rootNode.childNode(withName: "omni", recursively: true)?.light {
            omniLight = light
        }
        if let ball = magic.rootNode.childNode(withName: "ball", recursively: true) {
            ballNode = ball
        }
        balls.removeAll()
    }
    
    func loadTracking() {
        // setup configuration based on available sensors
        if ARWorldTrackingConfiguration.isSupported {
            configuration = ARWorldTrackingConfiguration()
            (configuration as? ARWorldTrackingConfiguration)?.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        } else {
            configuration = AROrientationTrackingConfiguration()
        }
    }
    
    func startTracking() {
        // run session with the configuration object
        guard let configuration = configuration else { return }
        sceneView.session.run(configuration, options: [ARSession.RunOptions.removeExistingAnchors, ARSession.RunOptions.resetTracking])
    }
    
    func pauseTracking() {
        sceneView.session.pause()
    }
    
    // MARK: Actions
    @IBAction func throwBallTapped(_ sender: UIButton) {
        makeAndThrowBall()
    }
    
    @IBAction func magicButtonTapped(_ sender: Any) {
        // Check if we have a hat
        guard let hatInScene = hatInScene else { return }
        
        removeBallsInside(node: hatInScene)
    }
}

// MARK: -
extension ViewController: ARSKViewDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    /*Implement this to provide a custom node for the given anchor.
     
     @discussion This node will automatically be added to the scene graph.
     If this method is not implemented, a node will be automatically created.
     If nil is returned the anchor will be ignored.
     @param renderer The renderer that will render the scene.
     @param anchor The added anchor.
     @return Node that will be mapped to the anchor or nil.
     */
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // check if a hat already exists and anchor is a plane anchor
        guard isHatPlaced == false, anchor is ARPlaneAnchor else { return nil }
        
        // create an empty node for this plane anchor
        return SCNNode()
    }
    
    // Called when a new node has been mapped to the given anchor
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // check if hat already exists in the sceneview
        // make sure we have a plane anchor and a new hatNode
        guard isHatPlaced == false, let planeAnchor = anchor as? ARPlaneAnchor, let hat = hatNode?.clone(), let floor = floorNode?.clone() else {
            print("Could not add hat")
            return
        }
        
        // Move and add hat to this new plane anchor
        // align x and z center but set y to zero to keep it on the ground (plane)
        let newPosition = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        hat.position = newPosition
        floor.position = newPosition
        
        node.addChildNode(hat)
        node.addChildNode(floor)
        
        // store this hat for magic trick
        hatInScene = hat
        isHatPlaced = true
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let lightEstimate = sceneView.session.currentFrame?.lightEstimate {
            omniLight?.intensity = lightEstimate.ambientIntensity
            omniLight?.temperature = lightEstimate.ambientColorTemperature
        }
    }
}

// MARK: -
extension ViewController {
    
    // MARK: - Ball
    func makeAndThrowBall() {
        // make sure we have a hat before throwing the ball
        guard isHatPlaced else { return }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.note.isHidden = true
        }
        
        // Instantiate a ball, put it in front of camera and throw it forward
        if let ballNode = ballNode?.clone(), let camera = sceneView.session.currentFrame?.camera {
            ballNode.applyTransformation(from: camera)
            
            // add new ball to scene view
            sceneView.scene.rootNode.addChildNode(ballNode)
            
            // throw the ball perpendicular from camera (-z direction)
            ballNode.applyForce(force, from: camera)
            
            // Store 'ballNode' for removal purpose
            balls.append(ballNode)
        }
    }
    
    func removeBallsInside(node: SCNNode) {
        // hide balls which are inside 'node'
        balls.forEach { $0.isHidden = $0.isInside(node: node) }
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.note.isHidden = false
        }
    }
}
