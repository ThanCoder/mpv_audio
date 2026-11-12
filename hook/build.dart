import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:mpv_audio/core/archive_lib.dart';
import 'package:mpv_audio/core/keys.dart';
import 'package:mpv_audio/core/utils.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final packageRootDir = input.packageRoot.toFilePath();
    final nativeAssets = p.join(packageRootDir, '.dart_tool', 'native_assets');

    // final archiveLib = LibArchiveConfig.create(input.config.code);

    // await extractLib(archiveLib, nativeAssets: nativeAssets);

    // for (var lib in archiveLib.libs) {
    //   final f = File(
    //     p.join(nativeAssets, archiveLib.platform, archiveLib.arch, lib.libName),
    //   );

    //   if (!f.existsSync()) continue;

    //   output.assets.code.add(
    //     .new(
    //       package: packageName,
    //       name: lib.libName,
    //       linkMode: DynamicLoadingBundled(),
    //       file: f.uri,
    //     ),
    //   );
    // }
  });
}

Future<void> extractLib(
  LibArchiveConfig config, {
  required String nativeAssets,
}) async {
  final outDir = Directory(p.join(nativeAssets, config.platform, config.arch));
  if (!outDir.existsSync()) {
    await outDir.create(recursive: true);
  }

  final libFiles = config.libs
      .map((lib) => File(p.join(outDir.path, lib.libName)))
      .toList();
  if (libFiles.any((e) => e.existsSync())) return;
  final libZipFile = File(
    //libmpv_audio-linux-x64.zip
    p.join(nativeAssets, 'libmpv_audio-${config.platform}-${config.arch}.zip'),
  );
  if (libZipFile.existsSync()) {
    await extractZip(libZipFile, outDir: outDir, libs: config.libs);
    return;
  }
  // libZipFile.writeAsStringSync('contents');

  // download
  await downloadLib(config.downloadUrl, libZipFile);
  await extractZip(libZipFile, outDir: outDir, libs: config.libs);
}

class LibArchiveConfig {
  const LibArchiveConfig({
    required this.config,
    required this.platform,
    required this.arch,
    required this.libs,
    required this.downloadUrl,
  });

  final CodeConfig config;
  final String downloadUrl;
  final List<ArchiveLib> libs;
  final String platform;
  final String arch;

  factory LibArchiveConfig.create(CodeConfig cf) {
    final targetOS = cf.targetOS;
    final targetArch = cf.targetArchitecture;

    if (cf.targetOS == .linux) {
      return .new(
        config: cf,
        libs: [.new(archivePath: 'libmpv_audio.so', libName: mpvLibName)],
        platform: targetOS.name,
        arch: 'x64',
        downloadUrl: linuxLibUrl,
      );
    }
    // if (cf.targetOS == .windows) {
    //   return .new(
    //     config: cf,
    //     libs: [.new(archivePath: 'libmpv_audio.so', libName: mpvLibName)],
    //     platform: targetOS.name,
    //     arch: 'x64',
    //     downloadUrl: windowLibUrl,
    //   );
    // }
    // if (targetOS == .android) {
    //   final downloadUrl = switch (targetArch) {
    //     .arm => androidArmLibUrl,
    //     .arm64 => androidArm64LibUrl,
    //     _ => UnsupportedError('error: ${targetOS.name} - ${targetArch.name}'),
    //   };
    //   return .new(
    //     config: cf,
    //     libs: [.new(archivePath: 'libmpv_audio.so', libName: mpvLibName)],
    //     platform: targetOS.name,
    //     arch: targetArch.name,
    //     downloadUrl: downloadUrl as String,
    //   );
    // }

    throw UnsupportedError(
      'Not Supported: ${targetOS.name} - ${targetArch.name}',
    );
  }
}
