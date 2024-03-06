import SwiftUI
import ARKit
import SceneKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var isRecording: Bool
    @Binding var selectedMustache: String
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        let currentMustacheNode = uiView.scene.rootNode.childNode(withName: "Mustache", recursively: true)
        if currentMustacheNode == nil || currentMustacheNode?.name != selectedMustache {
            currentMustacheNode?.removeFromParentNode()
            addMustacheNode(to: uiView)
        }
    }

    func addMustacheNode(to uiView: ARSCNView) {
        if let mustacheURL = Bundle.main.url(forResource: selectedMustache, withExtension: "scn") {
            print("Mustache URL: \(mustacheURL)")
            do {
                let mustacheScene = try SCNScene(url: mustacheURL, options: nil)
                if let mustacheNode = mustacheScene.rootNode.childNode(withName: "Mustache", recursively: true)?.clone() {
                    mustacheNode.name = "Mustache"
                    mustacheNode.position = SCNVector3(x: 0, y: -0.02, z: 0.1)
                    mustacheNode.scale = SCNVector3(x: 0.02, y: 0.02, z: 0.02)
                    mustacheNode.eulerAngles.x = -.pi / 2
                    uiView.scene.rootNode.addChildNode(mustacheNode)
                } else {
                    print("Failed to load mustache node")
                }
            } catch {
                print("Failed to load mustache scene with error: \(error)")
            }
        } else {
            print("Failed to find \(selectedMustache).scn in the main bundle")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var isRecording = false

        func toggleRecording() {
            if isRecording {
                // Handle recording toggle logic
            } else {
                // Handle recording toggle logic
            }
          
            isRecording.toggle()
        }

        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard let parent = node.parent as? ARViewContainer else {
                print("Parent reference is nil")
                return
            }
            
            if let mustacheURL = Bundle.main.url(forResource: parent.selectedMustache, withExtension: "scn") {
                do {
                    let mustacheScene = try SCNScene(url: mustacheURL, options: nil)
                    if let mustacheNode = mustacheScene.rootNode.childNode(withName: "Mustache", recursively: true)?.clone() {
                        mustacheNode.position = SCNVector3(x: 0, y: -0.02, z: 0.1)
                        mustacheNode.scale = SCNVector3(x: 0.02, y: 0.02, z: 0.02)
                        mustacheNode.eulerAngles.x = -.pi / 2
                        node.addChildNode(mustacheNode)
                    } else {
                        print("Failed to load mustache node")
                    }
                } catch {
                    print("Failed to load mustache scene with error: \(error)")
                }
            } else {
                print("Failed to find \(parent.selectedMustache).scn in the main bundle")
            }
        }
    }
}

