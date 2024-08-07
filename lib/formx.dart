/// Build, validate and fill forms easily with extended Form and TextFormField.
library formx;

export 'package:formx/src/extensions/widgets_extension.dart';
export 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
export 'package:recase/recase.dart';
export 'package:string_validator/string_validator.dart';

export 'src/extensions/context_extension.dart';
export 'src/extensions/form_field_state_extension.dart'
    hide FormFieldData, FormFieldStateAttacher;
export 'src/extensions/form_state_extension.dart' hide AssertKeysExtension;
export 'src/extensions/sanitizers.dart';
export 'src/extensions/string_extension.dart';
export 'src/extensions/validator_extension.dart';
export 'src/fields/autocomplete_form_field.dart';
export 'src/fields/checkbox_form_field.dart';
export 'src/fields/checkbox_list_form_field.dart';
export 'src/fields/date_form_field.dart';
export 'src/fields/radio_list_form_field.dart';
export 'src/fields/search_form_field.dart';
export 'src/formx_state.dart';
export 'src/validator/validator.dart';
