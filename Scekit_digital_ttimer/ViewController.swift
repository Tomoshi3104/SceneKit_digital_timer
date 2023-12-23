import UIKit
import SceneKit
import ARKit

// UIViewControllerを継承したクラス ViewController
class ViewController: UIViewController, ARSCNViewDelegate {
    // ARSCNViewのIBOutlet
    @IBOutlet var sceneView: ARSCNView!
    // AR上のタイマーのノード
    var timerNode: SCNNode?
    // タイマー開始時刻
    var startTime: Date?
    // タイマー中断時刻
    var interruptTime: Date?
    // タイマーが実行中かどうかを示すフラグ
    var isTimerRunning = false
    // タイマーの値を保持するためのプロパティ
    var timerBaseValue: TimeInterval = 0
    // Stop - Start 間のタイマーの値を保持するためのプロパティ
    //var timerInterruptedValue: TimeInterval = 0

    // ボタンの追加とレイアウト制約の設定
    let startStopButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 8
        //button.addTarget(ViewController.self, action: #selector(startStopButtonTapped), for: .touchUpInside) // クラッシュする
        button.addTarget(self, action: #selector(startStopButtonTapped), for: .touchUpInside)
        return button
    }()

    // リセットボタンの追加とレイアウト制約の設定
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()

    // UIViewControllerのライフサイクルメソッド viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // ARSCNViewのデリゲートを設定
        sceneView.delegate = self
        // fpsやタイミング情報を表示
        sceneView.showsStatistics = true
        // 新しいシーンを作成
        let scene = SCNScene()
        sceneView.scene = scene
        // ボタンをビューに追加
        view.addSubview(startStopButton)
        setupConstraints()
        // リセットボタンをビューに追加
        view.addSubview(resetButton)
        setupResetButtonConstraints()
    }

    // UIViewControllerのライフサイクルメソッド viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ARセッションの設定
        let configuration = ARWorldTrackingConfiguration()
        // ARSCNViewのセッションを開始
        sceneView.session.run(configuration)
        // タイマーを配置
        placeTimer()
    }

    // UIViewControllerのライフサイクルメソッド viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // ARSCNViewのセッションを一時停止
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    // ARSCNViewのデリゲートメソッド renderer
    // タイマーが実行中の場合にのみ時間を更新する
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if isTimerRunning {
            if let startTime = startTime {
                let elapsedTime: Double
                //if timerInterruptedValue != 0 {
                if timerBaseValue != 0 {
                    //elapsedTime = Date().timeIntervalSince(startTime) - timerInterruptedValue
                    elapsedTime = Date().timeIntervalSince(startTime) + timerBaseValue
                    print(Date().timeIntervalSince(startTime), elapsedTime)
                } else {
                    print(Date().timeIntervalSince(startTime))
                    elapsedTime = Date().timeIntervalSince(startTime)
                }
                let StringTime = formatTime(seconds: elapsedTime)
                DispatchQueue.main.async {
                    self.updateTextNode(text: StringTime)
                }
            }
//        } else {
//            if let startTime = startTime {
//                let elapsedTime = Date().timeIntervalSince(startTime) - timerInterruptedValue
//                print(Date().timeIntervalSince(startTime), timerInterruptedValue, elapsedTime)
//            }
        }
    }
