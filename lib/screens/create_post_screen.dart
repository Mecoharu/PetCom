import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/adoption_service.dart';
import '../services/auth_service.dart';
import '../models/adoption_post.dart';
import '../widgets/widgets.dart';




class CreatePostScreen extends ConsumerStatefulWidget {
  final String? editPostId;
  const CreatePostScreen({super.key, this.editPostId});
  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _form = GlobalKey<FormState>();
  final _petName = TextEditingController();
  final _breed = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();

  PetType _type = PetType.dog;
  PetGender _gender = PetGender.male;
  bool _vaccinated = false, _neutered = false;
  List<File> _images = [];
  List<String> _existingUrls = [];
  bool _loading = false;
  AdoptionPost? _existing;


  @override
  void initState() {
    super.initState();
    if (widget.editPostId != null) _loadExisting();
  }

  @override
  void dispose() {
    _petName.dispose();
    _breed.dispose();
    _ageCtrl.dispose();
    _desc.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    final post =
        await ref.read(adoptionServiceProvider).getPost(widget.editPostId!);
    if (post != null && mounted) {
      setState(() {
        _existing = post;
        _petName.text = post.petName;
        _breed.text = post.breed;
        _ageCtrl.text = post.ageMonths.toString();
        _desc.text = post.description;
        _location.text = post.location;
        _type = post.petType;
        _gender = post.gender;
        _vaccinated = post.isVaccinated;
        _neutered = post.isNeutered;
        _existingUrls = post.photoUrls;
      });
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickMultiImage(maxWidth: 1080, imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() => _images = picked.map((x) => File(x.path)).toList());
    }
  }

