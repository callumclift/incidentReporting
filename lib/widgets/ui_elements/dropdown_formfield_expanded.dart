import 'package:flutter/material.dart';
import 'fix_dropdown.dart' as fix;

class DropdownFormFieldExpanded extends StatefulWidget {
  final String hint;
  final String value;
  final List<String> items;
  final Function onChanged;
  final Function validator;
  final Function onSaved;
  final String initialValue;
  final bool expanded;

  DropdownFormFieldExpanded({
    @required this.hint,
    @required this.value,
    @required this.items,
    @required this.onChanged,
    @required this.validator,
    @required this.initialValue,
    @required this.onSaved,
    @required this.expanded
  });

  @override
  State<StatefulWidget> createState() {
    return _DropdownFormFieldExpanded();
  }
}

class _DropdownFormFieldExpanded extends State<DropdownFormFieldExpanded> {
  @override
  Widget build(BuildContext context) {
    return FormField(
      initialValue: widget.initialValue,
      onSaved: (val) => widget.onSaved,
      validator: widget.validator,
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: widget.value.toString().length > 40? InputDecoration(contentPadding: EdgeInsets.symmetric(vertical: 20.0),
            labelText: widget.hint,
            errorText: state.hasError ? state.errorText : null,
          ) : InputDecoration(
            labelText: widget.hint,
            errorText: state.hasError ? state.errorText : null,
          ),
          isEmpty: widget.value == '' || widget.value == null,
          child: fix.DropdownButtonHideUnderline(
            child: fix.FixDropDown(
              value: widget.value,
              isDense: widget.expanded ? false : true,
              onChanged: (dynamic newValue) {
                state.didChange(newValue);
                widget.onChanged(newValue);
              },
              items: widget.items.map((dynamic value) {
                return fix.FixDropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
