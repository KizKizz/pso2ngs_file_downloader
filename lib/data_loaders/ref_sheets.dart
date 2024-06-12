import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:pso2ngs_file_locator/classes.dart';
import 'package:pso2ngs_file_locator/global_vars.dart';

//Csv lists
List<String> accessoriesCsv = ['Accessories.csv'];
List<String> emoteCsv = ['LobbyActionsNGS_HandPoses.csv', 'LobbyActions.csv'];
List<String> basewearCsv = ['GenderlessNGSBasewear.csv', 'FemaleNGSBasewear.csv', 'MaleNGSBasewear.csv', 'FemaleBasewear.csv', 'MaleBasewear.csv'];
List<String> magsCsv = ['Mags.csv', 'MagsNGS.csv'];
List<String> stickersCsv = ['Stickers.csv'];
List<String> innerwearCsv = ['FemaleNGSInnerwear.csv', 'MaleNGSInnerwear.csv', 'MaleInnerwear.csv', 'FemaleInnerwear.csv'];
List<String> outerwearCsv = ['FemaleNGSOuters.csv', 'MaleNGSOuters.csv', 'FemaleOuters.csv', 'MaleOuters.csv'];
List<String> bodyPaintCsv = ['GenderlessNGSBodyPaint.csv', 'FemaleNGSBodyPaint.csv', 'MaleNGSBodyPaint.csv', 'FemaleBodyPaint.csv', 'MaleBodyPaint.csv'];
List<String> facePaintCsv = ['FacePaintNGS.csv', 'FacePaint.csv'];
List<String> hairCsv = ['AllHairNGS.csv', 'CasealHair.csv', 'FemaleHair.csv', 'MaleHair.csv'];
List<String> castBodyCsv = ['CastBodies.csv', 'CasealBodies.csv', 'CastNGSBodies.csv', 'CasealNGSBodies.csv'];
List<String> castArmCsv = ['CastArms.csv', 'CastArms.csv', 'CasealArmsNGS.csv', 'CastArmsNGS.csv'];
List<String> castLegCsv = ['CasealLegs.csv', 'CastLegs.csv', 'CastLegsNGS.csv', 'CasealLegsNGS.csv'];
List<String> eyeCsv = ['EyesNGS.csv', 'EyelashesNGS.csv', 'EyebrowsNGS.csv', 'Eyes.csv', 'Eyelashes.csv', 'Eyebrows.csv'];
List<String> costumeCsv = ['FemaleCostumes.csv', 'MaleCostumes.csv'];
List<String> motionCsv = [
  'SubstituteMotionGlide.csv',
  'SubstituteMotionJump.csv',
  'SubstituteMotionLanding.csv',
  'SubstituteMotionPhotonDash.csv',
  'SubstituteMotionRun.csv',
  'SubstituteMotionStandby.csv',
  'SubstituteMotionSwim.csv'
];
List<String> weaponCsv = [
  //NGS
  'BowNGSNames.csv',
  'DoubleSaberNGSNames.csv',
  'DualBladesNGSNames.csv',
  'GunslashNGSNames.csv',
  'JetBootsNGSNames.csv',
  'KatanaNGSNames.csv',
  'KnucklesNGSNames.csv',
  'LauncherNGSNames.csv',
  'PartizanNGSNames.csv',
  'RifleNGSNames.csv',
  'RodNGSNames.csv',
  'SwordNGSNames.csv',
  'TactNGSNames.csv',
  'TalisNGSNames.csv',
  'TwinDaggerNGSNames.csv',
  'TwinMachineGunNGSNames.csv',
  'WandNGSNames.csv',
  'WeaponDefaults.csv',
  'WeaponDefaultsNGS.csv',
  'WiredLanceNGSNames.csv'
      //PSO2
      'BowNames.csv',
  'DoubleSaberNames.csv',
  'DualBladesNames.csv',
  'GunslashNames.csv',
  'JetBootsNames.csv',
  'KatanaNames.csv',
  'KnucklesNames.csv',
  'LauncherNames.csv',
  'PartizanNames.csv',
  'RifleNames.csv',
  'RodNames.csv',
  'SwordNames.csv',
  'TactNames.csv',
  'TalisNames.csv',
  'TwinDaggerNames.csv',
  'TwinMachineGunNames.csv',
  'WandNames.csv',
  'WeaponDefaults.csv',
  'WeaponDefaults.csv',
  'WiredLanceNames.csv'
];

