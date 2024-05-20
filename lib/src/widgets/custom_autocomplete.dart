import 'package:flutter/material.dart';
import 'package:pos/src/constants/color_constants.dart';

class CustomAutocomplete extends StatefulWidget {
  final List<String> datalist;
  final TextEditingController textController;
  final String label;
  final Function(String) onSelected;
  final Function(String) onChanged;
  final Color borderColor;
  final double maxWidth;

  CustomAutocomplete({
    required this.datalist,
    required this.textController,
    required this.label,
    required this.onSelected,
    required this.onChanged,
    this.borderColor = ColorConstants.borderColor,
    this.maxWidth = 300,
  });

  @override
  _CustomAutocompleteState createState() => _CustomAutocompleteState();
}

class _CustomAutocompleteState extends State<CustomAutocomplete> {
  bool tap = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        // if (textEditingValue.text == '') {
        //   return const Iterable<String>.empty();
        // }
        return widget.datalist.where((String option) {
          return option.contains(textEditingValue.text);
        });
      },
      onSelected: (String selection) {
        widget.onSelected(selection);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        textEditingController.text = widget.textController.text;
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: tap ? Theme.of(context).primaryColor : widget.borderColor,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: textEditingController,
            focusNode: focusNode,
            style: Theme.of(context).textTheme.bodyLarge,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) {
              widget.onChanged(value);
            },
            onTap: () {
              setState(() {
                tap = true;
              });
            },
            onTapOutside: (value) {
              focusNode.unfocus();
              setState(() {
                tap = false;
              });
            },
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: widget.maxWidth,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                border: Border.all(color: Colors.transparent),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 7,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              height: 150,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((String option) {
                    return ListTile(
                      title: Text(
                        option,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