// 0 -> 10 - 20 -> 30
    // MARK: - Timer Methods

    // Start / Stop ボタンが押されたときの処理
    // タイマーが再開されたときに、経過時間を保持したまま再開するように修正
    @objc func startStopButtonTapped() {
        if isTimerRunning { // Stop 処理
            stopTimer()
            startStopButton.setTitle("Start", for: .normal)
        } else { // Start 処理
            //print("timerValue: \(timerValue)")
//            if let interruptTime = interruptTime {
//                let currentTime = Date().timeIntervalSince(interruptTime) + timerValue
//                updateTextNode(text: formatTime(seconds: currentTime))
//            } else {
//                updateTextNode(text: formatTime(seconds: timerValue))
//            }
            startTimer()
            startStopButton.setTitle("Stop", for: .normal)
        }
    }

    @objc func resetButtonTapped() {
        resetTimer() // タイマーを停止
        updateTextNode(text: "00:00.00") // テキストノードをリセット
        startStopButton.setTitle("Start", for: .normal) // Start/Stopボタンのテキストをリセット
    }

    // タイマーを描画するメソッド
    func placeTimer() {
        updateTextNode(text: "00:00.00")
    }
    
    // タイマーを開始するメソッド
    func startTimer() {
        if !isTimerRunning {
            if let startTime = startTime { // startTime が nil でない場合の処理(stop ボタン押下後)
                if let interruptTime = interruptTime { // interruptTime が nil でない場合の処理(stop ボタン押下後)
                    //timerInterruptedValue = Date().timeIntervalSince(startTime!) - Date().timeIntervalSince(interruptTime)
                    //timerInterruptedValue = Date().timeIntervalSince(interruptTime)
                } else { // interruptTime が nil の場合の処理(現時点では非想定)
                }
                //timerBaseValue -= timerInterruptedValue
                //let currentTime = Date().timeIntervalSince(startTime)
                //timerValue += currentTime // 経過時間を加算
                //print("timerValue: \(timerValue)")
                //print("currentTime: \(currentTime)")
                //print("interruptTime: \(interruptTime)")
            } else { // startTime が nil の場合の処理 (初期状態時 / reset ボタン押下後)
                //startTime = Date()
                //print("startTime: \(startTime) - type: \(type(of: startTime))")
            }

            interruptTime = nil
            startTime = Date()
            isTimerRunning = true
            print("startTime: \(startTime)")
            print("isTimerRunning: \(isTimerRunning)")
        }
    }
    
    
//    // タイマーを開始するメソッド
//    func startTimer() {
//        if !isTimerRunning {
//            if let startTime = startTime { // startTime が nil ではない場合(直前にresetボタンが押されていない)
//                let currentTime = Date().timeIntervalSince(startTime)
////                //timerValue = timerValue + currentTime - Date().timeIntervalSince(interruptTime!) // 経過時間を加算
////                print("timerValue: \(timerValue)")
////                print("currentTime: \(currentTime)")
////                print("interruptTime: \(interruptTime)")
////                //startTime = Date()
////                //startTime = Date()
////                print("startTime: \(startTime) - type: \(type(of: startTime))")
//            } else { // startTime が nil の場合(直前にresetボタンが押されている)
//                print("startTime: \(startTime) - type: \(type(of: startTime))")
//                startTime = Date()
//                
////                let currentTime = Date().timeIntervalSince(startTime!)
////                //timerValue = timerValue + currentTime - Date().timeIntervalSince(interruptTime!) // 経過時間を加算
////                print("timerValue: \(timerValue)")
////                print("currentTime: \(currentTime)")
////                print("interruptTime: \(interruptTime)")
////                //
//            }
//            isTimerRunning = true
//            print("startTime: \(startTime)")
//            print("isTimerRunning: \(isTimerRunning)")
//        }
//    }

