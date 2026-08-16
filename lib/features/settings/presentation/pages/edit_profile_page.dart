import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../domain/services/profile_image_processor.dart';
import '../widgets/profile_avatar.dart';

typedef PickProfileImage = Future<XFile?> Function();

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, this.pickImage});

  final PickProfileImage? pickImage;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();

  Shop? _shop;
  Uint8List? _profileImageBytes;
  bool _clearProfileImage = false;
  bool _processingImage = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (context.read<ShopBloc>().state is! ShopLoaded) {
      context.read<ShopBloc>().add(LoadShopEvent());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _initializeFromShop(Shop shop) {
    if (_shop != null) return;
    _shop = shop;
    _nameController.text = shop.name;
    _profileImageBytes = shop.profileImageBytes;
  }

  Future<XFile?> _pickFromDevice() {
    final injectedPicker = widget.pickImage;
    if (injectedPicker != null) return injectedPicker();
    return _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
      requestFullMetadata: false,
    );
  }

  Future<void> _chooseImage() async {
    if (_processingImage || _saving) return;
    try {
      final picked = await _pickFromDevice();
      if (picked == null || !mounted) return;
      setState(() => _processingImage = true);
      if (await picked.length() > maxProfileImageInputBytes) {
        throw const ProfileImageException(ProfileImageError.inputTooLarge);
      }
      final processed = await processProfileImage(await picked.readAsBytes());
      if (!mounted) return;
      setState(() {
        _profileImageBytes = processed;
        _clearProfileImage = false;
      });
    } on ProfileImageException catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final message =
          error.error == ProfileImageError.invalidImage
              ? l10n.invalidImage
              : l10n.imageTooLarge;
      _showError(message);
    } catch (_) {
      if (mounted) _showError(AppLocalizations.of(context).invalidImage);
    } finally {
      if (mounted) setState(() => _processingImage = false);
    }
  }

  void _removeImage() {
    setState(() {
      _profileImageBytes = null;
      _clearProfileImage = true;
    });
  }

  void _saveProfile() {
    final shop = _shop;
    final formState = _formKey.currentState;
    if (_saving ||
        _processingImage ||
        shop == null ||
        formState == null ||
        !formState.validate()) {
      return;
    }
    setState(() => _saving = true);
    context.read<ShopBloc>().add(
      UpdateShopEvent(
        shop.copyWith(
          name: _nameController.text.trim(),
          profileImageBytes: _profileImageBytes,
          clearProfileImage: _clearProfileImage,
        ),
      ),
    );
  }

  void _showError(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: scheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: BlocConsumer<ShopBloc, ShopState>(
        listener: (context, state) {
          if (state is ShopLoaded) {
            _initializeFromShop(state.shop);
          } else if (state is ShopOperationSuccess) {
            setState(() => _saving = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.profileUpdated)));
            context.pop();
          } else if (state is ShopError) {
            final wasSaving = _saving;
            setState(() => _saving = false);
            if (wasSaving) _showError(l10n.profileUpdateFailed);
          }
        },
        builder: (context, state) {
          if (state is ShopLoaded) _initializeFromShop(state.shop);
          final shop = _shop;
          if (shop == null) {
            if (state is ShopError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_outlined,
                        size: 48,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.profileLoadFailed, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed:
                            () => context.read<ShopBloc>().add(LoadShopEvent()),
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ProfileAvatar(
                          name:
                              _nameController.text.isEmpty
                                  ? shop.name
                                  : _nameController.text,
                          imageBytes: _profileImageBytes,
                          size: 128,
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: Material(
                            color: scheme.primary,
                            shape: const CircleBorder(),
                            child: IconButton(
                              key: const ValueKey('choose-profile-image'),
                              tooltip: l10n.chooseProfileImage,
                              onPressed:
                                  _processingImage || _saving
                                      ? null
                                      : _chooseImage,
                              color: scheme.onPrimary,
                              icon:
                                  _processingImage
                                      ? SizedBox.square(
                                        dimension: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: scheme.onPrimary,
                                        ),
                                      )
                                      : const Icon(Icons.photo_camera_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed:
                            _processingImage || _saving ? null : _chooseImage,
                        icon: const Icon(Icons.image_outlined),
                        label: Text(l10n.changePhoto),
                      ),
                      if (_profileImageBytes != null)
                        TextButton.icon(
                          onPressed: _saving ? null : _removeImage,
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.removePhoto),
                          style: TextButton.styleFrom(
                            foregroundColor: scheme.error,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    l10n.profileImageHelp,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  InputLabel(text: l10n.displayName),
                  TextFormField(
                    key: const ValueKey('profile-name-field'),
                    controller: _nameController,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(hintText: l10n.displayNameHint),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? l10n.nameRequired
                                : null,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.editProfileSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar:
          _shop == null
              ? null
              : SafeArea(
                minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: PrimaryButton(
                  onPressed: _saving || _processingImage ? null : _saveProfile,
                  isLoading: _saving,
                  icon: Icons.save_outlined,
                  label: _saving ? l10n.saving : l10n.save,
                ),
              ),
    );
  }
}
