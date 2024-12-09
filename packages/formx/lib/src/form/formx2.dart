// import 'package:flutter/material.dart';

// import '../../formx.dart';

// class Formx2 extends Form {
//   const Formx2({
//     super.key,
//     super.onChanged,
//     required this.fields,
//     this.onForm = defaultForm,
//     this.onField = defaultField,
//     this.builder = defaultBuilder,
//   }) : super(child: const SizedBox());

//   /// The fields to build.
//   final Map<String, dynamic> fields;

//   /// A function to build a field.
//   final Widget Function(String key, dynamic value) onField;

//   /// A function to build a form.
//   final Widget Function(String key, Map<String, dynamic> fields) onForm;

//   final Widget Function(FormState state, Map<String, Widget> children) builder;

//   /// A default implementation for a field.
//   static Widget defaultField(String key, Object? value) {
//     final noField = NoFormField(
//       key: Key(key),
//       initialValue: value,
//     );

//     final skey = key.snakeCase;
//     if (skey == 'id') return noField;
//     if (skey.endsWith('id')) return noField;
//     if (skey.endsWith('ids')) return noField;
//     if (skey.startsWith('created')) return noField;
//     if (skey.startsWith('updated')) return noField;
//     if (skey.startsWith('deleted')) return noField;

//     final field = switch (value) {
//       bool value => CheckboxFormField(
//           key: Key(key),
//           title: Text(key.titleCase),
//           initialValue: value,
//         ),
//       String url when key.endsWith('url') => ImageFormField.url(
//           key: Key(key),
//           decoration: InputDecoration(labelText: key.titleCase),
//           initialValue: url,
//         ),
//       num value => TextFormField(
//           key: Key(key).options(
//             adapter: num.tryParse,
//           ),
//           initialValue: value.toString(),
//           decoration: InputDecoration(labelText: key.titleCase),
//         ),
//       String text => TextFormField(
//           key: Key(key),
//           initialValue: text,
//           decoration: InputDecoration(labelText: key.titleCase),
//         ),
//       _ => noField,
//     };

//     return field;
//   }

//   /// A default implementation for a form.
//   static Widget defaultForm(String key, Map<String, dynamic> fields) {
//     return Builder(
//       builder: (context) {
//         final parent = context.findAncestorWidgetOfExactType<Formx2>()!;
//         return Formx2(
//           key: Key(key),
//           fields: fields,
//           onForm: parent.onForm,
//           onField: parent.onField,
//           onChanged: parent.onChanged,
//         );
//       },
//     );
//   }

//   /// A default implementation for a builder.
//   static Widget defaultBuilder(FormState state, Map<String, Widget> children) {
//     return Card.outlined(
//       child: Column(
//         children: [
//           if (state.key case var key?) Text(key.titleCase),
//           for (final child in children.values)
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: child,
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget get child => Builder(
//         builder: (context) {
//           final noFields = <Widget>[];
//           final fields = children.toMap()
//             ..removeWhere((e, v) {
//               if (e is! NoFormField) return false;
//               noFields.add(v);
//               return true;
//             });

//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               builder(context.findAncestorStateOfType()!, fields),
//               ...noFields,
//             ],
//           );
//         },
//       );

//   /// The children to build.
//   Map<String, Widget> get children => {
//         for (final (field) in fields.entries)
//           field.key: switch (field.value) {
//             Map fields => onForm(field.key, fields.cast()),
//             _ => onField(field.key, field.value),
//           },
//       };
// }

// extension on Object {
//   DateTime toDate() {
//     final value = this;
//     if (value is DateTime) return value;
//     if (value is String) return DateTime.parse(value);
//     if (toString().startsWith('Timestamp')) {
//       return (value as dynamic).toDate() as DateTime;
//     }

//     throw ArgumentError.value(value, 'value', 'Cannot convert to DateTime');
//   }
// }

// class NoFormField extends FormField {
//   const NoFormField({
//     super.key,
//     super.autovalidateMode,
//     super.enabled,
//     super.initialValue,
//     super.onSaved,
//     super.validator,
//     super.restorationId,
//     super.forceErrorText,
//   }) : super(builder: build);

// ignore_for_file: lines_longer_than_80_chars

//   @override
//   static Widget build(FormFieldState state) => const SizedBox.shrink();
// }
