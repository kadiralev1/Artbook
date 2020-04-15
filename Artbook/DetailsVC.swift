//
//  DetailsVC.swift
//  Artbook
//
//  Created by Kadir Kutluhan Alev on 9.04.2020.
//  Copyright © 2020 Kadir Kutluhan Alev. All rights reserved.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var artistTxtField: UITextField!
    @IBOutlet weak var yearTxtField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var choosenPainting = ""
    var choosenPaintingID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // checking the choosen painting
        if choosenPainting != ""{
            // core data
            // şimdi gelen UUID ye göre core data içinde sorgulama yapacağız
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = choosenPaintingID?.uuidString
            // id si %@ a eşit olan datayı getir. oda arg de belirtilen parametre
            fetchReguest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchReguest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchReguest)
                // result will be any
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameTxtField.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistTxtField.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearTxtField.text = "\(year)"
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch {
                
            }
            
            
        }
        else {
            nameTxtField.text = ""
            artistTxtField.text = ""
            yearTxtField.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        
        imageView.isUserInteractionEnabled = true
        
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapGesture)
    }
    
    
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
    }
    
    // after select the photo, what will happen ?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // parametre olarak gelen dictionary de ki any bizim fotomuz olacak
        // bunu image e kast edip kullanacağız
        // üstte edit yapmaya izin verdik burda orjinal resmi aldık
        // yani kullanıcı resmi düzenlese bile biz burada orjinal resmi alabiliriz.
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveBtnClicked(_ sender: Any) {
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        newPainting.setValue(nameTxtField.text!, forKey: "name")
        newPainting.setValue(artistTxtField.text!, forKey: "artist")
        
        if let year = Int(yearTxtField.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        
        do {
            try context.save()
            print("Save is successfull")
        }catch {
            print("There is an error when save process execute.")
        }
        // tüm uygulmaya bu mesajı yayar. Diger taraftan bu mesajları tutmamız lazım
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
