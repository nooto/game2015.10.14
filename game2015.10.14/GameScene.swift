//
//  GameScene.swift
//  game2015.10.14
//
//  Created by MacYY on 15/10/14.
//  Copyright (c) 2015年 ponphy. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var myLabel = SKLabelNode(fontNamed:"Chalkduster")
    var planetexure = SKTexture(imageNamed: "Spaceship")
    var enemyTexture=SKTexture(imageNamed: "Enm");
    var plane:SKSpriteNode!
    var count = 0
    
    var isTouched = false
    
    var bulletTime:TimeInterval = 0.2//子弹发射间隔
    var lastBullet:TimeInterval = 0//上次发射的时间点
    var toucheGap = CGPoint(x: 0, y: 0)
    
    var enemyTime:TimeInterval = 1
    var lastEnemy:TimeInterval = 0
    
    let PlayerCategory:UInt32 = 1<<1
    let BulletCategory:UInt32 = 1<<2
    let EnemyCategory:UInt32 = 1<<3
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        plane = SKSpriteNode(texture: planetexure)
        plane.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        plane.setScale(0.5)
        plane.name = "plane"
        addChild(plane)

        
        
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask == BulletCategory | EnemyCategory{
            print("enemy die")
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        let location:CGPoint! = touches.first?.location(in: self)
        toucheGap = CGPoint(x: location.x - plane.position.x, y: location.y - plane.position.y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let location:CGPoint! = touches.first?.location(in: self)
        let xDir = clamp(location.x - toucheGap.x, min: 0, max: size.width)
        let yDir = clamp(location.y - toucheGap.y, min: 0, max: size.height)
        plane.position = CGPoint(x: xDir, y: yDir)
    
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouched = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        if currentTime >= lastBullet + bulletTime{
            createBullet();
            lastBullet = currentTime
        }
        if currentTime >= lastEnemy + enemyTime{
            createEnemy()
            lastEnemy = currentTime
            enemyTime = TimeInterval(arc4random() % 20 + 5) / 100
            //一个神奇的经过反复测试得出的还不错的随机时间间隔
        }
    }
    
    func createBullet(){
        let bullet = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        bullet.position = CGPoint(x: plane.position.x, y: plane.position.y + 50)
        bullet.strokeColor = UIColor.clear
        bullet.fillColor = UIColor.green
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height: 10))
        bullet.physicsBody?.categoryBitMask = BulletCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.contactTestBitMask = EnemyCategory
        addChild(bullet)
        
        bullet.run(SKAction.sequence([SKAction.moveBy(x: 0, y: size.height, duration: 2), SKAction.removeFromParent()]))
    }
    
    func createEnemy(){
        let enemy = SKSpriteNode(texture: enemyTexture)
        enemy.setScale(0.5)
        
        let randomX = CGFloat(arc4random()).truncatingRemainder(dividingBy: size.width)
        
        enemy.position = CGPoint(x: randomX, y: size.height)
        addChild(enemy)
        
        enemy.run(SKAction.sequence([SKAction.moveBy(x: 0, y: -size.height, duration: 4), SKAction.removeFromParent()]))
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemyTexture.size())
        enemy.physicsBody?.categoryBitMask = EnemyCategory
        enemy.physicsBody?.collisionBitMask = 0
        enemy.physicsBody?.contactTestBitMask = BulletCategory
    }
    
    func clamp(_ x: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat{
        if x <= min{
            return min
        }else if x >= max{
            return max
        }else{
            return x
        }
    }
    
}
