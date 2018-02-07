//
//  ThreadsTableViewController.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ThreadsTableVC: UITableViewController {

    // This is set to the selected thread when the user selects a row. This is used to prepare for the segue.
    var selectedThread: Thread?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThreadManager.fillThreads(onThreadUpdate: onThreadUpdate) {
            () in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func onThreadUpdate(thread: Thread) {
        ThreadManager.bump(threadId: thread.threadId)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // If we came back from the settings page, we need to refresh the image. Also refresh when coming back from a message so the threads appear in the correct order.
        tableView.reloadData()
    }
    
    func startChat(thread:Thread) {
        selectedThread = thread
        navigationController?.popToRootViewController(animated: true)
        self.performSegue(withIdentifier: "showChatView", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ThreadManager.threads.count
    }

    override func tableView(_ tableViewS: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ThreadTableViewCell

        let thread = ThreadManager.threads[indexPath.row]
        cell.cellImage.image = thread.user.getProfileImage()
        
        cell.cellName.text = thread.user.displayName
        // Display the name in bold if the thread hasn't been read
        if (thread.read) {
            cell.cellName.font = UIFont.systemFont(ofSize: 16.0)
        } else {
            cell.cellName.font = UIFont.boldSystemFont(ofSize: 16.0)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        startChat(thread: ThreadManager.threads[indexPath.row])
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatView",
        let destinationViewController = segue.destination as? ChatVC {
            destinationViewController.thread = selectedThread
        }
    }
}
