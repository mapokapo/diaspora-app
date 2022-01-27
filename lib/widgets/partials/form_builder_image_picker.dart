import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vrouter/vrouter.dart';

class FormBuilderImagePicker extends StatefulWidget {
  final String name;
  final Uint8List? initialValue;
  const FormBuilderImagePicker(
      {required this.name, this.initialValue, Key? key})
      : super(key: key);

  @override
  _FormBuilderImagePickerState createState() => _FormBuilderImagePickerState();
}

class _FormBuilderImagePickerState extends State<FormBuilderImagePicker> {
  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
      name: widget.name,
      key: widget.key,
      initialValue: widget.initialValue,
      builder: (state) {
        return GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final imageFile =
                await picker.pickImage(source: ImageSource.gallery);
            Uint8List? result;
            if (imageFile != null) {
              result = await FlutterImageCompress.compressWithFile(
                imageFile.path,
                format: CompressFormat.webp,
                minWidth: 900,
                minHeight: 900,
                quality: 90,
              );
            }
            state.didChange(result);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 96),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(state.context).colorScheme.primary,
                  image: state.value != null
                      ? state.value is Uint8List
                          ? DecorationImage(
                              image: MemoryImage(state.value as Uint8List),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/profile.png'),
                            )
                      : state.context.vRouter.queryParameters
                              .containsKey('photoUrl')
                          ? DecorationImage(
                              image: NetworkImage(state.context.vRouter
                                  .queryParameters['photoUrl']!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: AssetImage('assets/images/profile.png'),
                            ),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  border: Border.all(
                    color: Theme.of(state.context).colorScheme.primaryVariant,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
