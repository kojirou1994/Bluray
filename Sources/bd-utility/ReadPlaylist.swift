import ArgumentParser
import Bluray
import System
import CBluray
import Foundation

struct ReadPlaylist: ParsableCommand {

  @Option
  var playlist: UInt32

  @Option
  var output: String

  @Argument
  var path: String

  func run() throws {
    let bd = try Bluray.open(devicePath: path)
    print("opened")
    _ = bd.getTitles(flags: .all, minTitleLength: 0)
    print("get titles")
    try bd.select(playlist: playlist)
    print("selected playlist")
    try bd.getDiscInfo()

    if #available(macOS 11.0, *) {
      let fd = try FileDescriptor.open(output, .writeOnly, options: [.create, .truncate], permissions: [.ownerReadWrite])
      let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 10 * 4096)
      try fd.closeAfter {
        while case let count = try bd.read(into: buffer),
              count > 0 {
          try fd.writeAll(buffer.prefix(Int(count)))
        }
      }
    } else {
      throw ValidationError("requires macOS 11.0")
    }
    
  }
}
