//
//  ViewController.swift
//  Pokemon
//
//  Created by t2023-m0019 on 7/15/24.
//

import UIKit
import SnapKit
import CoreData

let profileImageView = UIImageView()
let randomImageButton = UIButton()
let nameTextView = UITextView()
let phoneNumberTextView = UITextView()

class ContactViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var container: NSPersistentContainer!
    var contact: Contact?
    var contacts: [Contact] = []
    let tableView = UITableView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchContacts()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer

        title = "친구 목록"
        view.backgroundColor = .white
        
        setupTableView()
        tableView.separatorStyle = .none
        loadContactDetails()
        
        let addButton = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(addButtonTapped))
        
        self.navigationItem.rightBarButtonItem = addButton
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)]
        }
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
    }
    
    func loadContactDetails() {
        if let contact = contact {
            nameTextView.text = contact.name
            phoneNumberTextView.text = contact.phoneNumber
            if let profileImageData = contact.profileImage {
                profileImageView.image = UIImage(data: profileImageData)
            }
        }
    }
    
    func fetchContacts() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            contacts = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("DEBUG: Failed To Fetch Contacts. \(error.localizedDescription)")
        }
    }
    
    @objc func addButtonTapped() {
        let addPage = AddViewController()
        navigationController?.pushViewController(addPage, animated: true)
        print("DEBUG: Add Button Tapped.")
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactCell.self, forCellReuseIdentifier: "ContactCell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        let addVC = AddViewController()
        addVC.contact = contact

        navigationController?.pushViewController(addVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        let contact = contacts[indexPath.row]
        
        cell.profileImageView.image = UIImage(named: "profile_placeholder")
        cell.nameLabel.text = contact.name
        cell.phoneNumberLabel.text = contact.phoneNumber
        
        let separatorWidth: CGFloat = 368
        let separatorHeight: CGFloat = 1
        let separator = UIView(frame: CGRect(x: (cell.frame.width - separatorWidth) / 2, y: cell.frame.height - separatorHeight, width: separatorWidth, height: separatorHeight))
        separator.backgroundColor = .lightGray
        cell.addSubview(separator)
        
        if let profileImageData = contact.profileImage {
            cell.profileImageView.image = UIImage(data: profileImageData)
        } else {
            cell.profileImageView.image = UIImage(named: "profile")
        }
        
        cell.nameLabel.text = contact.name ?? "이름없음"
        cell.phoneNumberLabel.text = contact.phoneNumber ?? "번호없음"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

class ContactCell: UITableViewCell {
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let phoneNumberLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUIs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("어쩌구저쩌구")
    }
    
    func setupUIs() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(phoneNumberLabel)
        
        profileImageView.layer.cornerRadius = 30
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.black.cgColor
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(profileImageView.snp.right).offset(16)
        }
        
        phoneNumberLabel.font = UIFont.systemFont(ofSize: 16)
        phoneNumberLabel.textColor = .gray
        phoneNumberLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}

class AddViewController: UIViewController {
    
    var contact: Contact?
    let profileImageView = UIImageView()
    let randomImageButton = UIButton()
    let nameTextView = UITextView()
    let phoneNumberTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = contact != nil ? contact!.name : "연락처 추가"
        view.backgroundColor = .white
        setupNavigationBar()
        setupUI()
        
        if let contact = contact {
            nameTextView.text = contact.name
            phoneNumberTextView.text = contact.phoneNumber
            if let imageData = contact.profileImage {
                profileImageView.image = UIImage(data: imageData)
            }
        }
        
        func configureView(with contact: Contact) {
            nameTextView.text = contact.name
            phoneNumberTextView.text = contact.phoneNumber
            if let imageData = contact.profileImage {
                profileImageView.image = UIImage(data: imageData)
            }
        }
        
        func setupNavigationBar() {
            let doneButton = UIBarButtonItem(title: "적용", style: .plain, target: self, action: #selector(doneButtonTapped))
            navigationItem.rightBarButtonItem = doneButton
        }
    }
        
        @objc func doneButtonTapped() {
            print("DEBUG: Done Button Tapped.")
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            
            
            if let contact = contact {
                contact.name = nameTextView.text
                contact.phoneNumber = phoneNumberTextView.text
                if let imageData = profileImageView.image?.pngData() {
                    contact.profileImage = imageData
                }
            } else {
                let newContact = Contact(context: context)
                newContact.name = nameTextView.text
                newContact.phoneNumber = phoneNumberTextView.text
                
                if let imageData = profileImageView.image?.pngData() {
                    newContact.profileImage = imageData
                }
            }
            do {
                try context.save()
                if let viewController = navigationController?.viewControllers.first(where: { $0 is ContactViewController }) as? ContactViewController {
                    viewController.fetchContacts()
                }
                navigationController?.popViewController(animated: true)
            } catch {
                print("DEBUG: Failed To Save Contact.")
            }
        }
        
        func setupUI() {
            
            profileImageView.layer.cornerRadius = 120
            profileImageView.clipsToBounds = true
            profileImageView.layer.borderWidth = 1
            profileImageView.layer.borderColor = UIColor.black.cgColor
            
            view.addSubview(profileImageView)
            
            profileImageView.snp.makeConstraints { make in
                make.width.height.equalTo(240)
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(100)
            }
            
            randomImageButton.setTitle("랜덤 이미지 생성", for: .normal)
            randomImageButton.setTitleColor(.gray, for: .normal)
            randomImageButton.addTarget(self, action: #selector(randomImageButtonTapped), for: .touchUpInside)
            
            view.addSubview(randomImageButton)
            
            randomImageButton.snp.makeConstraints { make in
                make.top.equalTo(profileImageView.snp.bottom).offset(16)
                make.centerX.equalToSuperview()
            }
            
            nameTextView.layer.borderWidth = 1
            nameTextView.layer.borderColor = UIColor.lightGray.cgColor
            nameTextView.layer.cornerRadius = 5
            
            view.addSubview(nameTextView)
            
            nameTextView.snp.makeConstraints { make in
                make.top.equalTo(randomImageButton.snp.bottom).offset(20)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(40)
            }
            
            phoneNumberTextView.layer.borderWidth = 1
            phoneNumberTextView.layer.borderColor = UIColor.lightGray.cgColor
            phoneNumberTextView.layer.cornerRadius = 5
            
            view.addSubview(phoneNumberTextView)
            
            phoneNumberTextView.snp.makeConstraints { make in
                make.top.equalTo(nameTextView.snp.bottom).offset(20)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.height.equalTo(40)
            }
        }
        
        @objc func randomImageButtonTapped() {
            print("DEBUG: Random Image Button Tapped.")
            let randomID = Int.random(in: 1...1000)
            let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(randomID)")!
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("DEBUG: \(String(describing: error)) Failed To Load.")
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let sprites = json["sprites"] as? [String: Any],
                       let imageUrlString = sprites["front_default"] as? String,
                       let imageUrl = URL(string: imageUrlString) {
                        DispatchQueue.main.async {
                            self.profileImageView.loadImage(from: imageUrl)
                        }
                    }
                } catch {
                    print("DEBUG: \(error) Error Occured.")
                }
            }
            task.resume()
        }
    }
    
    extension UIImageView {
        func loadImage(from url: URL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }.resume()
        }
    }
