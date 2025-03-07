// ignore_for_file: cascade_invocations, inference_failure_on_collection_literal

import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

void main() {
  group('FormxCleanExtension.clean', () {
    test('removes null values from the map', () {
      var map = {'key1': null, 'key2': 'value2'};
      map.clean();
      expect(map.containsKey('key1'), isFalse);
      expect(map, {'key2': 'value2'});
    });

    test('removes empty strings if emptyString is true', () {
      var map = {'key1': '', 'key2': 'value2'};
      map.clean();
      expect(map.containsKey('key1'), isFalse);
      expect(map, {'key2': 'value2'});
    });

    test('does not remove empty strings if emptyString is false', () {
      var map = {'key1': '', 'key2': 'value2'};
      map.clean(nonEmptyStrings: false);
      expect(map.containsKey('key1'), isTrue);
      expect(map, {'key1': '', 'key2': 'value2'});
    });

    test('removes empty maps if emptyMap is true', () {
      var map = {'key1': {}, 'key2': 'value2'};
      map.clean();
      expect(map.containsKey('key1'), isFalse);
      expect(map, {'key2': 'value2'});
    });

    test('does not remove empty maps if emptyMap is false', () {
      var map = {'key1': {}, 'key2': 'value2'};
      map.clean(nonEmptyMaps: false);
      expect(map.containsKey('key1'), isTrue);
      expect(map, {'key1': {}, 'key2': 'value2'});
    });

    test('removes empty iterables if emptyIterable is true', () {
      var map = {'key1': [], 'key2': 'value2'};
      map.clean(nonEmptyIterables: true);
      expect(map.containsKey('key1'), isFalse);
      expect(map, {'key2': 'value2'});
    });

    test('does not remove empty iterables if emptyIterable is false', () {
      var map = {'key1': [], 'key2': 'value2'};
      map.clean();
      expect(map.containsKey('key1'), isTrue);
      expect(map, {'key1': [], 'key2': 'value2'});
    });

    test('cleans nested maps recursively', () {
      var map = {
        'key1': {
          'nestedKey1': null,
          'nestedKey2': 'nestedValue2',
          'nestedKey3': {},
        },
        'key2': 'value2',
      };
      map.clean();
      expect(map, {
        'key1': {'nestedKey2': 'nestedValue2'},
        'key2': 'value2',
      });
    });
  });

  group('FormxCleanExtension.cleaned', () {
    test('returns a new map with null values removed', () {
      var originalMap = {'key1': null, 'key2': 'value2'};
      var cleanedMap = originalMap.cleaned();
      expect(cleanedMap.containsKey('key1'), isFalse);
      expect(cleanedMap, {'key2': 'value2'});
    });

    test('returns a new map with empty strings removed if emptyString', () {
      var originalMap = {'key1': '', 'key2': 'value2'};
      var cleanedMap = originalMap.cleaned(nonEmptyStrings: true);
      expect(cleanedMap.containsKey('key1'), isFalse);
      expect(cleanedMap, {'key2': 'value2'});
    });

    test('returns a new map with empty strings kept if emptyString is false',
        () {
      var originalMap = {'key1': '', 'key2': 'value2'};
      var cleanedMap = originalMap.cleaned(nonEmptyStrings: false);
      expect(cleanedMap.containsKey('key1'), isTrue);
      expect(cleanedMap, {'key1': '', 'key2': 'value2'});
    });

    test('returns a new map with empty maps removed if emptyMap is true', () {
      var originalMap = {'key1': <String, dynamic>{}, 'key2': 'value2'};
      var cleanedMap = originalMap.cleaned(nonEmptyMaps: true);
      expect(cleanedMap.containsKey('key1'), isFalse);
      expect(cleanedMap, {'key2': 'value2'});
    });

    test('returns a new map with empty maps kept if emptyMap is false', () {
      var originalMap = {'key1': <String, dynamic>{}, 'key2': 'value2'};
      var cleanedMap = originalMap.cleaned(nonEmptyMaps: false);
      expect(cleanedMap.containsKey('key1'), isTrue);
      expect(cleanedMap, {'key1': <String, dynamic>{}, 'key2': 'value2'});
    });

    test('returns a new map with empty iterables removed if emptyIterable', () {
      var originalMap = {'key1': [], 'key2': 'value2'};
      var cleanedMap = originalMap.cleaned(nonEmptyIterables: true);
      expect(cleanedMap.containsKey('key1'), isFalse);
      expect(cleanedMap, {'key2': 'value2'});
    });

    test(
        'returns a new map with empty iterables kept if emptyIterable is false',
        () {
      var originalMap = {'key1': [], 'key2': 'value2'};
      var cleanedMap = originalMap.cleaned(nonEmptyIterables: false);
      expect(cleanedMap.containsKey('key1'), isTrue);
      expect(cleanedMap, {'key1': [], 'key2': 'value2'});
    });

    test('works correctly with nested maps', () {
      var originalMap = {
        'key1': {'nestedKey1': null, 'nestedKey2': 'nestedValue2'},
        'key2': 'value2',
      };
      var cleanedMap = originalMap.cleaned();
      expect(cleanedMap, {
        'key1': {'nestedKey2': 'nestedValue2'},
        'key2': 'value2',
      });
    });
  });
}
