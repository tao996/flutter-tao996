// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PsStyle _$PsStyleFromJson(Map<String, dynamic> json) => PsStyle(
  size: _$JsonConverterFromJson<String, Size>(
    json['size'],
    const JsonSizeConverter().fromJson,
  ),
  radius: (json['radius'] as num?)?.toDouble(),
  opacity: (json['opacity'] as num?)?.toDouble(),
  color: _$JsonConverterFromJson<int, Color>(
    json['color'],
    const JsonColorConverter().fromJson,
  ),
  backgroundColor: _$JsonConverterFromJson<int, Color>(
    json['backgroundColor'],
    const JsonColorConverter().fromJson,
  ),
  fontSize: (json['fontSize'] as num?)?.toDouble(),
  fontWeight: _$JsonConverterFromJson<int, FontWeight>(
    json['fontWeight'],
    const JsonFontWeightConverter().fromJson,
  ),
  position: json['position'] == null
      ? Offset.zero
      : const JsonOffsetConverter().fromJson(json['position'] as String),
  scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
  center: json['center'] as bool? ?? true,
  inherit: json['inherit'] as bool? ?? true,
  borderWidth: (json['borderWidth'] as num?)?.toDouble(),
  borderColor: _$JsonConverterFromJson<int, Color>(
    json['borderColor'],
    const JsonColorConverter().fromJson,
  ),
  shadow: _$JsonConverterFromJson<String, BoxShadow>(
    json['shadow'],
    const JsonBoxShadowConverter().fromJson,
  ),
  canvasSize: _$JsonConverterFromJson<String, Size>(
    json['canvasSize'],
    const JsonSizeConverter().fromJson,
  ),
  padding: _$JsonConverterFromJson<String, EdgeInsets>(
    json['padding'],
    const JsonEdgeInsetsConverter().fromJson,
  ),
  margin: _$JsonConverterFromJson<String, EdgeInsets>(
    json['margin'],
    const JsonEdgeInsetsConverter().fromJson,
  ),
  rotate: (json['rotate'] as num?)?.toDouble() ?? 0.0,
  backgroundGradient: _$JsonConverterFromJson<String, Gradient>(
    json['backgroundGradient'],
    const JsonGradientConverter().fromJson,
  ),
  foregroundGradient: _$JsonConverterFromJson<String, Gradient>(
    json['foregroundGradient'],
    const JsonGradientConverter().fromJson,
  ),
  textShadow: _$JsonConverterFromJson<String, BoxShadow>(
    json['textShadow'],
    const JsonBoxShadowConverter().fromJson,
  ),
  backgroundFit: json['backgroundFit'] == null
      ? BoxFit.cover
      : const JsonBoxFitConverter().fromJson(json['backgroundFit'] as String),
  blur: (json['blur'] as num?)?.toDouble(),
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PsStyleToJson(PsStyle instance) => <String, dynamic>{
  'size': _$JsonConverterToJson<String, Size>(
    instance.size,
    const JsonSizeConverter().toJson,
  ),
  'radius': instance.radius,
  'opacity': instance.opacity,
  'color': _$JsonConverterToJson<int, Color>(
    instance.color,
    const JsonColorConverter().toJson,
  ),
  'backgroundColor': _$JsonConverterToJson<int, Color>(
    instance.backgroundColor,
    const JsonColorConverter().toJson,
  ),
  'fontSize': instance.fontSize,
  'fontWeight': _$JsonConverterToJson<int, FontWeight>(
    instance.fontWeight,
    const JsonFontWeightConverter().toJson,
  ),
  'position': const JsonOffsetConverter().toJson(instance.position),
  'center': instance.center,
  'inherit': instance.inherit,
  'borderWidth': instance.borderWidth,
  'borderColor': _$JsonConverterToJson<int, Color>(
    instance.borderColor,
    const JsonColorConverter().toJson,
  ),
  'shadow': _$JsonConverterToJson<String, BoxShadow>(
    instance.shadow,
    const JsonBoxShadowConverter().toJson,
  ),
  'canvasSize': _$JsonConverterToJson<String, Size>(
    instance.canvasSize,
    const JsonSizeConverter().toJson,
  ),
  'scale': instance.scale,
  'padding': _$JsonConverterToJson<String, EdgeInsets>(
    instance.padding,
    const JsonEdgeInsetsConverter().toJson,
  ),
  'margin': _$JsonConverterToJson<String, EdgeInsets>(
    instance.margin,
    const JsonEdgeInsetsConverter().toJson,
  ),
  'rotate': instance.rotate,
  'backgroundGradient': _$JsonConverterToJson<String, Gradient>(
    instance.backgroundGradient,
    const JsonGradientConverter().toJson,
  ),
  'foregroundGradient': _$JsonConverterToJson<String, Gradient>(
    instance.foregroundGradient,
    const JsonGradientConverter().toJson,
  ),
  'textShadow': _$JsonConverterToJson<String, BoxShadow>(
    instance.textShadow,
    const JsonBoxShadowConverter().toJson,
  ),
  'backgroundFit': const JsonBoxFitConverter().toJson(instance.backgroundFit),
  'blur': instance.blur,
  'zIndex': instance.zIndex,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

PsClass _$PsClassFromJson(Map<String, dynamic> json) => PsClass(
  name: json['name'] as String,
  style: PsStyle.fromJson(json['style'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PsClassToJson(PsClass instance) => <String, dynamic>{
  'name': instance.name,
  'style': instance.style,
};

PsNode _$PsNodeFromJson(Map<String, dynamic> json) => PsNode(
  tag: json['tag'] as String?,
  classes: json['classes'] == null
      ? const []
      : const JsonListStringConverter().fromJson(json['classes'] as String),
  type: $enumDecode(_$PsNodeTypeEnumMap, json['type']),
  data: json['data'],
  style: PsStyle.fromJson(json['style'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PsNodeToJson(PsNode instance) => <String, dynamic>{
  'tag': instance.tag,
  'classes': const JsonListStringConverter().toJson(instance.classes),
  'type': _$PsNodeTypeEnumMap[instance.type]!,
  'style': instance.style,
  'data': instance.data,
};

const _$PsNodeTypeEnumMap = {
  PsNodeType.rect: 'rect',
  PsNodeType.circle: 'circle',
  PsNodeType.svg: 'svg',
  PsNodeType.text: 'text',
  PsNodeType.image: 'image',
  PsNodeType.line: 'line',
};

PsMask _$PsMaskFromJson(Map<String, dynamic> json) => PsMask(
  rect: const JsonRectConverter().fromJson(json['rect'] as String),
  radius: (json['radius'] as num?)?.toDouble() ?? 0,
  showBorder: json['showBorder'] == null
      ? false
      : const JsonBoolConverter().fromJson((json['showBorder'] as num).toInt()),
);

Map<String, dynamic> _$PsMaskToJson(PsMask instance) => <String, dynamic>{
  'rect': const JsonRectConverter().toJson(instance.rect),
  'radius': instance.radius,
  'showBorder': const JsonBoolConverter().toJson(instance.showBorder),
};

PsLayer _$PsLayerFromJson(Map<String, dynamic> json) => PsLayer(
  nodes: (json['nodes'] as List<dynamic>)
      .map((e) => PsNode.fromJson(e as Map<String, dynamic>))
      .toList(),
  mask: json['mask'] == null
      ? null
      : PsMask.fromJson(json['mask'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PsLayerToJson(PsLayer instance) => <String, dynamic>{
  'nodes': instance.nodes,
  'mask': instance.mask,
};
