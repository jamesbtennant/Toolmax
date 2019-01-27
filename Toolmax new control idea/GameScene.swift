//
//  GameScene.swift
//  Toolmax
//
//  Created by James Tennant on 10/11/18.
//  Copyright © 2018 James Tennant. All rights reserved.
//

import SpriteKit
import GameplayKit
import AudioToolbox.AudioServices

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Balance-Control Variables
    var gravityPower : CGFloat = -6
    var playerMass : CGFloat = 1.2
    var playerGroundLinearDamping : CGFloat = 4
    var playerAirLinearDamping : CGFloat = 0.1
    var ballMass : CGFloat = 0.01
    var ballRestitution : CGFloat = 0.6
    var movePower : CGFloat = 300
    var dashPower : CGFloat = 1600
    var rotatePower : CGFloat = 4
    var jumpPower : CGFloat = 1400
    var jetPower : CGFloat = 80
    var shootPower : CGFloat = 5000
    var bouncePadPower : CGFloat = 1800
    var currencyMass : CGFloat = 0.001
    var starDriftSpeed : CGFloat = 2
    var magnitudeToPointCoef : CGFloat = 0.1
    var pointToCurrencyCoef : Double = 0.001
    var health : Int = 512
    var currencyDenominator : UInt32 = 20 // Currency has a 1 in [denominator] chance of being ice
    var starDriftTime = 30
    var player2Power : CGFloat = 120
    
    // Primary Objects
    var ball = SKSpriteNode()
    var player = SKSpriteNode()
    var player2 = SKSpriteNode()
    var bullet : SKSpriteNode?
    var currency : SKSpriteNode?
    
    // Availability
    var dashUpAvailable = true
    var dashDownAvailable = true
    var dashLeftAvailable = true
    var dashRightAvailable = true
    var shootAvailable = true
    
    // Visual Effects
    var smoke : SKSpriteNode?
    var smokeBorder : SKSpriteNode?
    var ballTrail : SKSpriteNode?
    var ballTrail2 : SKSpriteNode?
    var bouncePadEffect : SKSpriteNode?
    
    // Sound Effects
    var dashSoundeffects = [SKAction.playSoundFileNamed("dash 1.mp3", waitForCompletion: false), SKAction.playSoundFileNamed("dash 2.mp3", waitForCompletion: false), SKAction.playSoundFileNamed("dash 3.mp3", waitForCompletion: false)]
    var backgroundMusic = SKAction.playSoundFileNamed("stress s2.mp3", waitForCompletion: false)
    
    // Mass
    var massBase = SKSpriteNode()
    var massLeft = SKSpriteNode()
    var massRight = SKSpriteNode()
    
    // Enviroment
    var sky = SKSpriteNode()
    var stars = SKSpriteNode()
    var background = SKSpriteNode()
    
    // Buttons
    var button1 = SKSpriteNode()
    var button2 = SKSpriteNode()
    var button3 = SKSpriteNode()
    var button4 = SKSpriteNode()
    var button5 = SKSpriteNode()
    var button6 = SKSpriteNode()
    
    // Rotation Dial
    var dial = SKSpriteNode()
    var playerInitialRotation : CGFloat = 0
    var dialTouchInitialPosition : CGFloat = 0
    var dialTouchDisplacement : CGFloat = 0
    var dialSensitivity : CGFloat = 0.003 // Default is 0.006
    var dialTouches : [UITouch] = []
    
    // Score-Related
    var healthLeft = SKSpriteNode()
    var healthLeftDrag = SKSpriteNode()
    var healthLeftLabel = SKLabelNode()
    var healthLeftLabelColor = SKLabelNode()
    var healthRight = SKSpriteNode()
    var healthRightDrag = SKSpriteNode()
    var healthRightLabel = SKLabelNode()
    var healthRightLabelColor = SKLabelNode()
    var pointLabel : SKLabelNode?
    var pointLabelColor : SKLabelNode?
    var racksLabel = SKLabelNode()
    var racksLabelColor = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var racks : Int = 0
    var score : [Int] = []
    var scoreToPosCoef : CGFloat = 1
    
    // Touches
    var button1Touches : [UITouch] = []
    var button2Touches : [UITouch] = []
    var button3Touches : [UITouch] = []
    var button4Touches : [UITouch] = []
    var button5Touches : [UITouch] = []
    var jetTouches : [UITouch] = []
    
    // Other
    var intro = SKVideoNode(fileNamed: "intro.mp4")
    var charge = 0
    var actionTimer = Timer()
    var playerJetTextures = [SKTexture(imageNamed: "player air 1"), SKTexture(imageNamed: "player air 2")]
    var inGameCurrency : [SKSpriteNode] = []
    var inGameBullets : [SKSpriteNode] = []
    var ready = false
    
    // didMove
    override func didMove(to view: SKView) {
        playIntro()
    }
    
    // playIntro
    func playIntro() {
        intro.zPosition = 10
        intro.size.width = 2400
        intro.size.height = 3200
        addChild(intro)
        intro.play()
    }
    
    // createGameScene
    func createGameScene() {
        
        // Set up contact stuff
        self.physicsWorld.contactDelegate = self
        
        // Create timer
        actionTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(GameScene.timerUpdate), userInfo: nil, repeats: true)
        
        // Create border
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = 128
        
        // Set gravity
        self.physicsWorld.gravity.dy = gravityPower
        
        // Create ball
        ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"))
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.mass = ballMass
        ball.physicsBody?.restitution = ballRestitution
        ball.physicsBody?.categoryBitMask = 64
        ball.physicsBody?.contactTestBitMask = 128
        addChild(ball)
        
        // Create player
        player = SKSpriteNode(texture: SKTexture(imageNamed: "player ground"))
        player.zPosition = 1
        player.position.x = -300
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 264))
        player.physicsBody?.mass = playerMass
        player.physicsBody?.categoryBitMask = 128
        player.physicsBody?.contactTestBitMask = 8
        addChild(player)
        
        // Create player 2 (AI)
