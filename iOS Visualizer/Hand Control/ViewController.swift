import UIKit
import SceneKit
import SwiftSocket

class ViewController: UIViewController {

    @IBOutlet var sceneView: SCNView!

    var lastFingerRotationX: [CGFloat] = [0, 0, 0, 0, 0]

    func startServer() {
        let server = UDPServer(address: "192.168.1.7", port: 8080)
        DispatchQueue.global(qos: .background).async { [unowned self] in
            repeat {
                let response = server.recv(100)
                let result = String(data: Data(response.0!), encoding: .utf8)!
                let values = result.split(separator: ",")
                var outputs = [UInt]()
                for v in values {
                    outputs.append(UInt(v)!)
                }
                DispatchQueue.main.sync { [unowned self] in
                    self.setFingers(values: outputs)
                }
            } while true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        startServer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.backgroundColor = UIColor.black
        sceneView.allowsCameraControl = true

        let scene = SCNScene()
        sceneView.scene = scene

        let handNode = SCNNode()
        handNode.name = "hand"
        scene.rootNode.addChildNode(handNode)

        let colorMaterial = SCNMaterial()
        colorMaterial.diffuse.contents = UIColor.blue
        let darkMaterial = SCNMaterial()
        darkMaterial.diffuse.contents = UIColor.darkGray

        let palm = SCNTube(innerRadius: 0.35, outerRadius: 0.5, height: 0.1)
        palm.materials = [darkMaterial, darkMaterial, colorMaterial, colorMaterial]

        let palmNode = SCNNode(geometry: palm)
        palmNode.name = "palm"
        palmNode.position = SCNVector3(0, 0, 0)
        palmNode.transform = SCNMatrix4MakeRotation(.pi / 2, 1, 0, 0)
        palmNode.opacity = 0.5
        handNode.addChildNode(palmNode)

        let ls: [CGFloat] = [0.6, 0.75, 0.65, 0.5]
        let rs: [Float] = [.pi / 6, .pi / 11, -.pi / 11, -.pi / 6, .pi / 3]
        let xs: [Float] = [-0.35, -0.1, 0.1, 0.35, -0.35]
        let ys: [Float] = [0.35, 0.5, 0.5, 0.35, 0]

        for f in 1...4 {
            let finger = SCNCylinder(radius: 0.1, height: ls[f - 1])
            finger.materials = [colorMaterial, darkMaterial, darkMaterial]

            let fingerNode = SCNNode(geometry: finger)
            fingerNode.name = "finger.\(f)"
            fingerNode.position = SCNVector3(0, 0, 0)
            fingerNode.pivot = SCNMatrix4MakeTranslation(0, -0.5, 0)
            fingerNode.transform = SCNMatrix4MakeRotation(rs[f - 1], 0, 0, 1)
            fingerNode.transform = SCNMatrix4Translate(fingerNode.transform, xs[f - 1], ys[f - 1], 0)
            fingerNode.opacity = 0.5
            handNode.addChildNode(fingerNode)
        }

        let thumb = SCNCylinder(radius: 0.1, height: 0.4)
        thumb.materials = [colorMaterial, darkMaterial, darkMaterial]

        let thumbNode = SCNNode(geometry: thumb)
        thumbNode.name = "finger.0"
        thumbNode.position = SCNVector3(0, 0, 0)
        thumbNode.pivot = SCNMatrix4MakeTranslation(0, -0.5, 0)
        thumbNode.transform = SCNMatrix4MakeRotation(rs[4], 0, 0, 1)
        thumbNode.transform = SCNMatrix4Translate(thumbNode.transform, xs[4], ys[4], 0)
        thumbNode.opacity = 0.5
        handNode.addChildNode(thumbNode)
    }

    @IBAction func wiggleFingers() {
        for f in 0...4 {
            if let finger = sceneView.scene?.rootNode.childNode(withName: "finger.\(f)", recursively: true) {
                let bend = SCNAction.rotateBy(x: -.pi / 3, y: 0, z: 0, duration: 0.25)
                let wait = SCNAction.wait(duration: TimeInterval(f) * 0.25)
                let sequence = SCNAction.sequence([wait, bend, bend.reversed()])
                sequence.timingMode = .easeInEaseOut
                finger.runAction(sequence)
            }
        }
    }

    @IBAction func waveHand() {
        if let hand = sceneView.scene?.rootNode.childNode(withName: "hand", recursively: true) {
            let moveLeft = SCNAction.moveBy(x: -0.25, y: 0, z: 0, duration: 0.1)
            let moveRight = SCNAction.moveBy(x: 0.25, y: 0, z: 0, duration: 0.1)
            let rotateLeft = SCNAction.rotateBy(x: 0, y: 0, z: .pi / 10, duration: 0.1)
            let rotateRight = SCNAction.rotateBy(x: 0, y: 0, z: -.pi / 10, duration: 0.1)
            let left = SCNAction.group([moveLeft, rotateLeft])
            let right = SCNAction.group([moveRight, rotateRight])
            let reset = SCNAction.group([SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.1),
                                         SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.1)])
            let wave = SCNAction.sequence([left, reset, right, reset])
            hand.runAction(SCNAction.repeat(wave, count: 3))
        }
    }

    @IBAction func makeFist() {
        for f in 0...4 {
            if let finger = sceneView.scene?.rootNode.childNode(withName: "finger.\(f)", recursively: true) {
                let fist = SCNAction.rotateBy(x: -.pi * 0.6, y: 0, z: 0, duration: 0.25)
                let wait = SCNAction.wait(duration: 1)
                let sequence = SCNAction.sequence([fist, wait, fist.reversed()])
                sequence.timingMode = .easeInEaseOut
                finger.runAction(sequence)
            }
        }
    }

    func setFingers(values: [UInt]) {
        for f in 0...4 {
            if let finger = sceneView.scene?.rootNode.childNode(withName: "finger.\(f)", recursively: true) {
                if lastFingerRotationX[f] != 0 {
                    finger.runAction(SCNAction.rotateBy(x: CGFloat(-lastFingerRotationX[f]), y: 0, z: 0, duration: 0))
                }
                let factor = CGFloat(Float(values[f]) / 10 * -.pi * 0.6)
                finger.runAction(SCNAction.rotateBy(x: factor, y: 0, z: 0, duration: 0))
                lastFingerRotationX[f] = factor
            }
        }
    }

}
