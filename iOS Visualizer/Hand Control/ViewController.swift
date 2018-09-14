import UIKit
import ARKit
import SceneKit
import SwiftSocket

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet private var sceneView: ARSCNView!

    private var server: UDPServer!
    private var hand: Hand?

    override func viewDidLoad() {
        super.viewDidLoad()

        server = UDPServer(address: "192.168.1.7", port: 8080)
        setupServerHandling()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }

        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        sceneView.session.run(configuration)
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
                let wrapper = SCNNode()
                wrapper.addChildNode(node)
                return wrapper
            } else {
                var geometry: SCNGeometry?
                switch anchor.referenceImage.name {
                case "ball", "ball-qr":
                    geometry = SCNSphere(radius: 2❞)
                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "red_tile")
                case "box", "box-qr":
                    geometry = SCNBox(width: 4❞, height: 4❞, length: 4❞, chamferRadius: 0)
                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "cyan_tile")
                case "cone", "cone-qr":
                    geometry = SCNCone(topRadius: 0.1❞, bottomRadius: 2❞, height: 4❞)
                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "green_tile")
                case "donut", "donut-qr":
                    geometry = SCNTorus(ringRadius: 2❞, pipeRadius: 1❞)
                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "yellow_tile")
                case "pyramid", "pyramid-qr":
                    geometry = SCNPyramid(width: 4❞, height: 4❞, length: 4❞)
                    geometry?.firstMaterial?.diffuse.contents = UIImage(named: "brown_tile")
                default:
                    return nil
                }
                if let validGeometry = geometry {
                    let node = SCNNode(geometry: validGeometry)
                    return node
                }
            }
        }
        return nil
    }

    private func setupServerHandling() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            repeat {
                let response = self.server.recv(100)
                let result = String(data: Data(response.0!), encoding: .utf8)!
                let sections = result.split(separator: ":")

                if sections[0] == "a" {
                    let values = sections[1].split(separator: ",")

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

                    DispatchQueue.main.sync { [unowned self] in
                        self.hand?.setFingers(fingers)
                        self.hand?.setTilt(axes)
                    }
                } else if sections[0] == "b" {
                    let values = sections[1].split(separator: ",")

                    let x = Float(values[0])!
                    let y = Float(values[1])!
                    let dropped = (values[2] == "1" ? true : false)

                    DispatchQueue.main.sync { [unowned self] in
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

    private func setFingers(_ values: [UInt]) {
        hand?.setFingers(values)
    }

    private func setTilt(_ values: [UInt]) {
        hand?.setTilt(values)
    }

}
