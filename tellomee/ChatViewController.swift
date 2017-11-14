//
//  ViewController.swift
//  Tellomee
//
//  Created by Michael Miller on 11/13/17.
//  Copyright © 2017 Tellomee. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
//    var messages = [JSQMessage]()
    
    var selectedUser:User?
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        senderId = FirebaseManager.currentUser?.uid
        senderDisplayName = ""
        
        // Do any additional setup after loading the view, typically from a nib.
        
//        let defaults = UserDefaults.standard
//
//        if  let id = defaults.string(forKey: "jsq_id"),
//            let name = defaults.string(forKey: "jsq_name")
//        {
//            senderId = id
//            senderDisplayName = name
//        }
//        else
//        {
//            senderId = String(arc4random_uniform(999999))
//            senderDisplayName = ""
//
//            defaults.set(senderId, forKey: "jsq_id")
//            defaults.synchronize()
//
//            showDisplayNameDialog()
//        }
        
//        title = "Chat: \(senderDisplayName!)"
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDisplayNameDialog))
//        tapGesture.numberOfTapsRequired = 1
//
//        navigationController?.navigationBar.addGestureRecognizer(tapGesture)
        
        // Remove the "attachment" button
        inputToolbar.contentView.leftBarButtonItem = nil
        
        // Remove avatars
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
//        let query = Constants.refs.databaseChats.queryLimited(toLast: 10)
//
//        _ = query.observe(.childAdded, with: { [weak self] snapshot in
//
//            if  let data        = snapshot.value as? [String: String],
//                let id          = data["sender_id"],
//                let name        = data["name"],
//                let text        = data["text"],
//                !text.isEmpty
//            {
//                if let message = JSQMessage(senderId: id, displayName: name, text: text)
//                {
//                    self?.messages.append(message)
//
//                    self?.finishReceivingMessage()
//                }
//            }
//        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        PostManager.fillPosts(uid: FirebaseManager.currentUser?.uid, toId:(selectedUser?.uid)!, completion: {_ in
            print("Completed filling posts")
            self.finishReceivingMessage()
        })
    }
    
//    @objc func showDisplayNameDialog()
//    {
//        let defaults = UserDefaults.standard
//
//        let alert = UIAlertController(title: "Your Display Name", message: "Before you can chat, please choose a display name. Others will see this name when you send chat messages. You can change your display name again by tapping the navigation bar.", preferredStyle: .alert)
//
//        alert.addTextField { textField in
//
//            if let name = defaults.string(forKey: "jsq_name")
//            {
//                textField.text = name
//            }
//            else
//            {
//                let names = ["Ford", "Arthur", "Zaphod", "Trillian", "Slartibartfast", "Humma Kavula", "Deep Thought"]
//                textField.text = names[Int(arc4random_uniform(UInt32(names.count)))]
//            }
//        }
//
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak alert] _ in
//
//            if let textField = alert?.textFields?[0], !textField.text!.isEmpty {
//
//                self?.senderDisplayName = textField.text
//
//                self?.title = "Chat: \(self!.senderDisplayName!)"
//
//                defaults.set(textField.text, forKey: "jsq_name")
//                defaults.synchronize()
//            }
//        }))
//
//        present(alert, animated: true, completion: nil)
//    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return PostManager.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return PostManager.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return PostManager.messages[(indexPath?.item)!].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return NSAttributedString()
//        PostManager.messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return 0 //messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        PostManager.addPost(username: senderDisplayName, text: text, toId: (selectedUser?.uid)!, fromId: senderId)
        
//        let ref = Constants.refs.databaseChats.childByAutoId()
//
//        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text]
//
//        ref.setValue(message)
        
        finishSendingMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}











////
////  ChatViewController.swift
////  pchatapp
////
////  Created by Brett Romero on 11/10/16.
////  Copyright © 2016 test. All rights reserved.
////
//
//import UIKit
//
//class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    var selectedUser:User?
//
//    @IBOutlet var tableView: UITableView!
//    @IBOutlet var userInput: UITextField!
//    var cellHeight = 44
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        tableView.estimatedRowHeight = 88.0
//        tableView.rowHeight = UITableViewAutomaticDimension
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        PostManager.fillPosts(uid: FirebaseManager.currentUser?.uid, toId:(selectedUser?.uid)!) {  (result:String) in
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        PostManager.posts = []
//    }
//
//
//    @IBAction func sendButton_click(_ sender: AnyObject) {
//        PostManager.addPost(username: (selectedUser?.username)!, text: userInput.text!, toId: (selectedUser?.uid)!, fromId: (FirebaseManager.currentUser?.uid)!)
//        userInput.text = ""
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return PostManager.posts.count
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatTableViewCell
//        let messageText = cell.messageText!
//        messageText.delegate = self
//        cellHeight = Int(messageText.contentSize.height)
//        let post = PostManager.posts[indexPath.row]
//        cell.messageText.text = post.text
//
//        return cell
//    }
//
//
//    /*
//     // MARK: - Navigation
//
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//     }
//     */
//}
//
//extension ChatViewController:UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        let currentOffset = tableView.contentOffset
//        UIView.setAnimationsEnabled(false)
//        tableView.beginUpdates()
//        tableView.endUpdates()
//        UIView.setAnimationsEnabled(true)
//        tableView.setContentOffset(currentOffset, animated: false)
//    }
//}
//
