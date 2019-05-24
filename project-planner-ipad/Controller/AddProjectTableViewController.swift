//
//  AddProjectTableViewController.swift
//  project-planner-ipad
//
//  Created by Brion Silva on 24/05/2019.
//  Copyright © 2019 Brion Silva. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddProjectTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate {
    
    var projects: [NSManagedObject] = []
    var endDate : Date!
    var addToCalendarFlag: Bool = false
    let dateFormatter : DateFormatter = DateFormatter()
    var datePickerVisible = false
    
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var addProjectButton: UIBarButtonItem!
    
    var priority: String = "Low" {
        didSet {
            priorityLabel.text = priority
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set initial end date to one hour ahead of current time
        var date = Date()
        date.addTimeInterval(TimeInterval(60.00 * 60.00))
        endDate = date // Set the raw end date field variable
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        endDateLabel.text = dateFormatter.string(from: date)
        
        // Settings the placeholder for notes UITextView
        notesTextView.delegate = self
        notesTextView.text = "Notes"
        notesTextView.textColor = UIColor.lightGray
        
        // Disable add button
        toggleAddButtonEnability()
    }
    
    @IBAction func handleDateChange(_ sender: UIDatePicker) {
        endDate = sender.date // Set the raw end date field variable
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        endDateLabel.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func handleCancelButtonClick(_ sender: UIBarButtonItem) {
        dismissAddProjectPopOver()
    }
    
    @IBAction func handleAddButtonClick(_ sender: UIBarButtonItem) {
        if validate() {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Project", in: managedContext)!
            let project = NSManagedObject(entity: entity, insertInto: managedContext)
            
            project.setValue(projectNameTextField.text, forKeyPath: "name")
            project.setValue(notesTextView.text, forKeyPath: "notes")
            project.setValue(endDate, forKeyPath: "due_date")
            project.setValue(priority, forKeyPath: "priority")
            project.setValue(addToCalendarFlag, forKeyPath: "add_to_calendar")
            
            do {
                try managedContext.save()
                projects.append(project)
            } catch _ as NSError {
                let alert = UIAlertController(title: "Error", message: "An error occured while saving the project.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Please fill the required fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        // Dismiss PopOver
        dismissAddProjectPopOver()
    }
    
    @IBAction func handleAddToCalendarToggle(_ sender: UISwitch) {
        addToCalendarFlag = sender.isOn
    }
    
    @IBAction func handleProjectNameChange(_ sender: Any) {
        toggleAddButtonEnability()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        toggleAddButtonEnability()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        toggleAddButtonEnability()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Notes"
            textView.textColor = UIColor.lightGray
        }
        toggleAddButtonEnability()
    }
    
    // Handles the add button enable state
    func toggleAddButtonEnability() {
        if validate() {
            addProjectButton.isEnabled = true;
        } else {
            addProjectButton.isEnabled = false;
        }
    }
    
    // Dismiss Popover
    func dismissAddProjectPopOver() {
        dismiss(animated: true, completion: nil)
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
    // Check if the required fields are empty or not
    func validate() -> Bool {
        if !(projectNameTextField.text?.isEmpty)! && !(notesTextView.text == "Notes") && !(notesTextView.text?.isEmpty)! {
            return true
        }
        return false
    }
    
    // Setting the selected priority back on the selection view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setPriority",
            let prioritySelectionViewController = segue.destination as? PrioritySelectionTableViewController {
            prioritySelectionViewController.selectedPriority = priority
        }
    }
}

// MARK: - UITableViewDelegate
extension AddProjectTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            projectNameTextField.becomeFirstResponder()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            notesTextView.becomeFirstResponder()
        }
        
        // Section 1 contains end date(inddex: 0) and add to callender(inddex: 1) rows
        if(indexPath.section == 1 && indexPath.row == 0) {
            datePickerVisible = !datePickerVisible
            tableView.reloadData()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1 {
            if datePickerVisible == false {
                return 0.0
            }
            return 200.0
        }
        // Make Notes text view bigger: 80
        if indexPath.section == 0 && indexPath.row == 1 {
            return 80.0
        }
        
        return 50.0
    }
}

// MARK: - IBActions
extension AddProjectTableViewController {
    
    @IBAction func unwindWithSelectedGame(segue: UIStoryboardSegue) {
        if let prioritySelectionViewController = segue.source as? PrioritySelectionTableViewController,
            let selectedPriority = prioritySelectionViewController.selectedPriority {
            priority = selectedPriority
        }
    }
}