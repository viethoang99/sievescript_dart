// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blob.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Blob _$BlobFromJson(Map<String, dynamic> json) => Blob(
      id: json['id'] as String,
      dataAsText: json['dataAsText'] as String?,
      dataAsBase64: json['dataAsBase64'] as String?,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$BlobToJson(Blob instance) => <String, dynamic>{
      'id': instance.id,
      'dataAsText': instance.dataAsText,
      'dataAsBase64': instance.dataAsBase64,
      'size': instance.size,
    };
