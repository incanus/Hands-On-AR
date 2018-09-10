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

        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImages
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        node.scale = SCNVector3(0.2, 0.2, 0.2)
        node.transform = SCNMatrix4Rotate(node.transform, -.pi / 2, 1, 0, 0)
        node.transform = SCNMatrix4Translate(node.transform, 0, 0, -0.25)
        hand = Hand()
        node.addChildNode(hand!)
        let wrapper = SCNNode()
        wrapper.addChildNode(node)
        return wrapper
    }

    private func setupServerHandling() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            repeat {
                let response = self.server.recv(100)
                let result = String(data: Data(response.0!), encoding: .utf8)!
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

                DispatchQueue.main.sync { [unowned self] in
                    self.hand?.setFingers(fingers)
                    self.hand?.setTilt(axes)
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
