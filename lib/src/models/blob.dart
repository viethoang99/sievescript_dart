import 'package:json_annotation/json_annotation.dart';

part 'blob.g.dart';

@JsonSerializable()
class Blob {
  /**
   *  context: Response:
   *  the data:asText and data:asBase64 can empty/null.

[ "Blob/get", { "accountId" : "account1", "list" : [ { "id" : "G6ec94756e3e046be78fcb33953b85b944e70673e", "data:asText" : "quick bro", "data:asBase64" : "cXVpY2sgYnJvCg==", "size" : 46 } ], "notFound" : [ "not-a-blob" ] }, "R1" ]
   */
  final String id;
  final String? dataAsText;
  final String? dataAsBase64;
  final int size;

  Blob({
    required this.id,
    this.dataAsText,
    this.dataAsBase64,
    required this.size,
  });

  factory Blob.fromJson(Map<String, dynamic> json) => _$BlobFromJson(json);

  Map<String, dynamic> toJson() => _$BlobToJson(this);
}
