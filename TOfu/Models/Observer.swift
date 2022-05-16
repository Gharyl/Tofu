class Observer<T> {
  var object: T {
    didSet {
      // Notify subscribers
      if !subscribers.isEmpty {
        subscribers.forEach{$0(object)}
      }
    }
  }
  
  private var subscribers: [((T) -> Void)] = []
  
  func observe(_ callback: @escaping (T) -> Void ) {
    subscribers.append(callback)
  }
  
  func pop() {
    subscribers.removeLast()
  }
  
  init(_ object: T) {
    self.object = object
  }
}
