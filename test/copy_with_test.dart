import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';
import 'package:formx/src/interface/text_form_field_copy.dart';

import 'constructor_parser/extractor.dart';
import 'constructor_parser/param.dart';

void main() {
  test('check if copiable TextFormField has same params as original', () {
    final mainParams = Constructor(TextFormField.new).params;
    final copyParams = Constructor(TextFormFieldCopy.new).params;

    expect(mainParams, copyParams);
  });
  group('TextFormxField.copyWith', () {
    const widget = TextFormxField('tag');

    final newClass = Constructor(TextFormxField.new);
    final copyWith = Constructor(widget.copyWith);

    test('params are optional', () {
      final areAllNullable = copyWith.params.every((e) => e.isNullable);
      final areAllNamed = copyWith.params.every((e) => e is NamedParam);

      expect(areAllNullable, true);
      expect(areAllNamed, true);
    });

    test('params have exactly same type (ignores nullability)', () {
      final copyWithTypeNames = copyWith.namedParams.map((e) => e.typeName);
      final newClassTypeNames = newClass.namedParams.map((e) => e.typeName);

      expect(copyWithTypeNames, newClassTypeNames);
    });

    test('params have same property name', () {
      final copyWithPropNames = copyWith.namedParams.map((e) => e.named);
      final newClassPropNames = newClass.namedParams.map((e) => e.named);

      expect(copyWithPropNames, newClassPropNames);
    });

    test('tag is always preserved', () {
      final newWidget = widget.copyWith();

      expect(newWidget.tag, widget.tag);
    });
  });
}
