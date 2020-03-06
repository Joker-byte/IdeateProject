//
//  IdeateTableViewController.swift
//  IdeateProject
//
//  Created by Gianluca Dubioso on 06/03/2020.
//  Copyright © 2020 Gianluca. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class IdeateTableViewController: UITableViewController, IdeateCellDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {


    var ideateItems:[IdeateItem]!
    
    
    var peerID:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
    }
    
    func loadData(){
        ideateItems = [IdeateItem]()
        ideateItems = DataManager.loadAll(IdeateItem.self).sorted(by: {$0.createdAt < $1.createdAt})
        self.tableView.reloadData()
    }
    
    
    
    @IBAction func addItem(_ sender: Any) {
        let addAlert = UIAlertController(title: "New ", message: "Enter a title", preferredStyle: .alert)
        addAlert.addTextField { (textfield:UITextField) in
            textfield.placeholder = " Item Title"
        }
        
        addAlert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action:UIAlertAction) in
            guard let title = addAlert.textFields?.first?.text else {return}
            let newIdeate = IdeateItem(title: title, completed: false, createdAt: Date(), itemIdentifier: UUID())
            newIdeate.saveItem()
            self.ideateItems.append(newIdeate)
            
            let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
            
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }))
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(addAlert, animated: true, completion: nil)
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return ideateItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! IdeateTableViewCell

        let ideateItem = ideateItems[indexPath.row]
        cell.IdeateLabel.text = ideateItem.title
        cell.delegate = self
        
        if ideateItem.completed {
            cell.IdeateLabel.attributedText = strikeThroughText(ideateItem.title)
        }

        return cell
    }
    
    func didRequestDelete(_ cell: IdeateTableViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            ideateItems[indexPath.row].deleteItem()
            ideateItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
    }
    
    func didRequestComplete(_ cell: IdeateTableViewCell) {
        
        if let indexPath = tableView.indexPath(for: cell) {
            var ideateItem = ideateItems[indexPath.row]
            ideateItem.markAsCompleted()
            cell.IdeateLabel.attributedText = strikeThroughText(ideateItem.title)
        }
    }
    
    func didRequestShare(_ cell: IdeateTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let ideateItem = ideateItems[indexPath.row]
            sendIdeate(ideateItem)
        }
    }
    
    func sendIdeate (_ ideateItem:IdeateItem) {
        if mcSession.connectedPeers.count > 0 {
            if let ideateData = DataManager.loadData(ideateItem.itemIdentifier.uuidString) {
                do {
                    try mcSession.send(ideateData, toPeers: mcSession.connectedPeers, with: .reliable)
                }catch{
                    fatalError("Could not send item")
                }
            }
        }else{
            print("you are not connected to another device")
        }
    }
    

    func strikeThroughText (_ text:String) -> NSAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        
        return attributeString
    }
    
   
    // MARK: - Multipeer Connectivity
    
    
    @IBAction func showConnectivityActions(_ sender: Any) {
        let actionSheet = UIAlertController(title: " Exchange", message: "Do you want to Host or Join a session?", preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action:UIAlertAction) in
            
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "ba-td", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action:UIAlertAction) in
            let mcBrowser = MCBrowserViewController(serviceType: "ba-td", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        do {
            let ideateItem = try JSONDecoder().decode(IdeateItem.self, from: data)
            
            DataManager.save(ideateItem, with: ideateItem.itemIdentifier.uuidString)
            
            DispatchQueue.main.async {
                self.ideateItems.append(ideateItem)
                
                let indexPath = IndexPath(row: self.tableView.numberOfRows(inSection: 0), section: 0)
                
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
            
        }catch{
            fatalError("Unable to process recieved data")
        }
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
   
}
