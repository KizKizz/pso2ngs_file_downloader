// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Item _$ItemFromJson(Map<String, dynamic> json) => Item(
      json['csvFileName'] as String,
      json['cvsFilePath'] as String,
      json['itemType'] as String,
      (json['itemCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      json['iconImagePath'] as String,
      Map<String, String>.from(json['infos'] as Map),
    );

Map<String, dynamic> _$ItemToJson(Item instance) => <String, dynamic>{
      'csvFileName': instance.csvFileName,
      'cvsFilePath': instance.cvsFilePath,
      'itemType': instance.itemType,
      'itemCategories': instance.itemCategories,
      'iconImagePath': instance.iconImagePath,
      'infos': instance.infos,
    };