//        player2 = SKSpriteNode(texture: SKTexture(imageNamed: "player 2"))
//        player2.position.x = 300
//        player2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 264))
//        player2.physicsBody?.mass = playerMass
//        addChild(player2)
        
        // Create mass
        massBase = SKSpriteNode(texture: SKTexture(imageNamed: "mass base"))
        massLeft = SKSpriteNode(texture: SKTexture(imageNamed: "mass left"))
        massRight = SKSpriteNode(texture: SKTexture(imageNamed: "mass right"))
        massBase.position.y = -700
        massLeft.position = CGPoint(x: -1050, y: 900)
        massRight.position = CGPoint(x: 1050, y: 900)
        massBase.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mass base"), size: massBase.size)
        massBase.physicsBody?.affectedByGravity = false
        massBase.physicsBody?.allowsRotation = false
        massBase.physicsBody?.isDynamic = false
        massLeft.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mass left"), size: massLeft.size)
        massLeft.physicsBody?.affectedByGravity = false
        massLeft.physicsBody?.allowsRotation = false
        massLeft.physicsBody?.isDynamic = false
        massRight.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "mass right"), size: massRight.size)
        massRight.physicsBody?.affectedByGravity = false
        massRight.physicsBody?.allowsRotation = false
        massRight.physicsBody?.isDynamic = false
        addChild(massBase)
        addChild(massLeft)
        addChild(massRight)
        massBase.physicsBody?.categoryBitMask = 128
        massLeft.physicsBody?.categoryBitMask = 128
        massRight.physicsBody?.categoryBitMask = 128
        
        // Create Enviroment
        sky = SKSpriteNode(texture: SKTexture(imageNamed: "sky"))
        stars = SKSpriteNode(texture: SKTexture(imageNamed: "stars"))
        background = SKSpriteNode(texture: SKTexture(imageNamed: "background"))
        sky.zPosition = -5
        stars.zPosition = -4
        background.zPosition = -3
        sky.size.width = 2400
        sky.size.height = 3200
        sky.texture?.filteringMode = SKTextureFilteringMode.nearest
        addChild(sky)
        addChild(stars)
        addChild(background)
        stars.run(SKAction.move(to: CGPoint(x: 0, y: 1600), duration: TimeInterval(starDriftTime)))
        
        // Create buttons
        button1 = SKSpriteNode(texture: SKTexture(imageNamed: "button"))
        button2 = SKSpriteNode(texture: SKTexture(imageNamed: "button"))
        button3 = SKSpriteNode(texture: SKTexture(imageNamed: "button"))
        button4 = SKSpriteNode(texture: SKTexture(imageNamed: "button"))
        button5 = SKSpriteNode(texture: SKTexture(imageNamed: "button"))
        button6 = SKSpriteNode(texture: SKTexture(imageNamed: "button"))
        button1.position = CGPoint(x: -218.75, y: -750)
        button2.position = CGPoint(x: 218.75, y: -750)
        button3.position = CGPoint(x: 656.25, y: -750)
        button4.position = CGPoint(x: -218.75, y: -1300)
        button5.position = CGPoint(x: 218.75, y: -1300)
        button6.position = CGPoint(x: 656.25, y: -1300)
        button1.zPosition = 1
        button2.zPosition = 1
        button3.zPosition = 1
        button4.zPosition = 1
        button5.zPosition = 1
        button6.zPosition = 1
        addChild(button1)
        addChild(button2)
        addChild(button3)
        addChild(button4)
        addChild(button5)
        addChild(button6)
        
        // Creat Rotation Dial
        dial = SKSpriteNode(texture: SKTexture(imageNamed: "dial"))
        dial.position = CGPoint(x: -656.25, y: -1025)
        dial.zPosition = 1
        addChild(dial)
        
        // Create health
        score = [health, health]
        // Given any value for health, generate a coefficient for converting score to the health bar's position
        scoreToPosCoef = 900 / CGFloat(health)
        healthLeft = SKSpriteNode(texture: SKTexture(imageNamed: "health left"))
        healthRight = SKSpriteNode(texture: SKTexture(imageNamed: "health right"))
        healthLeftDrag = SKSpriteNode(texture: SKTexture(imageNamed: "drag"))
        healthRightDrag = SKSpriteNode(texture: SKTexture(imageNamed: "drag"))
        healthLeftLabel = SKLabelNode(text: "\(score[0])")
        healthRightLabel = SKLabelNode(text: "\(score[1])")
        healthLeftLabelColor = SKLabelNode(text: healthLeftLabel.text)
        healthRightLabelColor = SKLabelNode(text: healthRightLabel.text)
        healthLeft.position = CGPoint(x: -1200, y: 1600)
        healthRight.position = CGPoint(x: 1200, y: 1600)
        healthLeftDrag.position = healthLeft.position
        healthRightDrag.position = healthRight.position
        healthLeftLabel.position = CGPoint(x: -800, y: 1515)
        healthRightLabel.position = CGPoint(x: 800, y: 1515)
        healthLeftLabel.fontSize = 110
        healthRightLabel.fontSize = 110
        healthLeftLabel.fontName = "Toolmax 1"
        healthRightLabel.fontName = "Toolmax 1"
        healthLeftLabel.fontColor = UIColor.black
        healthRightLabel.fontColor = UIColor.black
        healthLeftLabel.zPosition = 1
        healthRightLabel.zPosition = 1
        
        healthLeftLabelColor = SKLabelNode(text: healthLeftLabel.text)
        healthRightLabelColor = SKLabelNode(text: healthRightLabel.text)
        healthLeftLabelColor.position = CGPoint(x: -800, y: 1515)
        healthRightLabelColor.position = CGPoint(x: 800, y: 1515)
        healthLeftLabelColor.fontSize = 110
        healthRightLabelColor.fontSize = 110
        healthLeftLabelColor.fontName = "Toolmax 1 Color"
        healthRightLabelColor.fontName = "Toolmax 1 Color"
        healthLeftLabelColor.fontColor = UIColor(hue: 0.75, saturation: 0.01, brightness: 0.82, alpha: 1)
        healthRightLabelColor.fontColor = UIColor(hue: 0.75, saturation: 0.01, brightness: 0.82, alpha: 1)
        
        healthLeft.anchorPoint = CGPoint(x: 0, y: 1)
        healthRight.anchorPoint = CGPoint(x: 1, y: 1)
        healthLeftDrag.anchorPoint = healthLeft.anchorPoint
        healthRightDrag.anchorPoint = healthRight.anchorPoint
        healthRight.zPosition = -1
        healthLeft.zPosition = -1
        healthRightDrag.zPosition = -2
        healthLeftDrag.zPosition = -2
        addChild(healthLeft)
        addChild(healthRight)
        addChild(healthLeftDrag)
        addChild(healthRightDrag)
        addChild(healthLeftLabel)
        addChild(healthRightLabel)
        addChild(healthLeftLabelColor)
        addChild(healthRightLabelColor)
        
        // Create bullet
        self.bullet = SKSpriteNode(texture: SKTexture(imageNamed: "bullet"))
        bullet?.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        bullet?.physicsBody?.mass = currencyMass
        
        // Create currency
        self.currency = SKSpriteNode(texture: SKTexture(imageNamed: "rack"))
        currency?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100))
        currency?.physicsBody?.mass = currencyMass
        currency?.physicsBody?.categoryBitMask = 8
        currency?.physicsBody?.contactTestBitMask = 2
        
        // Create smoke
        self.smoke = SKSpriteNode(texture: SKTexture(imageNamed: "smoke1"))
        smoke?.zPosition = -1
        self.smokeBorder = SKSpriteNode(texture: SKTexture(imageNamed: "smoke1 border"))
        smokeBorder?.zPosition = -2
        
        // Create ball trail
        self.ballTrail = SKSpriteNode(color: UIColor(hue: 0.48, saturation: 0.52, brightness: 0.98, alpha: 1) , size: CGSize(width: 20, height: 20))
        ballTrail?.zPosition = -1
        if let ballTrail = self.ballTrail {
            ballTrail.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                             SKAction.fadeOut(withDuration: 0.5),
                                             SKAction.removeFromParent()]))
        }
        // Create ball trail 2
        self.ballTrail2 = SKSpriteNode(color: UIColor.black , size: CGSize(width: 32, height: 32))
        ballTrail2?.zPosition = -2
        if let ballTrail2 = self.ballTrail2 {
            ballTrail2.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        // Create bounce pad effect
        self.bouncePadEffect = SKSpriteNode(texture: SKTexture(imageNamed: "bounce pad effect"))
        bouncePadEffect?.position.y = -435
        
        // Create point label
        self.pointLabel = SKLabelNode(text: "Error")
        pointLabel?.zPosition = 3
        pointLabel?.fontSize = 130
        pointLabel?.fontColor = UIColor.black
        pointLabel?.fontName = "Toolmax 1"
        if let pointLabel = self.pointLabel {
            pointLabel.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        self.pointLabelColor = SKLabelNode(text: "Error")
        pointLabelColor?.zPosition = 2
        pointLabelColor?.fontSize = 130
        pointLabelColor?.fontColor = UIColor(hue: 0.75, saturation: 0.01, brightness: 0.82, alpha: 1)
        pointLabelColor?.fontName = "Toolmax 1 Color"
        if let pointLabelColor = self.pointLabelColor {
            pointLabelColor.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                                   SKAction.fadeOut(withDuration: 0.5),
                                                   SKAction.removeFromParent()]))
        }
        
        // Create racks label
        racksLabel = SKLabelNode(text: "error")
        racksLabel.zPosition = 2
        racksLabel.fontSize = 130
        racksLabel.fontName = "Toolmax 1"
        racksLabel.fontColor = UIColor.black
        racksLabel.position.y = 1400
        addChild(racksLabel)
        racksLabel.run(SKAction.fadeOut(withDuration: 0))
        
        racksLabelColor = SKLabelNode(text: "error")
        racksLabelColor.zPosition = 1
        racksLabelColor.fontSize = 130
        racksLabelColor.fontName = "Toolmax 1 Color"
        racksLabelColor.fontColor = UIColor(displayP3Red: 0.294, green: 0.6745, blue: 0.973, alpha: 1)
        racksLabelColor.position.y = 1400
        addChild(racksLabelColor)
        racksLabelColor.run(SKAction.fadeOut(withDuration: 0))
        
        //run(backgroundMusic)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.ready = true
        })
    }
    
    // touchesBegan
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // Intro
            if intro.contains(location) {
                intro.pause()
                intro.position.x = 2400
                intro.removeFromParent()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.createGameScene()
                })
            }
            
            // Button 1
            if button1.contains(location) {
                if dashLeftAvailable == true {
                    
                    button1Touches.append(touch)
                    
                    let dx = dashPower * cos (player.zRotation + CGFloat.pi)
                    let dy = dashPower * sin (player.zRotation + CGFloat.pi)
                    player.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
                    
                    AudioServicesPlaySystemSound(SystemSoundID(1519))
                    //let selectRand = 1 + arc4random_uniform(3)
                    //run(SKAction.playSoundFileNamed("dash " + "\(selectRand)" + ".mp3", waitForCompletion: false))
                    
                    dashLeftAvailable = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.dashLeftAvailable = true
                    })
                    
                }
            }
            
            // Button 2
            if button2.contains(location) {
                if dashUpAvailable == true {
                    
                    button2Touches.append(touch)
                    
                    let dx = dashPower * cos (player.zRotation + CGFloat.pi/2)
                    let dy = dashPower * sin (player.zRotation + CGFloat.pi/2)
                    player.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
                    
                    AudioServicesPlaySystemSound(SystemSoundID(1519))
                    //let selectRand = 1 + arc4random_uniform(3)
                    //run(SKAction.playSoundFileNamed("dash " + "\(selectRand)" + ".mp3", waitForCompletion: false))
                    
                    dashUpAvailable = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.dashUpAvailable = true
                    })
                    
                }
            }
            
            // Button 3
            if button3.contains(location) {
                if dashRightAvailable == true {
                    
                    button3Touches.append(touch)
                    
                    let dx = dashPower * cos (player.zRotation)
                    let dy = dashPower * sin (player.zRotation)
                    player.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
                    
                    AudioServicesPlaySystemSound(SystemSoundID(1519))
                    //let selectRand = 1 + arc4random_uniform(3)
                    //run(SKAction.playSoundFileNamed("dash " + "\(selectRand)" + ".mp3", waitForCompletion: false))
                    
                    dashRightAvailable = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.dashRightAvailable = true
                    })
                    
                }
            }
            
            // Button 4
            if button4.contains(location) {
                if shootAvailable == true {
                    button4Touches.append(touch)
                    AudioServicesPlaySystemSound(SystemSoundID(1519))
                    shootAvailable = false
                    shoot()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.shoot()
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.shoot()
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        self.shoot()
                    })
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                        self.inGameBullets[0].removeFromParent()
                        self.inGameBullets[1].removeFromParent()
                        self.inGameBullets[2].removeFromParent()
                        self.inGameBullets[3].removeFromParent()
                        self.inGameBullets = []
                        self.shootAvailable = true
                    })
                }
            }
            
            // Button 5
            if button5.contains(location) {
                if dashDownAvailable == true {
                    
                    button5Touches.append(touch)
                    
                    let dx = dashPower * cos (player.zRotation - CGFloat.pi/2)
                    let dy = dashPower * sin (player.zRotation - CGFloat.pi/2)
                    player.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
                    
                    AudioServicesPlaySystemSound(SystemSoundID(1519))
                    //let selectRand = 1 + arc4random_uniform(3)
                    //run(SKAction.playSoundFileNamed("dash " + "\(selectRand)" + ".mp3", waitForCompletion: false))
                    
                    dashDownAvailable = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.dashDownAvailable = true
                    })
                    
                }
            }
            
            // Button 6
            if button6.contains(location) {
                jetTouches.append(touch)
                run(SKAction.playSoundFileNamed("rumble.mp3", waitForCompletion: false))
                player.run(SKAction.repeatForever(SKAction.animate(with: playerJetTextures, timePerFrame: 0.05, resize: false, restore: false) ))
            }
            
            // Rotaion Dial
            if dial.contains(touch.location(in: self)) {
                // Store the touch
                dialTouches = [touch]
                // Record touch's initial position
                dialTouchInitialPosition = touch.location(in: self).y
                // Record player's initial rotation
                playerInitialRotation = player.zRotation
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if dialTouches.contains(touch) {
                // Calculate displacement
                dialTouchDisplacement = touch.location(in: self).y - dialTouchInitialPosition
                // Rotate Player
                player.zRotation = playerInitialRotation + dialTouchDisplacement * dialSensitivity
                player.physicsBody?.angularVelocity = 0
            }
        }
    }
    
    // timerUpdate
    @objc func timerUpdate() {
        
        // Reset stars if ready
        if stars.position.y == 1600 {
            stars.position.y = 0
            stars.run(SKAction.move(to: CGPoint(x: 0, y: 1600), duration: TimeInterval(starDriftTime)))
        }
        
        // Button 1
        if button1Touches.count > 0 {
            button1.texture = SKTexture(imageNamed: "button down")
        } else if button1Touches.count == 0 {
            button1.texture = SKTexture(imageNamed: "button")
        }
        
        // Button 2
        if button2Touches.count > 0 {
            button2.texture = SKTexture(imageNamed: "button down")
        } else {
            button2.texture = SKTexture(imageNamed: "button")
        }
        
        // Button 3
        if button3Touches.count > 0 {
            button3.texture = SKTexture(imageNamed: "button down")
        } else {
            button3.texture = SKTexture(imageNamed: "button")
        }
        
        // Button 4
        if button4Touches.count > 0 {
            button4.texture = SKTexture(imageNamed: "button down")
        } else if button4Touches.count == 0 {
            button4.texture = SKTexture(imageNamed: "button")
        }
        
        // Button 5
        if button5Touches.count > 0 {
            button5.texture = SKTexture(imageNamed: "button down")
        } else if button5Touches.count == 0 {
            button5.texture = SKTexture(imageNamed: "button")
        }
        
        // Button 6
        if jetTouches.count > 0 {
            button6.texture = SKTexture(imageNamed: "button down")
            let dx = jetPower * cos (player.zRotation + CGFloat.pi/2)
            let dy = jetPower * sin (player.zRotation + CGFloat.pi/2)
            player.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
            generateSmokeTrail()
        } else if jetTouches.count == 0 {
            button6.texture = SKTexture(imageNamed: "button")
        }
        
        // player 2
        if player2.position.x > ball.position.x {
            player2.physicsBody?.applyImpulse(CGVector(dx: -player2Power, dy: 0))
        } else {
            player2.physicsBody?.applyImpulse(CGVector(dx: player2Power, dy: 0))
        }
        if player2.position.y > ball.position.y {
            player2.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -player2Power))
        } else {
            player2.physicsBody?.applyImpulse(CGVector(dx: 0, dy: player2Power))
        }
        if player2.position.y < -210 && player2.zRotation > 0.1 || player2.zRotation < -0.1 {
            player2.run(SKAction.rotate(toAngle: 0, duration: 0.2))
            player2.physicsBody?.angularVelocity = 0
        }
        
    }
    
    // Update by Any Physics Simulation
    override func didSimulatePhysics() {
        
        if ready {
            makeBallTrail()
        }
        
        // Check if ball scored
        if ball.position.x > 975 {
            TeamScored(whichTeam: -1)
        }
        if ball.position.x < -975 {
            TeamScored(whichTeam: 1)
        }
        
        // Bounce Pad
        if ball.position.x > -100 && ball.position.x < 100 && ball.position.y < -310 {
            ball.physicsBody?.velocity.dy = bouncePadPower
            makeBouncePadEffect()
        }
    }
    
    // shoot
    func shoot() {
        if let n = self.bullet?.copy() as! SKSpriteNode? {
            n.position = player.position
            let dx = shootPower * cos (player.zRotation)
            let dy = shootPower * sin (player.zRotation)
            n.physicsBody?.velocity = CGVector(dx: dx, dy: dy)
            inGameBullets.append(n)
            self.addChild(n)
        }
    }
    
    // teamScored
    func TeamScored(whichTeam: CGFloat) {
        // Calculate point
        let magnitude = getMagnetude((ball.physicsBody?.velocity.dx)!, (ball.physicsBody?.velocity.dy)!)
        let point = Int(magnitudeToPointCoef * magnitude)
        
        // Display point
        if let n = self.pointLabel?.copy() as! SKLabelNode? {
            n.text = "\(point)"
            n.position.y = ball.position.y
            if whichTeam > 0 {
                n.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            } else {
                n.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            }
            n.position.x = whichTeam * -870
            self.addChild(n)
        }
        if let n = self.pointLabelColor?.copy() as! SKLabelNode? {
            if point > health / 2 {
                n.fontColor = UIColor(hue: 0.864, saturation: 0.26, brightness: 1, alpha: 1)
            }
            n.text = "\(point)"
            n.position.y = ball.position.y
            if whichTeam > 0 {
                n.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
            } else {
                n.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
            }
            n.position.x = whichTeam * -870
            self.addChild(n)
        }
        
        // Generate currency
        let currency = Int(pointToCurrencyCoef * Double(point) * Double(point))
        if currency > 0 {
            for _ in 1...currency {
                let chance = 1 + arc4random_uniform(currencyDenominator)
                if let n = self.currency?.copy() as! SKSpriteNode? {
                    if chance == 1 {
                        n.size = CGSize(width: 98, height: 77)
                        n.texture = SKTexture(imageNamed: "diamond")
                        n.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "diamond"), size: n.size)
                    }
                    n.position.y = ball.position.y - 50 + CGFloat(arc4random_uniform(100))
                    n.position.x = ball.position.x + whichTeam * 150
                    n.physicsBody?.velocity.dx = whichTeam * CGFloat(arc4random_uniform(1200))
                    n.physicsBody?.velocity.dy = CGFloat(arc4random_uniform(200))
                    self.addChild(n)
                    inGameCurrency.append(n)
                }
            }
        }
        
        // Update health
        if whichTeam < 0 {
            score[1] -= point
            if score[1] > 0 {
                healthRightLabel.text = String(score[1])
                healthRightLabelColor.text = healthRightLabel.text
                healthRight.position.x = -scoreToPosCoef * CGFloat(score[1]) + 2100
                healthRightDrag.run(SKAction.move(to: healthRight.position, duration: 1))
            } else {
                score[1] = 0
                healthRightLabel.text = String(score[1])
                healthRightLabelColor.text = healthRightLabel.text
                healthRight.position.x = -scoreToPosCoef * CGFloat(score[1]) + 2100
                healthRightDrag.run(SKAction.move(to: healthRight.position, duration: 1))
                //gameOver()
            }
        } else {
            score[0] -= point
            if score[0] > 0 {
                healthLeftLabel.text = String(score[0])
                healthLeftLabelColor.text = healthLeftLabel.text
                healthLeft.position.x = scoreToPosCoef * CGFloat(score[0]) - 2100
                healthLeftDrag.run(SKAction.move(to: healthLeft.position, duration: 1))
            } else {
                score[0] = 0
                healthLeftLabel.text = String(score[0])
                healthLeftLabelColor.text = healthLeftLabel.text
                healthLeft.position.x = scoreToPosCoef * CGFloat(score[0]) - 2100
                healthLeftDrag.run(SKAction.move(to: healthLeft.position, duration: 1))
                //gameOver()
            }
        }
        
        // Remove ball and reset game
        ball.position.y = -3200
        ball.position.x = 300
        ball.physicsBody?.velocity.dx = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            self.resetGame()
        })
    }
    
    func gameOver() {
        //player2.removeFromParent()
        //gameOverLabel.text = "Game Over. You earned " + String(racks)
        //gameOverLabel.fontSize = 100
        //gameOverLabel.fontName = "Cocogoose Pro"
        //addChild(gameOverLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Player and Currency
        if (contact.bodyA.node == player && inGameCurrency.contains(contact.bodyB.node as! SKSpriteNode)) {
            contact.bodyB.node?.removeFromParent()
            stackCollected()
        }
        if (contact.bodyB.node == player && inGameCurrency.contains(contact.bodyA.node as! SKSpriteNode)) {
            contact.bodyA.node?.removeFromParent()
            stackCollected()
        }
        
        // Ball and Mass
        if  contact.collisionImpulse > 1 && (contact.bodyA.node == ball && contact.bodyB.categoryBitMask == 128) {
            contact.bodyB.node?.removeFromParent()
            print("test2")
            let selectRand = 1 + arc4random_uniform(4)
            run(SKAction.playSoundFileNamed("ball impact " + "\(selectRand)", waitForCompletion: false))
        }
        if contact.collisionImpulse > 1 && (contact.bodyB.node == ball && contact.bodyA.categoryBitMask == 128) {
            
            let selectRand = 1 + arc4random_uniform(4)
            run(SKAction.playSoundFileNamed("ball impact " + "\(selectRand)", waitForCompletion: false))
        }
        
    }
    
    // stackCollected
    func stackCollected() {
        //run(currencySoundEffect)
        racks += 1
        racksLabel.text = "racks: " + String(racks)
        racksLabel.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0),
                                          SKAction.fadeOut(withDuration: 2)]))
        racksLabelColor.text = racksLabel.text
        racksLabelColor.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0),
                                               SKAction.fadeOut(withDuration: 2)]))
    }
    
    // getMagnitude
    func getMagnetude(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        return (a * a + b * b).squareRoot()
    }
    
    // generateSmokeTrail
    func generateSmokeTrail() {
        let whichSmoke = 1 + arc4random_uniform(3)
        let rotation = (CGFloat(1 + arc4random_uniform(16)) * CGFloat.pi)/CGFloat(8)
        let rotationVelocity : CGFloat = -4 + CGFloat(arc4random_uniform(9))
        if let n = self.smoke?.copy() as! SKSpriteNode? {
            n.zRotation = rotation
            n.texture = SKTexture(imageNamed: "smoke" + String(whichSmoke))
            n.position.x = player.position.x - 100 * sin(player.zRotation - CGFloat.pi)
            n.position.y = player.position.y - 100 * cos(player.zRotation)
            self.addChild(n)
            n.color = UIColor(hue: 0.48, saturation: 0.52, brightness: 0.98, alpha: 1)
            n.run(SKAction.repeatForever(SKAction.rotate(byAngle: rotationVelocity, duration: 1)))
            n.run(SKAction.sequence([SKAction.wait(forDuration: 0.7),
                                     SKAction.fadeOut(withDuration: 0.3),
                                     SKAction.removeFromParent()]))
        }
        if let n = self.smokeBorder?.copy() as! SKSpriteNode? {
            n.zRotation = rotation
            n.texture = SKTexture(imageNamed: "smoke" + String(whichSmoke) + " border")
            n.position.x = player.position.x - 100 * sin(player.zRotation - CGFloat.pi)
            n.position.y = player.position.y - 100 * cos(player.zRotation)
            self.addChild(n)
            n.run(SKAction.repeatForever(SKAction.rotate(byAngle: rotationVelocity, duration: 1)))
            n.run(SKAction.sequence([SKAction.wait(forDuration: 0.7),
                                     SKAction.fadeOut(withDuration: 0.3),
                                     SKAction.removeFromParent()]))
        }
    }
    
    // makeBallTrail
    func makeBallTrail() {
        let ballSpeed = getMagnetude((ball.physicsBody?.velocity.dx)!, (ball.physicsBody?.velocity.dy)!)
        if let n = self.ballTrail?.copy() as! SKSpriteNode? {
            n.position = ball.position
            n.alpha = ballSpeed/1000 - 1
            self.addChild(n)
        }
        if let n = self.ballTrail2?.copy() as! SKSpriteNode? {
            n.position = ball.position
            n.alpha = ballSpeed/1000 - 1
            self.addChild(n)
        }
    }
    
    // makeBouncePadEffect
    func makeBouncePadEffect() {
        if let n = self.bouncePadEffect?.copy() as! SKSpriteNode? {
            self.addChild(n)
            n.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1),
                                     SKAction.removeFromParent()]))
        }
    }
    
    // Reset game
    func resetGame() {
        ball.position.x = 0
        ball.position.y = 1100
        ball.zRotation = 0
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ball.physicsBody?.angularVelocity = 0
    }
    
    // Touches Ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if button4Touches.contains(touch) {
                button4Touches.remove(at: button4Touches.index(of: touch)!)
                player.physicsBody?.angularVelocity = 0
            }
            if button5Touches.contains(touch) {
                button5Touches.remove(at: button5Touches.index(of: touch)!)
                player.physicsBody?.angularVelocity = 0
            }
            if jetTouches.contains(touch) {
                jetTouches.remove(at: jetTouches.index(of: touch)!)
                player.removeAllActions()
                player.texture = SKTexture(imageNamed: "player ground")
            }
            if button1Touches.contains(touch) {
                button1Touches.remove(at: button1Touches.index(of: touch)!)
                charge = 0
            }
            if button2Touches.contains(touch) {
                button2Touches.remove(at: button2Touches.index(of: touch)!)
            }
            if button3Touches.contains(touch) {
                button3Touches.remove(at: button3Touches.index(of: touch)!)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if button4Touches.contains(touch) {
                button4Touches.remove(at: button4Touches.index(of: touch)!)
            }
            if button5Touches.contains(touch) {
                button5Touches.remove(at: button5Touches.index(of: touch)!)
            }
            if jetTouches.contains(touch) {
                jetTouches.remove(at: jetTouches.index(of: touch)!)
                player.removeAllActions()
                player.texture = SKTexture(imageNamed: "player ground")
            }
            if button1Touches.contains(touch) {
                button1Touches.remove(at: button1Touches.index(of: touch)!)
            }
            if button2Touches.contains(touch) {
                button2Touches.remove(at: button2Touches.index(of: touch)!)
            }
            if button3Touches.contains(touch) {
                button3Touches.remove(at: button3Touches.index(of: touch)!)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Do nothing for maximum frame rate
    }
}

