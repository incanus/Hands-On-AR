import UIKit
import ARKit
import SceneKit
import SwiftSocket
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet private var sceneView: ARSCNView!

    private var server: UDPServer!
    private var hand: Hand?
    private var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        server = UDPServer(address: "10.0.1.4", port: 8080)
        setupServerHandling()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }

        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 6
        configuration.trackingImages = referenceImages
        sceneView.session.run(configuration)

        sceneView.scene.physicsWorld.contactDelegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let anchor = anchor as? ARImageAnchor {
            if (anchor.referenceImage.name?.starts(with: "hand"))! {
                let node = SCNNode()
                node.scale = SCNVector3(0.5, 0.5, 0.5)
                node.transform = SCNMatrix4Rotate(node.transform, -.pi / 2, 1, 0, 0)
                node.transform = SCNMatrix4Translate(node.transform, 0, -1, -1) // y/z swapped
                hand = Hand()
                node.addChildNode(hand!)
                hand!.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: hand!.childNode(withName: "palm", recursively: true)!.geometry!, options: [SCNPhysicsShape.Option.keepAsCompound: 0]))
                hand!.physicsBody!.isAffectedByGravity = false
                hand!.physicsBody!.categoryBitMask = 1
                hand!.physicsBody!.contactTestBitMask = 1
                let wrapper = SCNNode()
                wrapper.addChildNode(node)
                return wrapper
            } else {
                var geometry: SCNGeometry?
                switch anchor.referenceImage.name {
//                case "ball", "ball-qr":
//                    geometry = SCNSphere(radius: 2❞)
//                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "red_tile")
//                case "box", "box-qr":
//                    geometry = SCNBox(width: 4❞, height: 4❞, length: 4❞, chamferRadius: 0)
//                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "cyan_tile")
                case "cone", "cone-qr":
                    geometry = SCNCone(topRadius: 0.1❞, bottomRadius: 2❞, height: 4❞)
                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "green_tile")
                case "donut", "donut-qr":
                    geometry = SCNTorus(ringRadius: 2❞, pipeRadius: 1❞)
                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "brown_tile")
                case "pyramid", "pyramid-qr":
                    geometry = SCNPyramid(width: 4❞, height: 4❞, length: 4❞)
                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "yellow_tile")
                default:
                    return nil
                }
                if let validGeometry = geometry {
                    let node = SCNNode(geometry: validGeometry)
                    node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: validGeometry, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox]))
                    node.physicsBody!.isAffectedByGravity = false
                    node.physicsBody!.categoryBitMask = 1
                    node.physicsBody!.contactTestBitMask = 1
                    return node
                }
            }
        }
        return nil
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("BEGIN: \(contact)")
        if sceneView.debugOptions != [] {
            player = AVPlayer(playerItem: AVPlayerItem(url: Bundle.main.url(forResource: "on", withExtension: "wav")!))
            player?.play()
        }
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("END: \(contact)")
        if sceneView.debugOptions != [] {
            player = AVPlayer(playerItem: AVPlayerItem(url: Bundle.main.url(forResource: "off", withExtension: "wav")!))
            player?.play()
        }
   }
    
    private func setupServerHandling() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            repeat {
                let response = self.server.recv(100)
                if let data = response.0 {
                    let result = String(data: Data(data), encoding: .utf8)!

                    let values = result.split(separator: ",")

                    var fingers = [UInt]()
                    for v in 0...4 {
                        if (Int(values[v])! > 0) {
                            fingers.append(UInt(values[v])!)
                        } else {
                            fingers.append(0)
                        }
                    }

                    var axes = [UInt]()
                    for v in 5...7 {
                        axes.append(UInt(values[v])!)
                    }

                    let x = Float(values[8])!
                    let y = Float(values[9])!
                    let dropped = (values[10] == "1" ? true : false)

                    DispatchQueue.main.sync { [unowned self] in
                        self.hand?.setFingers(fingers)
                        self.hand?.setTilt(axes)
                        self.hand?.setPosition(x: x, y: y, dropped: dropped)
                    }
                }
            } while true
        }
    }

    @IBAction private func wiggleFingers() {
        hand?.wiggleFingers()
    }

    @IBAction private func waveHand() {
        hand?.wave()
    }

    @IBAction private func makeFist() {
        hand?.makeFist()
    }

    @IBAction private func togglePhysicsDebug() {
        if sceneView.debugOptions == [] {
            sceneView.debugOptions = [.showPhysicsShapes, .renderAsWireframe]
        } else {
            sceneView.debugOptions = []
        }
    }

}
