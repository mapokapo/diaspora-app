import 'dart:io';
import 'dart:typed_data';

import 'package:diaspora_app/utils/types_equal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vrouter/vrouter.dart';

class FormBuilderImagePicker<T> extends FormBuilderField<T> {
  FormBuilderImagePicker({required String name, T? initialValue, Key? key})
      : super(
            key: key,
            name: name,
            initialValue: initialValue,
            builder: (_state) {
              final state = _state as _FormBuilderImagePickerState<T>;
              return GestureDetector(
                onTap: () async {
                  state.requestFocus();
                  final picker = ImagePicker();
                  final image =
                      await picker.pickImage(source: ImageSource.gallery);
                  dynamic result;
                  if (typesEqual<T, XFile?>()) {
                    result = image;
                  } else if (typesEqual<T, Uint8List?>()) {
                    result = await image?.readAsBytes();
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
                            ? state.value is XFile
                                ? DecorationImage(
                                    image: FileImage(
                                        File((state.value as XFile).path)),
                                    fit: BoxFit.cover,
                                  )
                                : state.value is Uint8List
                                    ? DecorationImage(
                                        image: MemoryImage(
                                            state.value as Uint8List),
                                        fit: BoxFit.cover,
                                      )
                                    : const DecorationImage(
                                        image: AssetImage(
                                            'assets/images/profile.png'),
                                      )
                            : state.context.vRouter.queryParameters
                                    .containsKey('photoUrl')
                                ? DecorationImage(
                                    image: NetworkImage(state.context.vRouter
                                        .queryParameters['photoUrl']!),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image:
                                        AssetImage('assets/images/profile.png'),
                                  ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25)),
                        border: Border.all(
                          color: Theme.of(state.context)
                              .colorScheme
                              .primaryVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });

  @override
  _FormBuilderImagePickerState<T> createState() =>
      _FormBuilderImagePickerState<T>();
}

class _FormBuilderImagePickerState<T>
    extends FormBuilderFieldState<FormBuilderImagePicker<T>, T> {}