  void _showSnack(String msg, {Color color = Colors.orange}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _save() async {
  print('SAVE — images: ${_images.length}, existingUrls: ${_existingUrls.length}, existing: $_existing');
  if (!_form.currentState!.validate()) return;
  
   
if (_images.isEmpty && _existingUrls.isEmpty) {
  _showSnack('Please add photo');
  return;
    }

    setState(() => _loading = true);

    try {
      final appUser = ref.read(appUserProvider).asData?.value;
      final service = ref.read(adoptionServiceProvider);

      if (_existing != null) {
        final updated = _existing!.copyWith(
          petName: _petName.text.trim(),
          petType: _type,
          breed: _breed.text.trim(),
          ageMonths: int.tryParse(_ageCtrl.text) ?? 0,
          gender: _gender,
          description: _desc.text.trim(),
          isVaccinated: _vaccinated,
          isNeutered: _neutered,
          location: _location.text.trim(),
        );
        await service.updatePost(updated);
      } else {
        final post = service.buildPost(
          ownerName: appUser?.fullName ?? 'Anonymous',
          ownerPhotoUrl: appUser?.photoUrl ?? '',
          petName: _petName.text.trim(),
          petType: _type,
          breed: _breed.text.trim(),
          ageMonths: int.tryParse(_ageCtrl.text) ?? 0,
          gender: _gender,
          description: _desc.text.trim(),
          isVaccinated: _vaccinated,
          isNeutered: _neutered,
          location: _location.text.trim(),
        );
       await service.createPost(post: post);
      }

      if (mounted) {
        _showSnack(
          _existing != null ? ' Post updated!' : 'Post published!',
          color: const Color(0xFF4CAF50),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) _showSnack('Failed: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editPostId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Post' : 'Open Adoption'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _form,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Photo
              _SectionTitle('Photo *'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8622A),
                      width: 1.5,
                    ),
                  ),
                  child: _images.isEmpty && _existingUrls.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined,
                                size: 40, color: Color(0xFFE8622A)),
                            const SizedBox(height: 8),
                            Text('Tap to add photo',
                                style: GoogleFonts.nunito(
                                    color: const Color(0xFFE8622A),
                                    fontWeight: FontWeight.w700)),
                          ],
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: _images.isNotEmpty
                              ? _images.length
                              : _existingUrls.length,
                          itemBuilder: (_, i) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 130,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _images.isNotEmpty
                                  ? Image.file(_images[i], fit: BoxFit.cover)
                                  : Image.network(_existingUrls[i],
                                      fit: BoxFit.cover),
                            ),
                          ),
                        ),
                ),
              ),
              if (_images.isNotEmpty || _existingUrls.isNotEmpty)
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Change Photo'),
                  style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFE8622A)),
                ),

              const SizedBox(height: 20),

              //Pet Type
              _SectionTitle('Types of Animals *'),
              const SizedBox(height: 10),
              _typeSelector(),
              const SizedBox(height: 16),

              // Name 
              AppTextField(
                controller: _petName,
                label: 'Name *',
          
                prefixIcon: Icons.pets,
                validator: (v) => v?.isEmpty == true ? 'Name required' : null,
              ),
              const SizedBox(height: 14),

              //Breed & Age 
              Row(children: [
                Expanded(
                  child: AppTextField(
                    controller: _breed,
                    label: 'Breed',
                    prefixIcon: Icons.category_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: _ageCtrl,
                    label: 'Age *',
                    prefixIcon: Icons.cake_outlined,
                    validator: (v) =>
                        v?.isEmpty == true ? 'Age required' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 14),
  
              // Gender 
              _SectionTitle('Gender *'),
              const SizedBox(height: 8),
              Row(children: [
                _ToggleBtn(
                  label: '♂ Male',
                  selected: _gender == PetGender.male,
                  onTap: () => setState(() => _gender = PetGender.male),
                ),
                const SizedBox(width: 10),
                _ToggleBtn(
                  label: '♀ Female',
                  selected: _gender == PetGender.female,
                  onTap: () => setState(() => _gender = PetGender.female),
                ),
              ]),
              const SizedBox(height: 14),

            
              // Location 
              AppTextField(
                controller: _location,
                label: 'Location *',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) =>
                    v?.isEmpty == true ? 'Location required' : null,
              ),
              const SizedBox(height: 14),

              // Description
              AppTextField(
                controller: _desc,
                label: 'Description *',
                hint: 'Describe the pet\'s personality, habits, condition...',
                prefixIcon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) =>
                    v?.isEmpty == true ? 'Description required' : null,
              ),
              const SizedBox(height: 16),

              //Health 
              _SectionTitle('Health Condition'),
              const SizedBox(height: 8),
              _CheckItem(
                label: '💉 Vaccinated',
                value: _vaccinated,
                onChanged: (v) => setState(() => _vaccinated = v!),
              ),
              _CheckItem(
                label: '✂️ Neutered / Spayed',
                value: _neutered,
                onChanged: (v) => setState(() => _neutered = v!),
              ),
              

              const SizedBox(height: 32),

              PrimaryButton(
                label: isEdit ? 'Save Changes' : 'Publish Post',
                onPressed: _save,
                isLoading: _loading,
                icon: isEdit ? Icons.save : Icons.upload,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeSelector() {
    return SizedBox(
      height: 76,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: PetType.values.map((t) {
          final sel = _type == t;
          return GestureDetector(
            onTap: () => setState(() => _type = t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? const Color(0xFFE8622A) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel
                      ? const Color(0xFFE8622A)
                      : const Color(0xFFEDD5C0),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_typeEmoji(t),
                      style: const TextStyle(fontSize: 24)),
                  Text(
                    _typeLabel(t),
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : const Color(0xFF2C1810),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _typeEmoji(PetType t) {
    switch (t) {
      case PetType.dog: return '🐕';
      case PetType.cat: return '🐈';
      case PetType.bird: return '🦜';
      case PetType.reptile: return '🦎';
      default: return '🐾';
    }
  }

  String _typeLabel(PetType t) {
    switch (t) {
      case PetType.dog: return 'Dog';
      case PetType.cat: return 'Cat';
      case PetType.bird: return 'Bird';
      case PetType.reptile: return 'Reptile';
      default: return 'Others';
    }
  }
}


class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2C1810),
        ),
      );
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleBtn(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE8622A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFFE8622A)
                    : const Color(0xFFEDD5C0),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: selected ? Colors.white : const Color(0xFF2C1810),
                ),
              ),
            ),
          ),
        ),
      );
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool?) onChanged;
  const _CheckItem(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => CheckboxListTile(
        title: Text(label,
            style:
                GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 14)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFE8622A),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
}