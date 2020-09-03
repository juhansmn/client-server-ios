//
//  ViewController.swift
//  artigoClienteServidor
//
//  Created by Juan Suman on 03/09/20.
//  Copyright © 2020 Juan Suman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    let clientSocket = Socket()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clientSocket.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        clientSocket.setupNetwork()
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        //enviar para o servidor
        clientSocket.sendToServer(message: "pintar")
    }
}

extension ViewController: SocketDelegate{
    func receivedMessage(message: String) {
        imageView.image = UIImage(named: message)
    }
}

