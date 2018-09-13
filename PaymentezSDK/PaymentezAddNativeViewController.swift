//
//  PaymentezAddNativeViewController.swift
//  PaymentezSDK
//
//  Created by Gustavo Sotelo on 31/08/17.
//  Copyright © 2017 Paymentez. All rights reserved.
//

import UIKit


@objc public protocol PaymentezCardAddedDelegate
{
    func cardAdded(_ error:PaymentezSDKError?, _ cardAdded:PaymentezCard?)
    func viewClosed()
}




open class PaymentezAddNativeViewController: UIViewController {
    
    var baseColor = PaymentezStyle.baseBaseColor
    var baseFont = PaymentezStyle.font
    var bundle = Bundle(for: PaymentezCard.self)
    var titleString:String  = "Add Card".localized
    var showTuya = false
    let showLogo:Bool = true
    
    let buttonMessage = ["on":"Continue without code".localized, "off": "Continue with NIP".localized]
    @objc var showNip = true
    
    weak var paymentezCard:PaymentezCard? = PaymentezCard()
    
    var uid:String?
    var email:String?
    
    let mainView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fill

        stackView.backgroundColor = .red
        return stackView
    }()
    let nameView: UIStackView = {
        let stackView = UIStackView()
        //stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .red
        stackView.distribution = .fillEqually
        return stackView
    }()
    let cardNumberView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .red
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    let verificationView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.backgroundColor = .red
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    let tuyaView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = UILayoutConstraintAxis.vertical
        stackView.spacing = 10
        return stackView
    }()
    let otpNipView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = UILayoutConstraintAxis.horizontal
        return stackView
    }()
    
    
    let cardField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "Card Number".localized
        return field
    }()
    let cvcField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "CVC/CVV"
        return field
    }()
    let expirationField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "Expiration (MM/YY)".localized
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    let nameField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "Name of Cardholder".localized
        return field
    }()
    
    //TUYA Elements
    
    let documentField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "Document Identifier".localized
        return field
    }()
    
    let nipField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.placeholder = "NIP".localized
        field.keyboardType = .numberPad
        field.isSecureTextEntry = true
        return field
    }()
    
    let useSMSButton: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(PaymentezStyle.baseBaseColor, for: .normal) 
        btn.clipsToBounds = true
        btn.setTitle("Continue without code".localized, for: .normal)
        btn.titleLabel?.font = PaymentezStyle.fontSmall
        //btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let smsMessageField: UITextView = {
        let txtView = UITextView()
