import ArgumentParser

@main
struct BDUtility: ParsableCommand {
  static var configuration: CommandConfiguration {
    .init(
      subcommands:[
        MainPlaylist.self,
      ]
    )
  }
}
