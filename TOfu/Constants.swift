import UIKit

struct K {
  static let testUsers = [
    Profile(username: "123", firstName: "test1233", lastName: "Joe"),
    Profile(username: "456", firstName: "test44444", lastName: "Jane"),
    Profile(username: "786", firstName: "test873847", lastName: "Cam")
  ]
  
  static let testMessasges = [
    ChatMessage(messageBody:"hey there? So i wanted ask you about last night. Where did you guys go with Sam?",
                messageSender: testUsers[0].id!, date: Date()),
    ChatMessage(messageBody: "yeah?",
                messageSender: testUsers[1].id!, date: Date()),
    ChatMessage(messageBody: "Oh we just wwent to Chile's",
                messageSender: testUsers[1].id!, date: Date()),
  ]
  
  static let testRequests =  [
    FriendRequest(
      toUser: Friend(id: "12334", firstName: "Test1", lastName: "last1", username: "testing1"),
      fromUser: Friend(id: "43321", firstName: "1tesT", lastName: "1last", username: "1gnitset")),
    
    FriendRequest(
      toUser: Friend(id: "123345", firstName: "Test2", lastName: "last2", username: "testing2"),
      fromUser: Friend(id: "43321", firstName: "1tesT", lastName: "1last", username: "1gnitset")),
      
    FriendRequest(
      toUser: Friend(id: "1233456", firstName: "Test3", lastName: "last3", username: "testing3"),
      fromUser: Friend(id: "43321", firstName: "1tesT", lastName: "1last", username: "1gnitset")),
  ]
  
  static let testChats = [
    Chat(participants: [Friend(profile: testUsers[0]), Friend(profile: testUsers[1])], messages: testMessasges)
  ]
  
  static let imageDefaultName: String = "person.circle.fill"
  static let chatCellIdentifier: String = "ChatListCell"
  static let cellHeight: CGFloat = 80
  static let textFieldHeight: CGFloat = 35
  static let contactCellHeight: CGFloat = 50
  static let themeFont = "MontserratRoman-Medium"
  static let headerHeight: CGFloat = 20
  static let slideOffset: CGFloat = UIScreen.main.bounds.width * 0.7
  static let maxImageSize: Float = 10 * 1024 * 1024
  
  struct Screen {
    static let width: CGFloat = UIScreen.main.bounds.width
    static let height: CGFloat = UIScreen.main.bounds.height
  }
  
  static let gradientButtonColor1 =  [
    #colorLiteral(red: 0.8117647059, green: 0.768627451, blue: 0.7098039216, alpha: 1).cgColor,
    #colorLiteral(red: 0.9058823529, green: 0.8823529412, blue: 0.8549019608, alpha: 1).cgColor,
    #colorLiteral(red: 0.968627451, green: 0.9607843137, blue: 0.9529411765, alpha: 1).cgColor,
    #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
  ]
  
  static let sectionHeaderGradient = [
    #colorLiteral(red: 0.9647058824, green: 0.9411764706, blue: 0.9215686275, alpha: 1).cgColor,
    #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
  ]
  
  struct colorTheme {
    static let yellow = UIColor(red: 245/255, green: 210/255, blue: 104/255, alpha: 1)
    static let beige = UIColor(red: 175/255, green: 158/255, blue: 132/255, alpha: 1)
    static let beige2 = UIColor(red: 180/255, green: 126/255, blue: 85/255, alpha: 1)
    static let beigeL = UIColor(red: 233/255, green: 217/255, blue: 205/255, alpha: 1)
    static let beigeD = #colorLiteral(red: 0.4352941176, green: 0.3764705882, blue: 0.2862745098, alpha: 1)
    static let black = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    static let purple = UIColor(red: 68/255, green: 43/255, blue: 72/255, alpha: 1)
    static let green = UIColor(red: 25/255, green: 83/255, blue: 92/255, alpha: 1)
    static let blue = #colorLiteral(red: 0.6653570533, green: 0.7135717273, blue: 0.7329399586, alpha: 1)
    static let gray = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
    static let grayL = #colorLiteral(red: 0.9647058824, green: 0.9411764706, blue: 0.9215686275, alpha: 1)
    static let burg = #colorLiteral(red: 0.3964335024, green: 0.2984021306, blue: 0.3116580546, alpha: 1)
  }
  
  struct colorTheme2 {
    static let blue = #colorLiteral(red: 0.0431372549, green: 0.2862745098, blue: 0.5176470588, alpha: 1)
    static let gray1 = #colorLiteral(red: 0.9176470588, green: 0.9137254902, blue: 0.9411764706, alpha: 1)
    static let gray2 = #colorLiteral(red: 0.6980392157, green: 0.7215686275, blue: 0.7764705882, alpha: 1)
    static let gray3 = #colorLiteral(red: 0.4941176471, green: 0.5333333333, blue: 0.6274509804, alpha: 1)
    static let blue2 = #colorLiteral(red: 0.431372549, green: 0.6431372549, blue: 0.7490196078, alpha: 1)
    static let beige = #colorLiteral(red: 0.9529411765, green: 0.8470588235, blue: 0.7803921569, alpha: 1)
    static let hotpink = #colorLiteral(red: 0.9764705882, green: 0.3843137255, blue: 0.4901960784, alpha: 1)
    static let purple = #colorLiteral(red: 0.5960784314, green: 0.5764705882, blue: 0.8549019608, alpha: 1)
    static let yellow = #colorLiteral(red: 0.9647058824, green: 0.6823529412, blue: 0.1764705882, alpha: 1)
    static let redOrange = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
  }
}
