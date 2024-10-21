/// Access, build, validate, sanitize and fill forms easily with Form/Field extensions.
library formx;

export 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
export 'package:material_file_icon/material_file_icon.dart';
export 'package:recase/recase.dart';
export 'package:string_validator/string_validator.dart';

export '/src/extensions/widgets_extension.dart';
export 'src/extensions/context_extension.dart';
export 'src/extensions/field_key_extension.dart';
export 'src/extensions/form_field_state_extension.dart'
    hide FormFieldData, FormFieldStateAttacher;
export 'src/extensions/formx_extension.dart' hide AssertKeysExtension;
export 'src/extensions/formx_state.dart';
export 'src/extensions/sanitizers.dart';
export 'src/extensions/string_extension.dart';
export 'src/extensions/validator_extension.dart';
export 'src/fields/autocomplete_form_field.dart';
export 'src/fields/checkbox_form_field.dart';
export 'src/fields/checkbox_list_form_field.dart';
export 'src/fields/date_form_field.dart';
export 'src/fields/file_form_field.dart';
export 'src/fields/file_list_form_field.dart';
export 'src/fields/radio_list_form_field.dart';
export 'src/fields/search_form_field.dart';
export 'src/models/field_key.dart';
export 'src/models/formx_exception.dart';
export 'src/models/formx_options.dart';
export 'src/models/formx_setup.dart';
export 'src/validator/validator.dart';
