import ArgumentParser
import Bluray

struct MainPlaylist: ParsableCommand {
  @Argument
  var path: String

  func run() throws {
    let bd = try Bluray.open(devicePath: path)
    _ = bd.getTitles(flags: .all, minTitleLength: 0)

    let mainTitle = try bd.getMainTitleIndex()

    let info = try bd.getTitleInfo(titleIndex: numericCast(mainTitle), angle: 0)
    print(info.playlist)
  }
}
