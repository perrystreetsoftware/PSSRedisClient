//
//  ViewController.swift
//  PSSRedisClient
//
//  Created by esilverberg on 03/11/2017.
//  Copyright (c) Perry Street Software, Inc
//

import UIKit
import PSSRedisClient

class ViewController: UIViewController, RedisManagerDelegate, UITextFieldDelegate {
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var results: UITextView!
    @IBOutlet weak var connectionInfo: UILabel!

    static let defaultRedisHost: String = "localhost"
    static let defaultRedisPort: Int = 6379
    static let defaultRedisPwd: String = "foo"
    static let defaultRedisChannel: String = "foo"

    var redisManager: RedisManager?
    var subscriptionManager: RedisManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.connectionInfo.text = "Disconnected"

        self.redisManager = RedisManager(delegate: self)
        self.subscriptionManager = RedisManager(delegate: self)
        self.redisManager?.connect(host: ViewController.defaultRedisHost,
                                   port: ViewController.defaultRedisPort,
                                   pwd: ViewController.defaultRedisPwd)

        self.subscriptionManager?.connect(host: ViewController.defaultRedisHost,
                                          port: ViewController.defaultRedisPort,
                                          pwd: ViewController.defaultRedisPwd)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.executeTapped()

        textField.resignFirstResponder()
        return false
    }

    @IBAction func executeTapped() {
        if let command: String = self.input.text {
            let components = command.components(separatedBy: [" "])

            self.redisManager?.exec(args: components,
                                    completion: self.messageReceived);
        }
    }

    func subscriptionMessageReceived(channel: String, message: String) {
        self.results.text = "Channel: \(channel) Message: \(message)"
    }

    func socketDidConnect(redisManager: RedisManager) {
        self.connectionInfo.text = "Connected";

        // Setup a subscription after we have connected
        if (redisManager == self.subscriptionManager) {
            self.subscribe(channel: ViewController.defaultRedisChannel)
        }
    }

    func socketDidDisconnect(redisManager: RedisManager) {
        self.connectionInfo.text = "Disconnected"
    }

    func subscribe(channel: String) {
        self.subscriptionManager?.exec(args: ["subscribe", channel], completion: nil)
    }

    func subscriptionMessageReceived(results: NSArray) {
        if (results.count == 3 && results.firstObject as? String != nil) {
            let message = results.firstObject as! String

            if (message == "message") {
                debugPrint("SOCKET: Sending message of \(results[2])");

                self.results.text = "Subscription heard: \(results[2])"
            } else if (message == "subscribe") {
                debugPrint("SOCKET: Subscription successful");
            } else {
                debugPrint("SOCKET: Unknown message received");
            }
        }
    }

    func messageReceived(message: NSArray) {
        if (message.firstObject as? NSError != nil) {
            let error = message.firstObject as! NSError
            let userInfo = error.userInfo

            if let possibleMessage = userInfo["message"] {
                if let actualMessage = possibleMessage as? String {
                    self.results.text = actualMessage
                }
            }
        } else {
            self.results.text = "Results: \(message.componentsJoined(by: " "))"
        }
    }
}

