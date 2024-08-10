//
//  ImmersiveView.swift
//  Portal Box
//
//  Created by Sarang Borude on 8/10/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor
struct ImmersiveView: View {
    
    @State private var box = Entity() //  to store our box
    
    @State private var world1 = Entity()
    @State private var world2 = Entity()
    @State private var world3 = Entity()
    @State private var world4 = Entity()
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "PortalBoxScene", in: realityKitContentBundle) {
                content.add(scene)

                guard let box = scene.findEntity(named: "Box") else {
                    fatalError()
                }
                
                // change the position and scale of the box
                self.box = box
                box.position = [0, 1, -2] // meters
                box.scale *= [1,2,1]
    
                let worlds = await createWorlds()
                content.add(worlds)
                
                let portals = createPortals()
                content.add(portals)
                
                await addContentToWorlds()
            }
        }
    }
    
    func createWorlds() async -> Entity {
        let worlds = Entity()
        
        //Make world 1
        world1 = Entity()
        world1.components.set(WorldComponent())
        let skybox1 = await createSkyboxEntity(texture: "skybox1")
        world1.addChild(skybox1)
        worlds.addChild(world1)
        //Make world 2
        world2 = Entity()
        world2.components.set(WorldComponent())
        let skybox2 = await createSkyboxEntity(texture: "skybox2")
        world2.addChild(skybox2)
        worlds.addChild(world2)
        
        //Make world 3
        world3 = Entity()
        world3.components.set(WorldComponent())
        let skybox3 = await createSkyboxEntity(texture: "skybox3")
        world3.addChild(skybox3)
        worlds.addChild(world3)
        
        //Make world 4
        world4 = Entity()
        world4.components.set(WorldComponent())
        let skybox4 = await createSkyboxEntity(texture: "skybox4")
        world4.addChild(skybox4)
        worlds.addChild(world4)
        
        return worlds
    }
    
    func createPortals() -> Entity {
        /// Create 4 portals
        let portals = Entity()
        
        let world1Portal = createPortal(target: world1)
        portals.addChild(world1Portal)
        guard let anchorPortal1 = box.findEntity(named: "AnchorPortal1") else {
            fatalError("Cannot find portal anchor")
        }
        anchorPortal1.addChild(world1Portal)
        world1Portal.transform.rotation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])
        
        let world2Portal = createPortal(target: world2)
        portals.addChild(world2Portal)
        guard let anchorPortal2 = box.findEntity(named: "AnchorPortal2") else {
            fatalError("Cannot find portal anchor")
        }
        anchorPortal2.addChild(world2Portal)
        world2Portal.transform.rotation = simd_quatf(angle: -.pi/2, axis: [1, 0, 0])
        
        let world3Portal = createPortal(target: world3)
        portals.addChild(world3Portal)
        guard let anchorPortal3 = box.findEntity(named: "AnchorPortal3") else {
            fatalError("Cannot find portal anchor")
        }
        anchorPortal3.addChild(world3Portal)
        
        let portal3RotX = simd_quatf(angle: .pi/2, axis: [1, 0, 0])
        let portal3RotY = simd_quatf(angle: -.pi/2, axis: [0, 1, 0])
        world3Portal.transform.rotation = portal3RotY * portal3RotX // ORDER Matters!!!!
        
        let world4Portal = createPortal(target: world4)
        portals.addChild(world4Portal)
        guard let anchorPortal4 = box.findEntity(named: "AnchorPortal4") else {
            fatalError("Cannot find portal anchor")
        }
        anchorPortal4.addChild(world4Portal)
        
        let portal4RotX = simd_quatf(angle: .pi/2, axis: [1, 0, 0])
        let portal4RotY = simd_quatf(angle: .pi/2, axis: [0, 1, 0])
        world4Portal.transform.rotation = portal4RotY * portal4RotX// ORDER Matters!!!!
        
        return portals
    }
    
    func addContentToWorlds() async {
        // Add more content to the worlds
        
        if let world1Scene = try? await Entity(named: "World1Scene", in: realityKitContentBundle) {
            world1Scene.position = [0, 3, 0]
            world1.addChild(world1Scene)
        }
        
        if let world2Scene = try? await Entity(named: "World2Scene", in: realityKitContentBundle) {
            world2Scene.position = [0, 3, 0]
            world2.addChild(world2Scene)
        }
        
        if let world3Scene = try? await Entity(named: "World3Scene", in: realityKitContentBundle) {
            world3Scene.position = [0, 10, 0]
            world3.addChild(world3Scene)
        }
        
        if let world4Scene = try? await Entity(named: "World4Scene", in: realityKitContentBundle) {
            world4Scene.position = [0, 10, 0]
            world4.addChild(world4Scene)
        }
    }
    
    func createSkyboxEntity(texture: String) async -> Entity {
        guard let resource = try? await TextureResource(named: texture) else {
            fatalError("Unable to load the skybox")
        }
        
        var material = UnlitMaterial()
        material.color = .init(texture: .init(resource))
        
        let entity = Entity()
        entity.components.set(ModelComponent(mesh: .generateSphere(radius: 1000), materials: [material]))
        entity.scale *= .init(x: -1, y:1, z:1)
        return entity
    }
    
    func createPortal(target: Entity) -> Entity {
        let portalMesh = MeshResource.generatePlane(width:1, depth:1) // meters
        let portal = ModelEntity(mesh: portalMesh, materials: [PortalMaterial()])
        portal.components.set(PortalComponent(target: target))
        return portal
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
