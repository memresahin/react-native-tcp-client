import Foundation
import Network
import React

@objc(TcpClient)
class TcpClient: RCTEventEmitter {

  private var connection: NWConnection?
  private var isConnected: Bool = false

  override static func requiresMainQueueSetup() -> Bool {
    return false
  }

  override func supportedEvents() -> [String]! {
    return ["connect", "data", "error", "close"]
  }

  @objc func connect(_ host: String, port: NSNumber) {
    let nwEndpoint = NWEndpoint.Host(host)
    let nwPort = NWEndpoint.Port(rawValue: port.uint16Value) ?? 1234

    let parameters = NWParameters.tcp
    connection = NWConnection(host: nwEndpoint, port: nwPort, using: parameters)

    connection?.stateUpdateHandler = { [weak self] newState in
      switch newState {
      case .ready:
        self?.isConnected = true
        self?.sendEvent(withName: "connect", body: nil)
        self?.receiveData()
      case .failed(let error):
        self?.sendError(error.localizedDescription)
        self?.connection?.cancel()
      case .cancelled:
        self?.sendEvent(withName: "close", body: nil)
      default:
        break
      }
    }

    connection?.start(queue: .global())
  }

  private func receiveData() {
    connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
      if let data = data, !data.isEmpty {
        let message = String(decoding: data, as: UTF8.self)
        self?.sendEvent(withName: "data", body: ["data": message])
      }

      if let error = error {
        self?.sendError(error.localizedDescription)
        return
      }

      if isComplete {
        self?.sendEvent(withName: "close", body: nil)
        return
      }

      // Listen again
      self?.receiveData()
    }
  }

  @objc func write(_ message: String) {
    guard isConnected, let connection = connection else {
      sendError("Not connected")
      return
    }

    let data = message.data(using: .utf8) ?? Data()
    connection.send(content: data, completion: .contentProcessed { error in
      if let error = error {
        self.sendError(error.localizedDescription)
      }
    })
  }

  @objc func disconnect() {
    connection?.cancel()
    connection = nil
    isConnected = false
    sendEvent(withName: "close", body: nil)
  }

  private func sendError(_ message: String) {
    sendEvent(withName: "error", body: ["message": message])
  }
}
