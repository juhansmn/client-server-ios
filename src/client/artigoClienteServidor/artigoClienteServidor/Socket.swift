//
//  Socket.swift
//  artigoClienteServidor
//
//  Created by Juan Suman on 03/09/20.
//  Copyright © 2020 Juan Suman. All rights reserved.
//

import Foundation

protocol SocketDelegate: class {
    func receivedMessage(message: String)
}

class Socket: NSObject {
    var delegate: SocketDelegate?
    
    //Recebe/Lê
    var inputStream: InputStream!
    //Envia/Escreve
    var outputStream: OutputStream!
    
    let maxReadLength = 64
    let ip = "192.168.0.15"
    let porta = 2350
    
    
    override init(){
        super.init()
    }
    
    func setupNetwork(){
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, ip as CFString, UInt32(porta), &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)
        
        inputStream.open()
        outputStream.open()
    }
    
    func sendToServer(message: String){
        let data = message.data(using: .utf8)!
        
        _ = data.withUnsafeBytes {
            guard let pointer_msg = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else{
                print("Erro ao enviar mensagem")
                return
            }

            outputStream.write(pointer_msg, maxLength: data.count)
        }
    }
}

extension Socket: StreamDelegate{
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode{
        case .hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
        case .endEncountered:
            print("Fim")
        case .errorOccurred:
            print("Erro")
        case .hasSpaceAvailable:
            print("Há espaço disponível")
        default:
            break
        }
    }
    
    private func readAvailableBytes(stream: InputStream) {
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)

      while stream.hasBytesAvailable {
        let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
        
        if numberOfBytesRead < 0, let error = stream.streamError {
          print(error)
          break
        }
        
        let serverMessage = String(bytesNoCopy: buffer, length: numberOfBytesRead, encoding: .utf8, freeWhenDone: true)
        
        delegate?.receivedMessage(message: serverMessage!)
      }
    }
}
