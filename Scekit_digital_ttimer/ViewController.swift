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

    var isTimerRunning = false // タイマーが実行中かどうかを示すフラグ
    
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
    }

    // UIViewControllerのライフサイクルメソッド viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // ARセッションの設定
        let configuration = ARWorldTrackingConfiguration()

        // ARSCNViewのセッションを開始
        sceneView.session.run(configuration)
        
        // ビューが表示されたときにタイマーを開始
        startTimer()
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
                let elapsedTime = Date().timeIntervalSince(startTime)
                let currentTime = formattedTime(seconds: Int(elapsedTime))

                // UIの更新はメインスレッドで行う
                DispatchQueue.main.async {
                    self.updateTextNode(text: currentTime)
                }
            }
        }
    }

    // MARK: - Timer Methods

    // Start / Stop ボタンが押されたときの処理
    @objc func startStopButtonTapped() {
        if isTimerRunning {
            stopTimer()
            startStopButton.setTitle("Start", for: .normal)
        } else {
            startTimer()
            startStopButton.setTitle("Stop", for: .normal)
        }
    }

    // タイマーを開始するメソッド
    func startTimer() {
        startTime = Date()
        isTimerRunning = true
    }

    // タイマーを停止するメソッド
    func stopTimer() {
        isTimerRunning = false
    }

    // MARK: - UI Updates

    // テキストノードを更新するメソッド
    func updateTextNode(text: String) {
        // テキストノードがまだ作成されていない場合は作成する
        if timerNode == nil {
            timerNode = createTextNode(text: text)
            sceneView.scene.rootNode.addChildNode(timerNode!)
        } else {
            // テキストノードが既に存在する場合は、テキストを更新する
            if let textGeometry = timerNode?.geometry as? SCNText {
                textGeometry.string = text
            }
        }
    }

    // テキストノードを作成するメソッド
    func createTextNode(text: String) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.5)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white

        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.02, 0.02, 0.02) // 適切なスケールを設定してください
        textNode.position = SCNVector3(0, 0, -0.5) // 適切な位置を設定してください

        return textNode
    }

    // 経過時間をフォーマットするメソッド
    private func formattedTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    // レイアウト制約の設定
    func setupConstraints() {
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startStopButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startStopButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            startStopButton.widthAnchor.constraint(equalToConstant: 100),
            startStopButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
