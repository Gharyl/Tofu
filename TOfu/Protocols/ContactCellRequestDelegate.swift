protocol ContactCellRequestDelegate: AnyObject {
  func requestResponded(response: Bool, cell: ContactCell)
}
