//
//  MultipeerCommunicator.swift
//  TinkoffChat
//
//  Created by Sergey Korobin on 22.10.17.
//  Copyright © 2017 Sergey. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MultipeerCommunicator: NSObject, CommunicatorProtocol, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate{

    var displayedName: String = UIDevice.current.name {
        didSet {
            online = false
            online = true
        }
    }
    
    let myPeerID: MCPeerID
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var usernamesDict: [MCPeerID: String] = [:]
    private var sessionsDict: [MCPeerID: MCSession] = [:]
    private let serviceType = "tinkoff-chat"
    
    weak var delegate: CommunicatorDelegateProtocol?
    var online: Bool = false {
        didSet {
            DispatchQueue.global(qos: .userInitiated).async {
                self.reinit()
            }
        }
    }
    
    func reinit() {
        if online {
            browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
            advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: ["userName": displayedName], serviceType: serviceType)
            browser?.delegate = self
            advertiser?.delegate = self
            browser?.startBrowsingForPeers()
            advertiser?.startAdvertisingPeer()
        } else {
            browser?.stopBrowsingForPeers()
            advertiser?.stopAdvertisingPeer()
            browser = nil
            advertiser = nil
        }
    }
    
    override init() {
        //
        guard let idForVendor = UIDevice.current.identifierForVendor
            else {
                fatalError("How it could be?? No identifier for vendor!!")
            }
        myPeerID = MCPeerID(displayName: idForVendor.description)
        super.init()
    }
    
    func sendMessage(string: String, to userID: String, completionHandler: ((Bool, Error?) -> ())?) {
        var peerID: MCPeerID?
        for unit in sessionsDict.keys {
            if unit.displayName == userID {
                peerID = unit
                break
            }
        }
        if let peerID = peerID {
            let message = ReceivedMessageData(message: string, type: "outgoing")
            do {
                let session = sessionsDict[peerID]
                
                try session?.send(JSONEncoder().encode(message), toPeers: [peerID], with: .reliable)
                completionHandler?(true, nil)
            } catch {
                completionHandler?(false, error)
            }
        }
    }
    
    
    // Session set up
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            delegate?.didFoundUser(userID: peerID.displayName, userName: usernamesDict[peerID])
        case .notConnected:
            delegate?.didLostUser(userID: peerID.displayName)

        default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let message = try JSONDecoder().decode(ReceivedMessageData.self, from: data)
            message.type = "incoming"
            delegate?.didReceiveMessage(text: message.text, fromUser: peerID.displayName, toUser: myPeerID.displayName)
            } catch {
                return
            }
        }
    
    // Browser set up
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
            online = false
            delegate?.failedToStartBrowsingForUsers(error: error)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        delegate?.didLostUser(userID: peerID.displayName)
        sessionsDict.removeValue(forKey: peerID)
    }

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        let userInfo = info?["userName"]
        let encodedContext: Data
        session.delegate = self
        sessionsDict[peerID] = session
        usernamesDict[peerID] = userInfo
        // Логика обёртки discoveryInfo в Data
        do {
            let discoveryInfo = ["userName": displayedName]
            let data = try JSONEncoder().encode(discoveryInfo)
            encodedContext = data
            browser.invitePeer(peerID, to: session, withContext: encodedContext, timeout: 0)
        }
        catch {
            print("can't read discoveryInfo")
        }
    }

    
    // Advertizer set up
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        online = false
        delegate?.failedToStartAdvertising(error: error)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        sessionsDict[peerID] = session
        invitationHandler(true, session)
        // Логика вытаскивания discoveryInfo
        //тут летит !!! фиксим анврап
        if let username = decodePersonInfo(from: context) {
            usernamesDict[peerID] = username
        }
        
    }
        
    func decodePersonInfo(from data: Data?) -> String? {
        // get username or nil from invitationContext when someone invites to session
        guard let fromData = data else { return nil }
        do {
            let username = try JSONDecoder().decode([String:String].self, from: fromData)["userName"]
            if username != nil {
                return username
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