List<List<String>> csvFileList = [
  accessoriesCsv,
  basewearCsv,
  bodyPaintCsv,
  castArmCsv,
  castBodyCsv,
  castLegCsv,
  costumeCsv,
  emoteCsv,
  eyeCsv,
  facePaintCsv,
  hairCsv,
  innerwearCsv,
  magsCsv,
  [],
  motionCsv,
  outerwearCsv,
  basewearCsv,
  weaponCsv
];

Future<List<Item>> populateItemList() async {
  List<Item> itemList = [];
  final csvFiles = refSheetsDir.listSync(recursive: true).whereType<File>().where((file) => p.extension(file.path) == '.csv');
  final csvJPFiles = refSheetsJPDir.listSync(recursive: true).whereType<File>().where((file) => p.extension(file.path) == '.csv');

  //NA sheets
  for (var file in csvFiles) {
    List<String> headers = [];
    List<String> infos = [];
    List<String> csvContent = [];

    String filePathInCsvDir = file.path.split('ref_sheets').last;
    final filePathParts = p.split(filePathInCsvDir);

    await File(file.path).openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) {
      if (line.isNotEmpty) csvContent.add(line);
    });

    //headers and padding
    switch (filePathParts[1]) {
      case 'Enemies':
        if (filePathParts.last == 'EnemiesClassic.csv' || filePathParts.last == 'EnemyBaseStats.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
        } else if (filePathParts.last == 'EnemiesNGS Miscellaneous.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        }
      case 'Music':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        for (var line in csvContent) {
          csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
        }
      case 'NPC':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        break;
      case 'Objects':
        if (filePathParts.last == 'Room Goods.csv') {
          headers.addAll(csvContent[1].split(','));
          csvContent.removeRange(0, 2);
        } else {
          headers.addAll(csvContent[0].split(','));
          csvContent.removeAt(0);
        }
        break;
      case 'Pets':
        headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
        csvContent.removeAt(0);
        break;
      case 'Player':
        List<String> threeFieldsFiles = [
          'CasealVoices.csv',
          'CastVoices.csv',
          'DarkBlasts_DrivableVehicles.csv',
          'FemaleVoices.csv',
          'MaleVoices.csv',
          'PhotonBlastCreatures.csv',
          'General Character Animations.csv',
          'General Character Effects.csv',
          'General Character Animations NGS.csv',
          'General Reboot Character Effects.csv'
        ];
        List<String> fourFieldsFiles = ['Mags.csv', 'MagsNGS.csv'];

        if (threeFieldsFiles.contains(filePathParts.last)) {
          headers.addAll(['Japanese Name', 'English Name', 'Ice Hash']);
          for (var element in csvContent) {
            csvContent[csvContent.indexOf(element)] = element.replaceAll(',(Not found)', '').trim();
          }
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 3) {
              String commas = '';
              for (int i = fields; i < 3; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            } else if (fields > 3) {
              final tempFields = line.split(',');
              List<String> temp = [];
              temp.add(tempFields[0]);
              temp.add(tempFields.getRange(1, tempFields.length - 2).join(' ').trim());
              temp.addAll(tempFields.getRange(tempFields.length - 2, tempFields.length));
              csvContent[csvContent.indexOf(line)] = temp.join(',');
            }
          }
        } else if (fourFieldsFiles.contains(filePathParts.last)) {
          headers.addAll(['Japanese Name', 'English Name', 'Ice Hash']);
          for (var element in csvContent) {
            csvContent[csvContent.indexOf(element)] = element.replaceAll(',(Not found)', '').trim();
          }
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 4) {
              String commas = '';
              for (int i = fields; i < 4; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            } else if (fields > 4) {
              final tempFields = line.split(',');
              List<String> temp = [];
              temp.add(tempFields[0]);
              temp.add(tempFields.getRange(1, tempFields.length - 2).join(' ').trim());
              temp.addAll(tempFields.getRange(tempFields.length - 2, tempFields.length));
              csvContent[csvContent.indexOf(line)] = temp.join(',');
            }
          }
        } else if (filePathParts.last == 'DarkBlasts_DrivableVehiclesNGS.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Ice Hash']);
        } else {
          if (filePathParts.last == 'MaleBodyPaint.csv') {
            debugPrint('test');
          }
          headers.addAll(csvContent[0].split(','));
          csvContent.removeAt(0);
        }
        break;
      case 'Stage':
        if (filePathParts.last == 'Classic') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        } else if (filePathParts.last == 'NGS') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 4) {
              String commas = '';
              for (int i = fields; i < 4; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            }
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 4) {
              String commas = '';
              for (int i = fields; i < 4; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            } else if (fields > 4) {
              final tempFields = line.split(',');
              List<String> temp = [];
              temp.add(tempFields[0]);
              temp.add(tempFields.getRange(1, tempFields.length - 2).join(' ').trim());
              temp.addAll(tempFields.getRange(tempFields.length - 2, tempFields.length));
              csvContent[csvContent.indexOf(line)] = temp.join(',');
            }
          }
        }
        break;
      case 'UI':
        if (filePathParts.last == 'stamps.csv' || filePathParts.last == 'stampsNA.csv' || filePathParts.last == 'Vital Gauge.csv') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash - Image']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        }
        break;
      case 'Units':
        headers.addAll(['Japanese Name', 'English Name', '1st model attach bone', '2nd model attach bone', 'Extra model attach bone', 'Object unhashed name', 'Object hashed name']);
        csvContent.removeRange(0, 2);
        for (var line in csvContent) {
          csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 7);
        }
        break;
      case 'Weapons':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        for (var line in csvContent) {
          csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
        }
      default:
        headers.addAll(['Japanese Name', 'English Name']);
        for (var line in csvContent) {
          int numMissingHeaders = line.split(',').length - headers.length;
          String commas = '';
          while (numMissingHeaders-- > 0) {
            commas += ',';
          }
          csvContent[csvContent.indexOf(line)] = '$commas$line';
        }
        break;
    }

    String emoteChatCommand = '';
    String emoteENName = '';
    String emoteJPName = '';
    for (var line in csvContent) {
      if (line.split(',').isNotEmpty) {
        int categoryIndex = csvFileList.indexWhere((element) => element.where((e) => e == p.basename(file.path)).isNotEmpty);
        String enItemName = '';
        String jpItemName = '';
        List<String> fields = const CsvToListConverter().convert(line).first.map((e) => e.toString()).toList();
        for (var element in fields) {
          fields[fields.indexOf(element)] = element.trim();
        }
        infos.addAll(fields);

        int enItemNameIndex = headers.indexOf('English Name');
        int jpItemNameIndex = headers.indexOf('Japanese Name');
        if (enItemNameIndex != -1) {
          enItemName = infos[enItemNameIndex];
        }
        if (jpItemNameIndex != -1) {
          jpItemName = infos[jpItemNameIndex];
        }

        String subCategory = '';
        if (categoryIndex == 1) {
          //Basewears
          if (enItemName.contains('[Ba]') || jpItemName.contains('[Ba]')) {
            subCategory = 'Basewear';
          } else if (enItemName.contains('[Se]') || jpItemName.contains('[Se]')) {
            subCategory = 'Setwear';
          } else if (enItemName.contains('[Fu]') || jpItemName.contains('[Fu]')) {
            subCategory = 'Full Setwear';
          }
        } else if (categoryIndex == 7) {
          //Emotes
          int commandHeaderIndex = headers.indexWhere((element) => element == 'Chat Command');
          if (commandHeaderIndex != -1) {
            if (emoteENName.isEmpty) emoteENName = enItemName;
            if (emoteJPName.isEmpty) emoteJPName = jpItemName;
            if (infos[commandHeaderIndex].isEmpty && emoteChatCommand.isNotEmpty && (emoteENName == enItemName || emoteJPName == jpItemName)) {
              infos[commandHeaderIndex] = emoteChatCommand;
              emoteENName = enItemName;
              emoteJPName = jpItemName;
            } else if (infos[commandHeaderIndex] != emoteChatCommand && infos[commandHeaderIndex].isNotEmpty) {
              emoteChatCommand = infos[commandHeaderIndex];
              emoteENName = enItemName;
              emoteJPName = jpItemName;
            }
          }
        } else if (categoryIndex == 14) {
          //Motions
          if (p.basename(file.path) == 'SubstituteMotionGlide.csv') {
            subCategory = 'Glide Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionJump.csv') {
            subCategory = 'Jump Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionLanding.csv') {
            subCategory = 'Landing Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionPhotonDash.csv') {
            subCategory = 'Dash Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionRun.csv') {
            subCategory = 'Run Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionStandby.csv') {
            subCategory = 'Standby Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionSwim.csv') {
            subCategory = 'Swim Motion';
          }
        } else if (categoryIndex == 17) {
          if (enItemName.isNotEmpty && enItemName.characters.first == '*' || jpItemName.isNotEmpty && jpItemName.characters.first == '*') {
            subCategory = '* ';
          }
          switch (p.basename(file.path)) {
            case 'BowNGSNames.csv' || 'BowNames.csv':
              subCategory += 'Bows';
              break;
            case 'DoubleSaberNGSNames.csv' || 'DoubleSaberNames.csv':
              subCategory += 'Double Sabers';
              break;
            case 'DualBladesNGSNames.csv' || 'DualBladesNames.csv':
              subCategory += 'Soaring Blades';
              break;
            case 'GunslashNGSNames.csv' || 'GunslashNames.csv':
              subCategory += 'Gunblades';
              break;
            case 'JetBootsNGSNames.csv' || 'JetBootsNames.csv':
              subCategory += 'Jet Boots';
              break;
            case 'KatanaNGSNames.csv' || 'KatanaNames.csv':
              subCategory += 'Katanas';
              break;
            case 'KnucklesNGSNames.csv' || 'KnucklesNames.csv':
              subCategory += 'Knuckles';
              break;
            case 'LauncherNGSNames.csv' || 'LauncherNames.csv':
              subCategory += 'Launchers';
              break;
            case 'PartizanNGSNames.csv' || 'PartizanNames.csv':
              subCategory += 'Partisans';
              break;
            case 'RifleNGSNames.csv' || 'RifleNames.csv':
              subCategory += 'Assault Rifles';
              break;
            case 'RodNGSNames.csv' || 'RodNames.csv':
              subCategory += 'Rods';
              break;
            case 'SwordNGSNames.csv' || 'SwordNames.csv':
              subCategory += 'Swords';
              break;
            case 'TactNGSNames.csv' || 'TactNames.csv':
              subCategory += 'Harmonizers';
              break;
            case 'TalisNGSNames.csv' || 'TalisNames.csv':
              subCategory += 'Talises';
              break;
            case 'TwinDaggerNGSNames.csv' || 'TwinDaggerNames.csv':
              subCategory += 'Twin Daggers';
              break;
            case 'TwinMachineGunNGSNames.csv' || 'TwinMachineGunNames.csv':
              subCategory += 'Twin Machine Guns';
              break;
            case 'WandNGSNames.csv' || 'WandNames.csv':
              subCategory += 'Wands';
              break;
            case 'WiredLanceNGSNames.csv' || 'WiredLanceNames.csv':
              subCategory += 'Wired Lances';
              break;
            default:
              subCategory += 'Unknown Weapons';
              break;
          }
        }

        Item newItem = await itemFromCsv(
            p.basename(file.path),
            p.dirname(filePathInCsvDir),
            filePathInCsvDir.contains('NGS')
                ? 'NGS'
                : filePathInCsvDir.contains('PSO2') || filePathInCsvDir.contains('Classic') || filePathInCsvDir.contains('classic')
                    ? 'PSO2'
                    : '',
            [p.basenameWithoutExtension(file.path)],
            categoryIndex != -1 ? defaultCategoryDirs[categoryIndex] : defaultCategoryDirs[13],
            subCategory,
            categoryIndex,
            '',
            headers,
            infos);

        itemList.add(newItem);
        infos.clear();
      }
    }
  }

  //JP sheets
  for (var file in csvJPFiles) {
    List<String> headers = [];
    List<String> infos = [];
    List<String> csvContent = [];

    String filePathInCsvDir = file.path.split('ref_sheets_jp').last;
    final filePathParts = p.split(filePathInCsvDir);

    await File(file.path).openRead().transform(utf8.decoder).transform(const LineSplitter()).forEach((line) {
      if (line.isNotEmpty) csvContent.add(line);
    });

    switch (filePathParts[1]) {
      case 'Enemies':
        if (filePathParts.last == 'EnemiesClassic.csv' || filePathParts.last == 'EnemyBaseStats.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
        } else if (filePathParts.last == 'EnemiesNGS Miscellaneous.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        }
      case 'Music':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        for (var line in csvContent) {
          csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
        }
      case 'NPC':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        break;
      case 'Objects':
        if (filePathParts.last == 'Room Goods.csv') {
          headers.addAll(csvContent[1].split(','));
          csvContent.removeRange(0, 2);
        } else {
          headers.addAll(csvContent[0].split(','));
          csvContent.removeAt(0);
        }
        break;
      case 'Pets':
        headers.addAll(['English Name', 'Japanese Name', 'Path', 'Ice Hash']);
        csvContent.removeAt(0);
        break;
      case 'Player':
        List<String> threeFieldsFiles = [
          'CasealVoices.csv',
          'CastVoices.csv',
          'DarkBlasts_DrivableVehicles.csv',
          'FemaleVoices.csv',
          'MaleVoices.csv',
          'PhotonBlastCreatures.csv',
          'General Character Animations.csv',
          'General Character Effects.csv',
          'General Character Animations NGS.csv',
          'General Reboot Character Effects.csv'
        ];
        List<String> fourFieldsFiles = ['Mags.csv', 'MagsNGS.csv'];

        if (threeFieldsFiles.contains(filePathParts.last)) {
          headers.addAll(['Japanese Name', 'English Name', 'Ice Hash']);
          for (var element in csvContent) {
            csvContent[csvContent.indexOf(element)] = element.replaceAll(',(Not found)', '').trim();
          }
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 3) {
              String commas = '';
              for (int i = fields; i < 3; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            } else if (fields > 3) {
              final tempFields = line.split(',');
              List<String> temp = [];
              temp.add(tempFields[0]);
              temp.add(tempFields.getRange(1, tempFields.length - 2).join(' ').trim());
              temp.addAll(tempFields.getRange(tempFields.length - 2, tempFields.length));
              csvContent[csvContent.indexOf(line)] = temp.join(',');
            }
          }
        } else if (fourFieldsFiles.contains(filePathParts.last)) {
          headers.addAll(['Japanese Name', 'English Name', 'Ice Hash']);
          for (var element in csvContent) {
            csvContent[csvContent.indexOf(element)] = element.replaceAll(',(Not found)', '').trim();
          }
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 4) {
              String commas = '';
              for (int i = fields; i < 4; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            } else if (fields > 4) {
              final tempFields = line.split(',');
              List<String> temp = [];
              temp.add(tempFields[0]);
              temp.add(tempFields.getRange(1, tempFields.length - 2).join(' ').trim());
              temp.addAll(tempFields.getRange(tempFields.length - 2, tempFields.length));
              csvContent[csvContent.indexOf(line)] = temp.join(',');
            }
          }
        } else if (filePathParts.last == 'DarkBlasts_DrivableVehiclesNGS.csv') {
          headers.addAll(['English Name', 'Japanese Name', 'Ice Hash']);
        } else {
          headers.addAll(csvContent[0].split(','));
          csvContent.removeAt(0);
        }
        break;
      case 'Stage':
        if (filePathParts.last == 'Classic') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        } else if (filePathParts.last == 'NGS') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 4) {
              String commas = '';
              for (int i = fields; i < 4; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            }
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            int fields = line.split(',').length;
            if (fields < 4) {
              String commas = '';
              for (int i = fields; i < 4; i++) {
                commas += ',';
              }
              csvContent[csvContent.indexOf(line)] = '$commas$line';
            } else if (fields > 4) {
              final tempFields = line.split(',');
              List<String> temp = [];
              temp.add(tempFields[0]);
              temp.add(tempFields.getRange(1, tempFields.length - 2).join(' ').trim());
              temp.addAll(tempFields.getRange(tempFields.length - 2, tempFields.length));
              csvContent[csvContent.indexOf(line)] = temp.join(',');
            }
          }
        }
        break;
      case 'UI':
        if (filePathParts.last == 'stamps.csv' || filePathParts.last == 'stampsNA.csv' || filePathParts.last == 'Vital Gauge.csv') {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash - Image']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        } else {
          headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
          for (var line in csvContent) {
            csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
          }
        }
        break;
      case 'Units':
        headers.addAll(['Japanese Name', 'English Name', '1st model attach bone', '2nd model attach bone', 'Extra model attach bone', 'Object unhashed name', 'Object hashed name']);
        csvContent.removeRange(0, 2);
        for (var line in csvContent) {
          csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 7);
        }
        break;
      case 'Weapons':
        headers.addAll(['Japanese Name', 'English Name', 'Path', 'Ice Hash']);
        for (var line in csvContent) {
          csvContent[csvContent.indexOf(line)] = itemInfoLineFieldPad(line, 4);
        }
      default:
        headers.addAll(['Japanese Name', 'English Name']);
        for (var line in csvContent) {
          int numMissingHeaders = line.split(',').length - headers.length;
          String commas = '';
          while (numMissingHeaders-- > 0) {
            commas += ',';
          }
          csvContent[csvContent.indexOf(line)] = '$commas$line';
        }
        break;
    }

    String emoteChatCommand = '';
    for (var line in csvContent) {
      if (line.split(',').isNotEmpty) {
        int categoryIndex = csvFileList.indexWhere((element) => element.where((e) => e == p.basename(file.path)).isNotEmpty);
        String enItemName = '';
        String jpItemName = '';
        List<String> fields = const CsvToListConverter().convert(line).first.map((e) => e.toString()).toList();
        for (var element in fields) {
          fields[fields.indexOf(element)] = element.trim();
        }
        infos.addAll(fields);

        int enItemNameIndex = headers.indexOf('English Name');
        int jpItemNameIndex = headers.indexOf('Japanese Name');
        if (enItemNameIndex != -1) {
          enItemName = infos[enItemNameIndex];
        }
        if (jpItemNameIndex != -1) {
          jpItemName = infos[jpItemNameIndex];
        }

        String subCategory = '';
        if (categoryIndex == 1) {
          //Basewears
          if (enItemName.contains('[Ba]') || jpItemName.contains('[Ba]')) {
            subCategory = 'Basewear';
          } else if (enItemName.contains('[Se]') || jpItemName.contains('[Se]')) {
            subCategory = 'Setwear';
          } else if (enItemName.contains('[Fu]') || jpItemName.contains('[Fu]')) {
            subCategory = 'Full Setwear';
          }
        } else if (categoryIndex == 7) {
          //Emotes
          int commandHeaderIndex = headers.indexWhere((element) => element == 'Chat Command');
          if (commandHeaderIndex != -1) {
            if (infos[commandHeaderIndex].isEmpty && emoteChatCommand.isNotEmpty) {
              infos[commandHeaderIndex] = emoteChatCommand;
            } else if (infos[commandHeaderIndex] != emoteChatCommand && infos[commandHeaderIndex].isNotEmpty) {
              emoteChatCommand = infos[commandHeaderIndex];
            }
          }
        } else if (categoryIndex == 14) {
          //Motions
          if (p.basename(file.path) == 'SubstituteMotionGlide.csv') {
            subCategory = 'Glide Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionJump.csv') {
            subCategory = 'Jump Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionLanding.csv') {
            subCategory = 'Landing Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionPhotonDash.csv') {
            subCategory = 'Dash Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionRun.csv') {
            subCategory = 'Run Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionStandby.csv') {
            subCategory = 'Standby Motion';
          } else if (p.basename(file.path) == 'SubstituteMotionSwim.csv') {
            subCategory = 'Swim Motion';
          }
        } else if (categoryIndex == 17) {
          if (enItemName.isNotEmpty && enItemName.characters.first == '*' || jpItemName.isNotEmpty && jpItemName.characters.first == '*') {
            subCategory = 'Weapon Camo';
          } else {
            switch (p.basename(file.path)) {
              case 'BowNGSNames.csv' || 'BowNames.csv':
                subCategory += 'Bows';
                break;
              case 'DoubleSaberNGSNames.csv' || 'DoubleSaberNames.csv':
                subCategory += 'Double Sabers';
                break;
              case 'DualBladesNGSNames.csv' || 'DualBladesNames.csv':
                subCategory += 'Soaring Blades';
                break;
              case 'GunslashNGSNames.csv' || 'GunslashNames.csv':
                subCategory += 'Gunblades';
                break;
              case 'JetBootsNGSNames.csv' || 'JetBootsNames.csv':
                subCategory += 'Jet Boots';
                break;
              case 'KatanaNGSNames.csv' || 'KatanaNames.csv':
                subCategory += 'Katanas';
                break;
              case 'KnucklesNGSNames.csv' || 'KnucklesNames.csv':
                subCategory += 'Knuckles';
                break;
              case 'LauncherNGSNames.csv' || 'LauncherNames.csv':
                subCategory += 'Launchers';
                break;
              case 'PartizanNGSNames.csv' || 'PartizanNames.csv':
                subCategory += 'Partisans';
                break;
              case 'RifleNGSNames.csv' || 'RifleNames.csv':
                subCategory += 'Assault Rifles';
                break;
              case 'RodNGSNames.csv' || 'RodNames.csv':
                subCategory += 'Rods';
                break;
              case 'SwordNGSNames.csv' || 'SwordNames.csv':
                subCategory += 'Swords';
                break;
              case 'TactNGSNames.csv' || 'TactNames.csv':
                subCategory += 'Harmonizers';
                break;
              case 'TalisNGSNames.csv' || 'TalisNames.csv':
                subCategory += 'Talises';
                break;
              case 'TwinDaggerNGSNames.csv' || 'TwinDaggerNames.csv':
                subCategory += 'Twin Daggers';
                break;
              case 'TwinMachineGunNGSNames.csv' || 'TwinMachineGunNames.csv':
                subCategory += 'Twin Machine Guns';
                break;
              case 'WandNGSNames.csv' || 'WandNames.csv':
                subCategory += 'Wands';
                break;
              case 'WiredLanceNGSNames.csv' || 'WiredLanceNames.csv':
                subCategory += 'Wired Lances';
                break;
              default:
                subCategory += 'Unknown Weapons';
                break;
            }
          }
        }

        Item newItem = await itemFromCsv(
            p.basename(file.path),
            p.dirname(filePathInCsvDir),
            filePathInCsvDir.contains('NGS')
                ? 'NGS'
                : filePathInCsvDir.contains('PSO2') || filePathInCsvDir.contains('Classic') || filePathInCsvDir.contains('classic')
                    ? 'PSO2'
                    : '',
            [p.basenameWithoutExtension(file.path)],
            categoryIndex != -1 ? defaultCategoryDirs[categoryIndex] : defaultCategoryDirs[13],
            subCategory,
            categoryIndex,
            '',
            headers,
            infos);
        int matchedIndex = itemList.indexWhere((element) => element.compareNames(newItem));
        if (matchedIndex == -1) {
          itemList.add(newItem);
        }

        infos.clear();
      }
    }
  }

  return itemList;
}

Future<Item> itemFromCsv(String csvFileName, String csvFilePath, String itemType, List<String> itemCategories, String category, String subCategory, int categoryIndex, String iconImagePath,
    List<String> headers, List<String> infos) async {
  if (headers.length > infos.length) {
    for (var i = infos.length; i < headers.length; i++) {
      infos.add('');
    }
  } else if (infos.length > headers.length) {
    for (var i = headers.length; i < infos.length; i++) {
      headers.add('Unknown ($i)');
    }
  }

  final infoMap = Map.fromIterables(headers, infos);
  return Item.fromMap(csvFileName, csvFilePath, itemType, itemCategories, category, subCategory, categoryIndex, iconImagePath, infoMap);
}

//Helpers

String itemInfoLineFieldPad(String line, int fieldNum) {
  int fields = line.split(',').length;
  String commas = '';
  if (fields < fieldNum) {
    for (int i = fields; i < fieldNum; i++) {
      commas += ',';
    }
  }
  return commas + line;
}