//        txtView.text = "Validate this operation using a temporal unique code that will be sent by SMS or E-email registered at Tuya.".localized
        txtView.isEditable = false
        txtView.isSelectable = false
        txtView.isScrollEnabled = false
        txtView.font = PaymentezStyle.fontExtraSmall
        txtView.textColor = PaymentezStyle.baseFontColor
        txtView.backgroundColor = PaymentezStyle.baseBaseColor
        return txtView
    }()
    
    private let paymentezLogo : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"logo_paymentez_black", in: Bundle(for: PaymentezCard.self), compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()
    
    let logoView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"stp_card_unknown", in: Bundle(for: PaymentezCard.self), compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()
    let cvcImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"stp_card_cvc", in: Bundle(for: PaymentezCard.self), compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let scanButton: UIButton = {
       let btn = UIButton()
        btn.setImage(UIImage(named:"ic_photo_camera", in: Bundle(for: PaymentezCard.self), compatibleWith: nil), for:.normal)
       btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let addButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = PaymentezStyle.baseBaseColor
        btn.tintColor = PaymentezStyle.baseFontColor
        btn.layer.cornerRadius = 5
        btn.clipsToBounds = true
        btn.setTitle("Add Card".localized, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
   
    
    
    @objc var isWidget:Bool = true
    
    @objc public var addDelegate:PaymentezCardAddedDelegate?
    
    
    var cardMaskedDelegate: MaskedTextFieldDelegate!
    var expirationMaskedDelegate: MaskedTextFieldDelegate!
    var cvcMaskedField: MaskedTextFieldDelegate!
    
    var cardMask:Mask = try! Mask(format: "[0000]-[0000]-[0000]-[0009]")
    var expirationMask:Mask = try! Mask(format: "[00]/[00]")
    var cvcMask:Mask = try! Mask(format: "[0009]")
    
    
    var cardType:PaymentezCardType =  PaymentezCardType.notSupported {
        didSet {
        
            DispatchQueue.main.async {
                // change card
                if self.cardType == .notSupported {
                    self.logoView.image = UIImage(named: "stp_card_unknown", in: self.bundle, compatibleWith: nil)
                    self.cvcImageView.image = UIImage(named: "stp_card_cvc", in: self.bundle, compatibleWith: nil)
                }
            }
           
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    @objc public init(isWidget:Bool)
    {
        super.init(nibName: nil, bundle: nil)
        self.isWidget = isWidget
        setupViews()
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: View Setup Methods
    private func setupViews(){
        setupColor()
        setupMask()
        setupAddPresentation()
        setupViewLayouts()
    }
    
    private func setupColor(){
        self.view.backgroundColor = .white
        //SETUP COLOR
        cardField.selectedLineColor = baseColor
        nameField.selectedLineColor = baseColor
        expirationField.selectedLineColor = baseColor
        cvcField.selectedLineColor = baseColor
        documentField.selectedLineColor = baseColor
        documentField.selectedTitleColor = baseColor
        nipField.selectedLineColor = baseColor
        nipField.selectedTitleColor = baseColor
        cardField.selectedTitleColor = baseColor
        nameField.selectedTitleColor = baseColor
        expirationField.selectedTitleColor = baseColor
        cvcField.selectedTitleColor = baseColor
    }
    
    private func setupMask(){
        //SETUP MASK
        self.cardMaskedDelegate = MaskedTextFieldDelegate(format: "[0000]-[0000]-[0000]-[0009]")
        self.cardMaskedDelegate.listener = self
        self.cardField.delegate = cardMaskedDelegate
        
        self.expirationMaskedDelegate = MaskedTextFieldDelegate(format: "[00]/[00]")
        self.expirationMaskedDelegate.listener = self
        self.expirationField.delegate = expirationMaskedDelegate
        
        self.cvcMaskedField = MaskedTextFieldDelegate(format: "[0000]")
        self.cvcMaskedField.listener = self
        self.cvcField.delegate = cvcMaskedField
        self.nipField.delegate = cvcMaskedField
        
        
        
        
        
        
    }
    
    private func setupAddPresentation(){
        if self.isWidget{
            self.addButton.isHidden = true
            
        }else{
            //CONFIGURE ADDBUTTON
            self.title = self.titleString
            self.addButton.isHidden = false
            self.addButton.addTarget(self, action: #selector(self.addCard(_:)), for: .touchUpInside)
            self.view.addSubview(self.addButton)
            
            self.addButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
            self.addButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            self.addButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
            self.addButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
            
            // Create close button
            let barBtn = UIBarButtonItem(image: UIImage(named:"icon_close", in: self.bundle, compatibleWith: nil), style: .plain, target: self, action: #selector(close(_:)))
            barBtn.tintColor = PaymentezStyle.baseFontColor
            self.navigationItem.rightBarButtonItem = barBtn
            
            
        }
    }
    private func setupViewLayouts(){
        //SETUP nameView
        self.nameView.addArrangedSubview(self.nameField)
        
        //SETUP cardNumberView
        
        self.scanButton.addTarget(self, action: #selector(self.scanCard(_:)), for: .touchUpInside)
        self.cardNumberView.addArrangedSubview(self.logoView)
        self.cardNumberView.addArrangedSubview(self.cardField)
        self.cardNumberView.addArrangedSubview(self.scanButton)
        
        self.logoView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        //self.logoView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        self.scanButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        //SETUP VERIFICATIONVIEW
        
        self.verificationView.addArrangedSubview(self.expirationField)
        self.verificationView.addArrangedSubview(self.cvcImageView)
        self.verificationView.addArrangedSubview(self.cvcField)
        self.expirationField.widthAnchor.constraint(equalTo: self.verificationView.widthAnchor, multiplier: 0.5).isActive = true
        self.cvcImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        //SETUP TUYA VIEW
        
        self.useSMSButton.addTarget(self, action: #selector(dismissNip(_:)), for: .touchUpInside)
        self.otpNipView.addArrangedSubview(self.nipField)
        self.otpNipView.addArrangedSubview(self.useSMSButton)
        
        
        self.tuyaView.addArrangedSubview(self.documentField)
        self.tuyaView.addArrangedSubview(self.otpNipView)
        
        // ADD SUBVIEWS
        self.mainView.addArrangedSubview(self.nameView)
        self.mainView.addArrangedSubview(self.cardNumberView)
        self.mainView.addArrangedSubview(self.verificationView)
        if showLogo{
            self.mainView.addArrangedSubview(self.paymentezLogo)
        }
        self.view.addSubview(self.mainView)
        
        //SETUP MAIN VIEW
        if isWidget {
            self.mainView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10).isActive = true
            // self.mainView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
        } else{
            //self.mainView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        }
        
        if #available(iOS 11.0, *) {
            self.mainView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        } else {
            self.mainView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        }
        self.mainView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        self.mainView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10).isActive = true
    }
    
    private func toggleTuya(show:Bool){
        
        if !show && self.showTuya == true{
            // dismiss
            self.showTuya = false
            self.tuyaView.isHidden = true
            self.mainView.insertArrangedSubview(self.verificationView, at: 2)
            self.tuyaView.removeFromSuperview()
            self.verificationView.isHidden = false
        } else if show && self.showTuya == false {
            // show
            //
            self.tuyaView.isHidden = false
            self.verificationView.isHidden = true
            self.mainView.insertArrangedSubview(self.tuyaView, at: 2)
            //self.verificationView.removeFromSuperview()
            self.showTuya = true
        }
    }
    
    
    @objc func dismissNip(_ sender:Any){
        toggleNip(show: false)
    }
    
    @objc func showNip(_ sender:Any){
        toggleNip(show: true)
    }
    
    
    private func toggleNip(show:Bool){
        if !show && self.showNip == true{
            // dismiss
            self.nipField.isHidden = true
            self.useSMSButton.setTitle(buttonMessage["off"], for: .normal)
            //self.nipField.removeFromSuperview()
            self.showNip = false
            self.tuyaView.addArrangedSubview(self.smsMessageField)
            self.useSMSButton.removeTarget(self, action: #selector(dismissNip(_:)), for: .touchUpInside)
            self.useSMSButton.addTarget(self, action: #selector(showNip(_:)), for: .touchUpInside)
        } else if show && self.showNip == false {
            // show
            //
            self.useSMSButton.setTitle(buttonMessage["on"], for: .normal)
            self.smsMessageField.removeFromSuperview()
            self.nipField.isHidden = false
            self.otpNipView.insertArrangedSubview(self.nipField, at: 0)
            self.showNip = true
            self.useSMSButton.removeTarget(self, action: #selector(showNip(_:)), for: .touchUpInside)
            self.useSMSButton.addTarget(self, action: #selector(dismissNip(_:)), for: .touchUpInside)
        }
    }
    

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Card Validation Methods
    
     @objc open func getValidCard()->PaymentezCard?
    {
        
        
        if self.cardType == .notSupported{
            return nil
        }
        
        if self.cardType == .alkosto || self.cardType == .exito  //tarjetas tuya
        {
            guard let _ = self.cvcField.text else {
                return nil
            }
            guard let _ = self.paymentezCard?.fiscalNumber else {
                return nil
            }
            
            return self.paymentezCard
            
        }else { // las demás
            guard let _ = self.cvcField.text else {
                return nil
            }
            guard let _ = self.paymentezCard?.cardHolder else {
                return nil
            }
            guard let _ = self.paymentezCard?.cardNumber else {
                return nil
            }
            guard let _ = self.paymentezCard?.expiryMonth else {
                return nil
            }
            guard let _ = self.paymentezCard?.expiryYear else {
                return nil
            }
           return self.paymentezCard
        }
    }
    
    //MARK:Scan Card
    
    @objc func scanCard(_ sender: Any) {
        PaymentezSDKClient.scanCard(self) { (closed, number, expiry, cvv, card) in
            if !closed
            {
                let result: Mask.Result = self.cardMask.apply(
                    toText: CaretString(
                        string: number!,
                        caretPosition: number!.endIndex
                    ),
                    autocomplete: false // you may consider disabling autocompletion for your case
                )
                let resultEx: Mask.Result = self.expirationMask.apply(
                    toText: CaretString(
                        string: expiry!,
                        caretPosition: expiry!.endIndex
                    ),
                    autocomplete: false // you may consider disabling autocompletion for your case
                )
                let resultCvv: Mask.Result = self.cvcMask.apply(
                    toText: CaretString(
                        string: cvv!,
                        caretPosition: cvv!.endIndex
                    ),
                    autocomplete: false // you may consider disabling autocompletion for your case
                )
                self.cardField.text = result.formattedText.string
                
                self.expirationField.text = resultEx.formattedText.string
                self.cvcField.text = resultCvv.formattedText.string
                self.paymentezCard?.cvc = self.cvcField.text
                
                self.paymentezCard?.cardNumber = self.cardField.text?.replacingOccurrences(of: "-", with: "")
                self.cardType = PaymentezCard.getTypeCard((self.paymentezCard?.cardNumber)!)
                let valExp = self.expirationField.text!.components(separatedBy: "/")
                if valExp.count > 1
                {
                    let expiryYear = Int(valExp[1])! + 2000
                    let expiryMonth = valExp[0]
                    self.paymentezCard?.expiryYear =  "\(expiryYear)"
                    self.paymentezCard?.expiryMonth =  expiryMonth
                }
            }
        }
    }
    
    //MARK: Actions
    
    @objc func close(_ sender:Any){
        self.dismiss(animated: true) {
            self.addDelegate?.viewClosed()
        }
    }
    
    @objc func addCard(_ sender: Any) {
        
        if !isWidget
        {
            guard let uid  = self.uid else {
                return
            }
            guard let email = self.email else {
                return
            }
            if let validCard = self.getValidCard() {
                PaymentezSDKClient.add(validCard, uid: uid, email: email, callback: { (error, cardAdded) in
                    
                    self.addDelegate?.cardAdded(error, cardAdded)
                })
            }
        }
    }
    func loadImageFromUrl(urlString:String){
        guard let url = URL(string: urlString) else{
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error ==  nil {
                if let imageData = data{
                    DispatchQueue.main.async {
                        
                        self.logoView.image = UIImage(data: imageData)
                    }
                }
            }
            }.resume()
    }
}


extension PaymentezAddNativeViewController: MaskedTextFieldDelegateListener
{
    public func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        
        if textField == self.cardField
        {
//            if self.cardField.text?.count ?? 0 > 5 {
//                self.toggleTuya(show:true)
//            } else{
//                self.toggleTuya(show:false)
//            }
            self.cardField.errorMessage = ""
            //self.cardType = PaymentezCard.getTypeCard(value)
            self.paymentezCard?.cardNumber = self.cardField.text?.replacingOccurrences(of: "-", with: "")
            if self.cardField.text?.count ?? 0 > 6 {
                PaymentezCard.validate(cardNumber: (self.cardField.text?.replacingOccurrences(of: "-", with: ""))!) { (cardType, imageUrl, cvvLength, mask) in
                    
                   
                    DispatchQueue.main.async {
                        self.cardType = cardType
                        if let img = imageUrl{
                            self.loadImageFromUrl(urlString: img)
                        }
                        
                        if cardType == .alkosto || cardType == .exito {
                            
                            self.toggleTuya(show:true)
                        }else {
                            self.toggleTuya(show:false)
                        }
                    }
                }
            } else {
                self.cardType = .notSupported
            }
            
            
        }
        if textField == self.expirationField
        {
            self.expirationField.errorMessage = ""
            if complete
            {
                if PaymentezCard.validateExpDate(self.expirationField.text!)
                {
                    let valExp = self.expirationField.text!.components(separatedBy: "/")
                    if valExp.count > 1
                    {
                        let expiryYear = Int(valExp[1])! + 2000
                        
                        self.paymentezCard?.expiryYear =  "\(expiryYear)"
                        self.paymentezCard?.expiryMonth = valExp[0]
                    }
                }
                else
                {
                    self.paymentezCard?.expiryYear = nil
                    self.paymentezCard?.expiryMonth = nil
                    self.expirationField.errorMessage = "Invalid Date".localized
                }
                
            }
            
        }
        if textField == self.cvcField
        {
            self.cvcField.errorMessage = ""
            if complete
            {
                if (value.count != 3 && self.cardType != .amex) || (value.count != 4 && self.cardType == .amex)
                {
                    self.cvcField.errorMessage = "Invalid".localized
                    self.paymentezCard?.cvc = nil
                }
                else
                {
                    self.paymentezCard?.cvc = value
                }
            }
        }
        if textField == self.documentField{
            self.paymentezCard?.fiscalNumber = self.documentField.text
        }
        if textField == self.nipField {
            self.nipField.errorMessage = ""
            if value.count != 4{
                self.nipField.errorMessage = "Invalid".localized
            } else {
                self.paymentezCard?.nip  = self.nipField.text
            }
            
        }
        
    }
}

public extension UIViewController {
    
    func addPaymentezWidget(toView containerView:UIView,  delegate:PaymentezCardAddedDelegate?, uid:String, email:String){
        let paymentezAddVC = PaymentezSDKClient.createAddWidget()
        paymentezAddVC.uid = uid
        paymentezAddVC.email = email
        paymentezAddVC.addDelegate = delegate
        self.addChildViewController(paymentezAddVC)
        let paymentezView = paymentezAddVC.view
        paymentezView?.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(paymentezView!)
        paymentezView?.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        paymentezView?.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        paymentezView?.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        paymentezView?.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        paymentezAddVC.didMove(toParentViewController: self)
    }
    func presentPaymentezViewController(delegate:PaymentezCardAddedDelegate, uid:String, email:String){
        let paymentezAddVC = PaymentezAddNativeViewController(isWidget: false)
        paymentezAddVC.addDelegate = delegate
        paymentezAddVC.uid = uid
        paymentezAddVC.email = email
        let navigationViewController = UINavigationController(rootViewController: paymentezAddVC)
        navigationViewController.navigationBar.barTintColor = PaymentezStyle.baseBaseColor
        navigationViewController.navigationBar.isTranslucent = false
        self.present(navigationViewController, animated: true) {
            
        }
    }
    
}

public extension UINavigationController {
    func pushPaymentezViewController(delegate:PaymentezCardAddedDelegate, uid:String, email:String){
        let paymentezAddVC = PaymentezAddNativeViewController(isWidget: false)
        paymentezAddVC.uid = uid
        paymentezAddVC.email = email
        paymentezAddVC.addDelegate = delegate
        self.pushViewController(paymentezAddVC, animated: true)
    }
}

