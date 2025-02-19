import 'package:json_annotation/json_annotation.dart';

part 'sieve_script.g.dart';

@JsonSerializable()
class SieveScript {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'blobId')
  final String? blobId;

  @JsonKey(name: 'isActive')
  final bool isActive;

  SieveScript({
    this.id,
    this.name,
    this.blobId,
    this.isActive = false,
  });

  factory SieveScript.fromJson(Map<String, dynamic> json) {
    // print('SieveScript.fromJson: $json');
    return SieveScript(
      id: json['id'] as String?,
      name: json['name'] as String?,
      blobId: json['blobId'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$SieveScriptToJson(this);
}
