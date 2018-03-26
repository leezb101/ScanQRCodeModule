//
//  ViewController.swift
//  ScanQRCodeModule
//
//  Created by leezb101 on 2017/5/8.
//  Copyright © 2017年 leezb101. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    let label = { () -> UILabel in
        let label = UILabel()
        label.backgroundColor = .darkGray
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "没有检测到二维码"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
        
        
        buildCaptureSession()
        buildOutPut()
        buildPreviewLayer()
        view.bringSubview(toFront: label)
        buildCodeFrameView()
        
        
        captureSession?.startRunning()
    }

    
    /// AVCaptureMetadataOutput代理
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            label.text = "没有检测到二维码"
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if  metadataObj.type == AVMetadataObjectTypeQRCode {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds
            
            if metadataObj.stringValue != nil {
                label.text = metadataObj.stringValue
            }
        }
    }

    /// 初始化摄像头输入源以及会话管理
    func buildCaptureSession() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            
            captureSession?.addInput(input)
        } catch {
            print(error)
        }
    }
    
    /// 创建输出元数据
    func buildOutPut() {
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
    }
    
    /// 创建扫描试图预览层
    func buildPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
    }
    
    /// 创建展示二维码范围的框视图
    func buildCodeFrameView() {
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView?.layer.borderWidth = 2.0
        view.addSubview(qrCodeFrameView!)
        view.bringSubview(toFront: qrCodeFrameView!)
    }
    
}

