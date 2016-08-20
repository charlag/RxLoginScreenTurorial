//
//  ViewController.swift
//  RxLoginScreen
//
//  Created by Ivan Kupalov on 14/08/16.
//  Copyright © 2016 Charlag. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum AuthCellType: String {
  case Headline
  case EmailTextField
  case NameTextField
  case PasswordTextField
  case LoginButton
  case Separator
}

extension AuthCellType: IdentifiableType {
  var identity: String { return rawValue }
}

enum LoginScreenState {
  case ShowLogIn
  case ShowSignUp
  
  var buttonTitle: String {
    switch self {
    case .ShowLogIn:
      return "Don't have an account?"
    case .ShowSignUp:
      return "Already have an account?"
    }
  }
  
  var cells: [AuthCellType] {
    switch self {
    case .ShowLogIn:
      return [
        .Headline,
        .Separator,
        .EmailTextField,
        .PasswordTextField,
        .LoginButton
      ]
    case .ShowSignUp:
      return [
        .EmailTextField,
        .NameTextField,
        .PasswordTextField,
        .LoginButton
      ]
    }
  }
}

typealias AuthSection = AnimatableSectionModel<Int, AuthCellType>

class ViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  let footerButton = UIButton()
  
  let screenState = Variable(LoginScreenState.ShowLogIn)
  
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.estimatedRowHeight = 44
    tableView.rowHeight = UITableViewAutomaticDimension
    
    screenState.asObservable()
      .map { $0.buttonTitle }
      .bindTo(footerButton.rx_title(.Normal))
      .addDisposableTo(disposeBag)
    
    footerButton.rx_tap
      .asObservable()
      .withLatestFrom(screenState.asObservable())
      .map { state -> LoginScreenState in
        switch state {
        case .ShowLogIn:
          return .ShowSignUp
        case .ShowSignUp:
          return .ShowLogIn
        }
      }
      .bindTo(screenState)
      .addDisposableTo(disposeBag)
    
    footerButton.setTitleColor(.blueColor(), forState: .Normal)
    footerButton.titleLabel?.font = UIFont.systemFontOfSize(13)
    footerButton.frame = CGRectMake(0, 0, 40, 20)
    tableView.tableFooterView = footerButton
    
    let dataSource = RxTableViewSectionedAnimatedDataSource<AuthSection>()
    dataSource.configureCell = { _, tableView, indexPath, item in
      let cell = tableView.dequeueReusableCellWithIdentifier(item.rawValue, forIndexPath: indexPath)
      return cell
    }
    
    dataSource.animationConfiguration = AnimationConfiguration(insertAnimation: .Fade,
                                                               reloadAnimation: .Fade,
                                                               deleteAnimation: .Fade)
    
    screenState.asObservable()
      .map { $0.cells }
      .map { [AuthSection(model: 0, items: $0)] }
      .bindTo(tableView.rx_itemsWithDataSource(dataSource))
      .addDisposableTo(disposeBag)
  }
}

