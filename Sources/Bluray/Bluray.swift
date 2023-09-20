import CBluray
import Precondition

public struct Bluray: ~Copyable {
  @usableFromInline
  internal init() throws {
    self.bd = try bd_init().unwrap(BlurayError.bd_init)
  }

  @usableFromInline
  internal let bd: OpaquePointer

  @inlinable
  deinit {
    bd_close(bd)
  }

}

public extension Bluray {
  @_alwaysEmitIntoClient
  @inlinable
  static func open(devicePath: UnsafePointer<Int8>, keyfilePath: UnsafePointer<Int8>? = nil) throws -> Bluray {
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
  case bd_select_playlist
  case bd_get_disc_info
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

  @_alwaysEmitIntoClient
  func getTitles(flags: TitleFlags, minTitleLength: UInt32) -> UInt32 {
    bd_get_titles(bd, flags.rawValue, minTitleLength)
  }

  @_alwaysEmitIntoClient
  func getTitleInfo(titleIndex: UInt32, angle: UInt32) throws -> TitleInfo {
    try .init(info: bd_get_title_info(bd, titleIndex, angle).unwrap(BlurayError.bd_get_title_info))
  }

  @_alwaysEmitIntoClient
  func getDiscInfo() throws {
    try bd_get_disc_info(bd).unwrap(BlurayError.bd_get_disc_info)
  }

  @_alwaysEmitIntoClient
  func getMainTitleIndex() throws -> Int32 {
    let v = bd_get_main_title(bd)
    if v == -1 {
      throw BlurayError.bd_get_main_title
    }
    return v
  }

  @_alwaysEmitIntoClient
  func select(playlist: UInt32) throws {
    try preconditionOrThrow(
      bd_select_playlist(bd, playlist) == 1,
      BlurayError.bd_select_playlist
    )
  }

  @_alwaysEmitIntoClient
  func select(angle: UInt32) throws {
    try preconditionOrThrow(
      bd_select_angle(bd, angle) == 1,
      BlurayError.bd_select_playlist
    )
  }

  @_alwaysEmitIntoClient
  func seek(chapter: UInt32) -> Int64 {
    bd_seek_chapter(bd, chapter)
  }

  @_alwaysEmitIntoClient
  func read(into buffer: UnsafeMutableBufferPointer<UInt8>) throws -> Int32 {
    bd_read(bd, buffer.baseAddress, numericCast(buffer.count))
  }
}

public struct TitleInfo: ~Copyable {
  @usableFromInline
  internal init(info: UnsafeMutablePointer<BLURAY_TITLE_INFO>) {
    self.info = info
  }

  @usableFromInline
  internal let info: UnsafeMutablePointer<BLURAY_TITLE_INFO>

  @inlinable
  deinit {
    bd_free_title_info(info)
  }

}

public extension TitleInfo {

  @_alwaysEmitIntoClient
  var index: UInt32 { info.pointee.idx }

  @_alwaysEmitIntoClient
  var playlist: UInt32 { info.pointee.playlist }

  @_alwaysEmitIntoClient
  var duration: UInt64 { info.pointee.duration }

  @_alwaysEmitIntoClient
  var angleCount: UInt8 { info.pointee.angle_count }

  @_alwaysEmitIntoClient
  var clips: UnsafeMutableBufferPointer<Bluray.ClipInfo> {
    .init(start: .init(OpaquePointer(info.pointee.clips)), count: Int(info.pointee.clip_count))
  }

  @_alwaysEmitIntoClient
  var chapters: UnsafeMutableBufferPointer<Bluray.Chapter> {
    .init(start: .init(OpaquePointer(info.pointee.chapters)), count: Int(info.pointee.chapter_count))
  }

  @_alwaysEmitIntoClient
  var marks: UnsafeMutableBufferPointer<Bluray.TitleMark> {
    .init(start: .init(OpaquePointer(info.pointee.marks)), count: Int(info.pointee.mark_count))
  }

  @_alwaysEmitIntoClient
  var mvc_base_view_r_flag: UInt8 {
    info.pointee.mvc_base_view_r_flag
  }

}
