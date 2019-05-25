//
//  DetailViewController.swift
//  project-planner-ipad
//
//  Created by Brion Silva on 23/05/2019.
//  Copyright © 2019 Brion Silva. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    
    func configureView() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        // Update the user interface for the detail item.
        if let project = selectedProject {
            if let nameLabel = projectNameLabel {
                nameLabel.text = project.name ?? "Unavailable"
            }
            if let dueDateLabel = dueDateLabel {
                dueDateLabel.text = "Due Date: \(formatter.string(from: project.dueDate as Date))"
            }
            if let priorityLabel = priorityLabel {
                priorityLabel.text = "Priority: \(project.priority ?? "Unavailable")"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var selectedProject: Project? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addTask" {
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 320, height: 400)
            }
        }
    }
}

