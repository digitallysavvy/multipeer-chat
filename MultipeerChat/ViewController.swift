//
//  ViewController.swift
//  MultipeerChat
//
//  Created by Hermes Frangoudis on 9/18/15.
//  Copyright © 2015 Hermes Frangoudis. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate,
MCSessionDelegate {
    
    let serviceType = "LCOC-Chat"
    
    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!

    @IBOutlet weak var chatView: UITextView!
    @IBOutlet weak var messageField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        self.browser = MCBrowserViewController(serviceType:serviceType,
            session:self.session)
        
        self.browser.delegate = self;
        
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType,
            discoveryInfo:nil, session:self.session)
        
        // tell the assistant to start advertising our fabulous chat
        self.assistant.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendChat(_ sender: UIButton) {
        // Bundle up the text in the message field, and send it off to all
        // connected peers
        
        let textLine = self.messageField.text!
        
        let msg = textLine.data(using: String.Encoding.utf8,
            allowLossyConversion: false)
        
        
        do {
            try self.session.send(msg!, toPeers: self.session.connectedPeers,
            with: MCSessionSendDataMode.unreliable)
        }catch _ {
            print("Error sending data")
        }
        
        
        self.updateChat(self.messageField.text!, fromPeer: self.peerID)
        
        self.messageField.text = ""
        
    }
    
    func updateChat(_ text : String, fromPeer peerID: MCPeerID) {
        // Appends some text to the chat view
        
        // If this peer ID is the local device's peer ID, then show the name
        // as "Me"
        var name : String
        
        switch peerID {
            case self.peerID:
                name = "Me"
            default:
                name = peerID.displayName
        }
        
        // Add the name to the message and display it
        let message = "\(name): \(text)\n"
        self.chatView.text = self.chatView.text + message
        
    }
    
    @IBAction func showBrowser(_ sender: UIButton) {
        // Show the browser view controller
        self.present(self.browser, animated: true, completion: nil)
    }
    
    func browserViewControllerDidFinish(
        _ browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
            self.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(
        _ browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is cancelled
            
            self.dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, didReceive data: Data,
        fromPeer peerID: MCPeerID)  {
            // Called when a peer sends an NSData to us
            
            // This needs to run on the main queue
            DispatchQueue.main.async {
                
                let msg = String(data: data, encoding: String.Encoding.utf8)
                
                self.updateChat(msg!, fromPeer: peerID)
            }
    }

    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(_ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, with progress: Progress)  {
            
            // Called when a peer starts sending a file to us
    }
    
    func session(_ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL, withError error: Error?)  {
            // Called when a file has finished transferring from another peer
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream,
        withName streamName: String, fromPeer peerID: MCPeerID)  {
            // Called when a peer establishes a stream with us
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID,
        didChange state: MCSessionState)  {
            // Called when a connected peer changes state (for example, goes offline)
            
    }
    

}

