//
//  PeripheralServiceCharacteristicsViewController.swift
//  BlueCap
//
//  Created by Troy Stribling on 6/23/14.
//  Copyright (c) 2014 Troy Stribling. The MIT License (MIT).
//

import UIKit
import BlueCapKit

class PeripheralServiceCharacteristicsViewController : UITableViewController {
 
    weak var service: BCService?
    var peripheralViewController: PeripheralViewController?

    var dataValid = false

    struct MainStoryboard {
        static let peripheralServiceCharacteristicCell = "PeripheralServiceCharacteristicCell"
        static let peripheralServiceCharacteristicSegue = "PeripheralServiceCharacteristic"
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder:aDecoder)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.updateWhenActive()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PeripheralServiceCharacteristicsViewController.peripheralDisconnected), name: BlueCapNotification.peripheralDisconnected, object: self.service?.peripheral)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PeripheralServiceCharacteristicsViewController.didEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == MainStoryboard.peripheralServiceCharacteristicSegue {
            if let service = self.service {
                if let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell) {
                    let viewController = segue.destinationViewController as! PeripheralServiceCharacteristicViewController
                    viewController.characteristic = service.characteristics[selectedIndex.row]
                    viewController.peripheralViewController = self.peripheralViewController
                }
            }
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        return true
    }
    
    func peripheralDisconnected() {
        BCLogger.debug()
        self.tableView.reloadData()
        if let peripheralViewController = self.peripheralViewController {
            if peripheralViewController.peripheralConnected {
                self.presentViewController(UIAlertController.alertWithMessage("Peripheral disconnected") { action in
                        peripheralViewController.peripheralConnected = false
                        self.updateWhenActive()
                    }, animated:true, completion:nil)
            }
        }
    }
    
    func didEnterBackground() {
        self.navigationController?.popToRootViewControllerAnimated(false)
        BCLogger.debug()
    }
    
    // UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let service = self.service {
            return service.characteristics.count
        } else {
            return 0;
        }
    }
    
    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.peripheralServiceCharacteristicCell, forIndexPath: indexPath) as! NameUUIDCell
        if let service = self.service {
            let characteristic = service.characteristics[indexPath.row]
            cell.nameLabel.text = characteristic.name
            cell.uuidLabel.text = characteristic.UUID.UUIDString
            if let peripheralViewController = self.peripheralViewController {
                if peripheralViewController.peripheralConnected {
                    cell.nameLabel.textColor = UIColor.blackColor()
                } else {
                    cell.nameLabel.textColor = UIColor.lightGrayColor()
                }
            } else {
                cell.nameLabel.textColor = UIColor.blackColor()
            }
        }
        return cell
    }
    
    override func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    // UITableViewDelegate

}
