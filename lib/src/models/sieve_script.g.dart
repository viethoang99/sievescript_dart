// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sieve_script.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SieveScript _$SieveScriptFromJson(Map<String, dynamic> json) => SieveScript(
      id: json['id'] as String?,
      name: json['name'] as String?,
      blobId: json['blobId'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );

Map<String, dynamic> _$SieveScriptToJson(SieveScript instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'blobId': instance.blobId,
      'isActive': instance.isActive,
    };
