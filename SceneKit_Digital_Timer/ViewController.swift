import UIKit
import SceneKit
import ARKit

// UIViewControllerを継承したクラス ViewController
class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    // ARSCNViewのIBOutlet
    @IBOutlet var sceneView: ARSCNView!
    // AR上のタイマーのノード
    var timerNode: SCNNode?
    // タイマー開始時刻
    var startTime: Date?
    // タイマーが実行中かどうかを示すフラグ
    var isTimerRunning = false
    // タイマーの状態変化が発生したかどうかを示すフラグ
    var isStatusChanged = false
    // タイマーの値を保持するためのプロパティ
    var timerBaseValue: TimeInterval = 0
    
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
    
    // Adjustボタンの追加とレイアウト制約の設定
    let adjustButton: UIButton = {
        let button = UIButton()
        button.setTitle("Adjust", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(adjustButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // UIViewControllerのライフサイクルメソッド viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // ARSessionのデリゲートをViewController自体に設定
        self.sceneView.session.delegate = self
        // ARSCNViewのデリゲートをViewController自体に設定
        sceneView.delegate = self
        // fpsやタイミング情報を表示
        sceneView.showsStatistics = true
        // 新しいシーンを作成
        let scene = SCNScene()
        sceneView.scene = scene
        // Start/Stopボタンをビューに追加
        view.addSubview(startStopButton)
        setupConstraints()
        // Resetボタンをビューに追加
        view.addSubview(resetButton)
        setupResetButtonConstraints()
        // Adjustボタンをビューに追加
        view.addSubview(adjustButton)
        setupAdjustButtonConstraints()
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
    
    // ARSCNViewのデリゲートメソッド renderer -
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //print("rendering")
        if isTimerRunning { // タイマーが実行中の場合にのみ時間を更新する
            if let startTime = startTime {
                let elapsedTime: Double
                if timerBaseValue != 0 {
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
        } else {
            if isStatusChanged { // stop ボタン、または reset ボタン押下時の処理
                isStatusChanged = false
                if let startTime = startTime {
                    readTextNode()
                    updateTextNode(text: formatTime(seconds: timerBaseValue))
                } else {
                    DispatchQueue.main.async {
                        self.updateTextNode(text: "00:00.00")
                    }
                }
            }
        }
    }
        
    // MARK: - Timer Methods
    
    // Start / Stop ボタン押下時の処理
    @objc func startStopButtonTapped() {
        if isTimerRunning { // Stop 処理
            stopTimer()
            startStopButton.setTitle("Start", for: .normal)
        } else { // Start 処理
            startTimer()
            startStopButton.setTitle("Stop", for: .normal)
        }
    }
    
    // Reset ボタン押下時の処理
    @objc func resetButtonTapped() {
        resetTimer() // タイマーを停止
        //updateTextNode(text: "00:00.00") // テキストノードをリセット
        startStopButton.setTitle("Start", for: .normal) // Start/Stopボタンのテキストをリセット
    }
    
    // Adjust ボタン押下時の処理
    @objc func adjustButtonTapped() {
        adjustTimer()
    }
    
    // タイマーを描画するメソッド
    func placeTimer() {
        updateTextNode(text: "00:00.00")
    }
    
    // タイマーを開始するメソッド
    func startTimer() {
        if !isTimerRunning {
            startTime = Date()
            isTimerRunning = true
        }
    }
    
    // タイマーを停止するメソッド
    func stopTimer() {
        if isTimerRunning {
            isTimerRunning = false
            isStatusChanged = true
        }
    }
    
    // タイマーをリセットするメソッド
    func resetTimer() {
        startTime = nil
        timerBaseValue = 0
        isTimerRunning = false
        isStatusChanged = true
    }
    
    // MARK: - ARSessionDelegate
    
    // タイマーを画面中央に再配置するメソッド
    func adjustTimer() {
        //print(sceneView.pointOfView!)
        if let camera = sceneView.pointOfView {
            let position = SCNVector3(x: -0.2, y: -0.1, z: -0.5) // Set the position relative to the camera
            let convertedPosition = camera.convertPosition(position, to: nil)
            timerNode?.position = convertedPosition
            timerNode?.eulerAngles = camera.eulerAngles // Set the node's orientation to match the camera's orientation
        }
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
    
    // テキストノードに表示された経過時間を読み取るメソッド
    func readTextNode(){
        // テキストノードが既に存在する場合は経過時間を読み取る
        if timerNode != nil {
            if let textGeometry = timerNode?.geometry as? SCNText {
                let timerString: String = textGeometry.string as! String
                print("timerString: \(timerString)")
                // 経過時間を型変換して、timerBaseValue に代入する
                if let convertedTime = convertTime(timeString: timerString) {
                    timerBaseValue = convertedTime
                }
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
    
    // 経過時間をフォーマットするメソッド
    private func formatTime(seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        let milliseconds = Int((seconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, remainingSeconds, milliseconds)
    }
    
    // 経過時間を TimeInterval 型に型変換するメソッド
    private func convertTime(timeString: String) -> TimeInterval? {
        let timeComponents = timeString.components(separatedBy: ":")
        // timeString の形式が想定通り、"xx:yy" の場合にのみ処理を実行する
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
            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -180), // 画面の中央線から-180の位置に配置
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50), // 下から-16の位置に配置
            resetButton.widthAnchor.constraint(equalToConstant: 100),
            resetButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // Startボタンのレイアウト制約の設定
    func setupConstraints() {
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startStopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0), // 画面の中央に配置
            startStopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50), // 下から-16の位置に配置
            startStopButton.widthAnchor.constraint(equalToConstant: 100),
            startStopButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // Adjustボタンのレイアウト制約の設定
    func setupAdjustButtonConstraints() {
        adjustButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adjustButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 180), // 画面の中央線から+180の位置に配置
            adjustButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50), // 下から-16の位置に配置
            adjustButton.widthAnchor.constraint(equalToConstant: 100),
            adjustButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