//    func startTimer() {
//        if !isTimerRunning {
//            if startTime == nil {
//                startTime = Date()
//            } else {
//                let currentTime = Date().timeIntervalSince(startTime!)
//                elapsedTime += currentTime // 経過時間を加算
//                print("elapsedTime: \(elapsedTime)")
//                print("currentTime: \(currentTime)")
//                startTime = Date()
//            }
//            isTimerRunning = true
//            print("startTime: \(startTime)")
//            print("isTimerRunning: \(isTimerRunning)")
//        }
//    }
    
    // タイマーを停止するメソッド
    func stopTimer() {
        if isTimerRunning {
            interruptTime = Date()
            //timerInterruptedValue =
            //let currentTime = Date().timeIntervalSince(startTime!)
            //timerValue = Date().timeIntervalSince(startTime!)
            isTimerRunning = false
            // Call a method to update the text node with the current timer value
            readTextNode()
            updateTextNode(text: formatTime(seconds: timerBaseValue))
            //readTextNode()

        }
    }

    // タイマーをリセットするメソッド
    func resetTimer() {
        //interruptTime = Date()
        updateTextNode(text: formatTime(seconds: 0))
        startTime = nil
        interruptTime = nil
        //timerInterruptedValue = 0
        timerBaseValue = 0
        //timerValue = 0
        //timerValue = 0
        //let currentTime = 0
        isTimerRunning = false
        //updateTextNode(text: formattedTime(seconds: Int(elapsedTime)))
        print("interruptTime: \(interruptTime)")
    }
    
    // MARK: - UI Updates

    // テキストノードを更新するメソッド
    func updateTextNode(text: String) {
        // テキストノードがまだ作成されていない場合は作成する
        if timerNode == nil {
            print("timerNode created.")
            timerNode = createTextNode(text: text)
            sceneView.scene.rootNode.addChildNode(timerNode!)
        } else {
            // テキストノードが既に存在する場合は、テキストを更新する
            if let textGeometry = timerNode?.geometry as? SCNText {
                textGeometry.string = text
            }
        }
    }

//    func updateTextNode2(text: String) {
//        // テキストノードがまだ作成されていない場合は作成する
//        if timerNode == nil {
//            timerNode = createTextNode(text: text)
//            sceneView.scene.rootNode.addChildNode(timerNode!)
//        } else {
//            // テキストノードが既に存在する場合は、テキストを更新する
//            if let textGeometry = timerNode?.geometry as? SCNText {
//                textGeometry.string = text
//            }
//        }
//    }
    
    func readTextNode(){
        if timerNode != nil {
            if let textGeometry = timerNode?.geometry as? SCNText {
                let timerString: String = textGeometry.string as! String
                print("timerString: \(timerString)")
                if let convertedTime = convertTime(timeString: timerString) {
                    timerBaseValue = convertedTime
                }
                print(type(of: timerString))
                print("readTextNode: timerBaseValue: \(timerBaseValue)")
            }
        }
    }
            
    // テキストノードを作成するメソッド
    func createTextNode(text: String) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.5)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01) // 適切なスケールを設定してください
        textNode.position = SCNVector3(-0.2, -0.2, -0.5) // 適切な位置を設定してください
        return textNode
    }

//    func createTextNode2(text: String) -> SCNNode {
//        let textGeometry = SCNText(string: text, extrusionDepth: 1.5)
//        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
//        let textNode = SCNNode(geometry: textGeometry)
//        textNode.scale = SCNVector3(0.005, 0.005, 0.005) // 適切なスケールを設定してください
//        textNode.position = SCNVector3(-0.2, -0.5, -0.5) // 適切な位置を設定してください
//        return textNode
//    }
    
    // 経過時間をフォーマットするメソッド
    private func formatTime(seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        let milliseconds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, remainingSeconds, milliseconds)
    }
    
    private func convertTime(timeString: String) -> TimeInterval? {
        let timeComponents = timeString.components(separatedBy: ":")
        if timeComponents.count == 2,
           let minutes = Double(timeComponents[0]),
           let secondsAndMillis = Double(timeComponents[1]) {
            let totalSeconds = (minutes * 60) + secondsAndMillis
            return TimeInterval(totalSeconds)
        }
        return nil
    }

    // レイアウト制約の設定
    // Resetボタンのレイアウト制約の設定
    func setupResetButtonConstraints() {
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -60), // 画面の中央線から-60の位置に配置
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50), // 下から-16の位置に配置
            resetButton.widthAnchor.constraint(equalToConstant: 100),
            resetButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // Startボタンのレイアウト制約の設定
    func setupConstraints() {
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startStopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 60), // 画面の中央線から+60の位置に配置
            startStopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50), // 下から-16の位置に配置
            startStopButton.widthAnchor.constraint(equalToConstant: 100),
            startStopButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
