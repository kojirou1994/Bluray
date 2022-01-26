import CBluray
import Precondition

public final class Bluray {
  internal init() throws {
    self.bd = try bd_init().unwrap(BlurayError.bd_init)
  }

  let bd: OpaquePointer

  deinit {
    bd_close(bd)
  }

}

public extension Bluray {
  static func open(devicePath: String, keyfilePath: String? = nil) throws -> Bluray {
    let bd = try Bluray()
    try preconditionOrThrow(bd_open_disc(bd.bd, devicePath, keyfilePath) == 1,
                            BlurayError.bd_open)
    return bd
  }
}

public enum BlurayError: Error {
  case bd_init
  case bd_open
  case bd_get_title_info
  case bd_get_main_title
}

extension Bluray {
  public struct TitleFlags: OptionSet {
    public init(rawValue: UInt8) {
      self.rawValue = rawValue
    }

    public var rawValue: UInt8
  }
  public struct Chapter {
    private let chapter: bd_chapter
  }

  public struct ClipInfo {
    private let clip: bd_clip
  }

  public struct TitleMark {
    private let clip: bd_mark
  }
}

public extension Bluray.TitleFlags {
  /// all titles.
  @_alwaysEmitIntoClient
  static var all: Self { .init(rawValue: numericCast(TITLES_ALL)) }

  /// remove duplicate titles.
  @_alwaysEmitIntoClient
  static var noDuplicateTitles: Self { .init(rawValue: numericCast(TITLES_FILTER_DUP_TITLE)) }

  /// remove titles that have duplicate clips.
  @_alwaysEmitIntoClient
  static var noDuplicateClips: Self { .init(rawValue: numericCast(TITLES_FILTER_DUP_CLIP)) }

  /// remove duplicate titles and clips
  @_alwaysEmitIntoClient
  static var relevant: Self { .init(rawValue: numericCast(TITLES_RELEVANT)) }
}

public extension Bluray {
  func getTitles(flags: TitleFlags, minTitleLength: UInt32) -> UInt32 {
    bd_get_titles(bd, flags.rawValue, minTitleLength)
  }

  func getTitleInfo(titleIndex: UInt32, angle: UInt32) throws -> TitleInfo {
    try .init(info: bd_get_title_info(bd, titleIndex, angle).unwrap(BlurayError.bd_get_title_info))
  }

  func getMainTitleIndex() throws -> Int32 {
    let v = bd_get_main_title(bd)
    if v == -1 {
      throw BlurayError.bd_get_main_title
    }
    return v
  }
}

public final class TitleInfo {
  internal init(info: UnsafeMutablePointer<BLURAY_TITLE_INFO>) {
    self.info = info
  }

  let info: UnsafeMutablePointer<BLURAY_TITLE_INFO>

  deinit {
    bd_free_title_info(info)
  }

}

public extension TitleInfo {
  var index: UInt32 { info.pointee.idx }

  var playlist: UInt32 { info.pointee.playlist }

  var duration: UInt64 { info.pointee.duration }

  var angleCount: UInt8 { info.pointee.angle_count }

  var clips: UnsafeMutableBufferPointer<Bluray.ClipInfo> {
    .init(start: .init(OpaquePointer(info.pointee.clips)), count: Int(info.pointee.clip_count))
  }

  var chapters: UnsafeMutableBufferPointer<Bluray.Chapter> {
    .init(start: .init(OpaquePointer(info.pointee.chapters)), count: Int(info.pointee.chapter_count))
  }

  var marks: UnsafeMutableBufferPointer<Bluray.TitleMark> {
    .init(start: .init(OpaquePointer(info.pointee.marks)), count: Int(info.pointee.mark_count))
  }

  var mvc_base_view_r_flag: UInt8 {
    info.pointee.mvc_base_view_r_flag
  }

}
