//
//  ViewController.swift
//  Tellomee
//
//  Created by Michael Miller on 11/13/17.
//  Copyright © 2017 Tellomee. All rights reserved.
//

import UIKit
import JSQMessagesViewController


class ChatVC: JSQMessagesViewController {
    
    var thread:Thread?
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start with an empty message list. It shows for a split second.
        PostManager.clearPosts()
        
        senderId = FirebaseManager.currentFirebaseUser?.uid
        senderDisplayName = ""
        
        // Remove the "attachment" button
        inputToolbar.contentView.leftBarButtonItem = nil
        
        inputToolbar.contentView!.textView.returnKeyType = UIReturnKeyType.send
        
        // Remove avatars
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PostManager.fillPosts(uid: FirebaseManager.currentFirebaseUser?.uid, toId:(thread?.user.uid)!, threadId: (thread?.threadId)!, completion: {_ in
            // Now that it's been loaded, set the thread as read
            self.finishReceivingMessage()
        })
        
        // Mark the thread as having been read
        self.thread?.setRead(read: true)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (thread != nil) {
            // Mark the thread as having been read
            self.thread!.setRead(read: true)
            
            // Remove PostManager's observer so we don't keep listening for new messages
            PostManager.removeObserver(threadId: thread!.threadId)
        }
    }
    
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
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return 0
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        PostManager.addPost(threadId: (thread?.threadId)!, text: text, toId: (thread?.user.uid)!, fromId: senderId)
        finishSendingMessage()
    }
    
    // Send the message when the user presses return
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.didPressSend(nil, withMessageText:self.keyboardController.textView?.text , senderId:self.senderId , senderDisplayName: self.senderDisplayName, date: NSDate() as Date!)
            return false // Don't add the "/n" to the textview
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
