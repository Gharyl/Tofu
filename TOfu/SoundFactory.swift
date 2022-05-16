import AVFoundation

enum SoundFactory {
  static func supplySound() {
    let path = Bundle.main.path(forResource: "pop1", ofType: "wav")!
    let url = URL(fileURLWithPath: path)
    
    do {
      let audio = try AVAudioPlayer(contentsOf: url)
      audio.play()
    } catch {
      print("AUdio error")
    }
  }
}
