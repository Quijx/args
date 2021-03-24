// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../command_runner.dart';

/// The built-in help command that's added to every [CommandRunner].
///
/// This command displays help information for the various subcommands.
class HelpCommand<T> extends Command<T> {
  @override
  final name = 'help';

  @override
  String get description {
    final executableName = runner!.executableName;
    if (executableName.isEmpty) {
      return 'Display help information.';
    }
    return 'Display help information for $executableName.';
  }

  @override
  String get invocation {
    final executableName = runner!.executableName;
    if (executableName.isEmpty) {
      return 'help [command]';
    }
    return '$executableName help [command]';
  }

  @override
  bool get hidden => true;

  @override
  Null run() {
    // Show the default help if no command was specified.
    if (argResults!.rest.isEmpty) {
      runner!.printUsage();
      return;
    }

    // Walk the command tree to show help for the selected command or
    // subcommand.
    var commands = runner!.commands;
    Command? command;
    var commandString = runner!.executableName;

    for (var name in argResults!.rest) {
      if (commands.isEmpty) {
        command!.usageException(
            'Command "$commandString" does not expect a subcommand.');
      }

      if (commands[name] == null) {
        if (command == null) {
          runner!.usageException('Could not find a command named "$name".');
        }

        command.usageException(
            'Could not find a subcommand named "$name" for "$commandString".');
      }

      command = commands[name];
      commands = command!.subcommands as Map<String, Command<T>>;
      if (commandString.isEmpty) {
        commandString = name;
      } else {
        commandString += ' $name';
      }
    }

    command!.printUsage();
  }
}
