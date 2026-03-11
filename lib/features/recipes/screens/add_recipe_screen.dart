import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/recipe_data.dart';
import '../services/recipe_service.dart';
import '../services/ai_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  // removed _imageUrlController
  
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  bool _isAnalyzing = false;

  Future<void> _analyzeWithAi() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final aiResult = await AiService.analyzeRecipeFromImage(_selectedImage!);
      
      if (aiResult != null && mounted) {
        setState(() {
          _titleController.text = aiResult['title'] ?? '';
          _descController.text = aiResult['description'] ?? '';
          _caloriesController.text = aiResult['calories']?.toString() ?? '';
          _proteinController.text = aiResult['protein']?.toString() ?? '';
          _fatController.text = aiResult['fat']?.toString() ?? '';
          _carbsController.text = aiResult['carbs']?.toString() ?? '';
          
          // Clear and refill ingredients
          _ingredientControllers.clear();
          if (aiResult['ingredients'] is List) {
            for (var ing in aiResult['ingredients']) {
              _ingredientControllers.add(TextEditingController(text: ing.toString()));
            }
          }
          if (_ingredientControllers.isEmpty) {
            _addIngredientField();
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil menganalisis gambar!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menganalisis: \$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  // Lists
  final List<TextEditingController> _ingredientControllers = [];
  final List<TextEditingController> _instructionControllers = [];
  
  // Selections
  final List<String> _selectedGoals = [];
  final List<String> _selectedMealTypes = [];
  bool _isHalal = true;
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isLowCarb = false;

  @override
  void initState() {
    super.initState();
    _addIngredientField(); // Add initial field
    _addInstructionField(); // Add initial field
  }

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers.removeAt(index);
    });
  }

  void _addInstructionField() {
    setState(() {
      _instructionControllers.add(TextEditingController());
    });
  }

  void _removeInstructionField(int index) {
    setState(() {
      _instructionControllers.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      // Validate lists
      final ingredients = _ingredientControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      
      final instructions = _instructionControllers
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (ingredients.isEmpty || instructions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon isi minimal 1 bahan dan instruksi')),
        );
        return;
      }

      final newRecipe = Recipe(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        calories: int.tryParse(_caloriesController.text) ?? 0,
        protein: int.tryParse(_proteinController.text) ?? 0,
        fat: int.tryParse(_fatController.text) ?? 0,
        carbs: int.tryParse(_carbsController.text) ?? 0,
        imageUrl: _selectedImage != null ? _selectedImage!.path : '', 
        ingredients: ingredients,
        instructions: instructions,
        tags: 'User Generated', // Default tag
        dietGoals: _selectedGoals,
        mealTypes: _selectedMealTypes,
        isHalal: _isHalal,
        isVegetarian: _isVegetarian,
        isVegan: _isVegan,
        isLowCarb: _isLowCarb,
      );

      await RecipeService.addRecipe(newRecipe);

      if (mounted) {
        Navigator.pop(context, true); // Return true to signal refresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Resep Baru'),
         backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Info Dasar'),
            
            // Image Picker Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                image: _selectedImage != null 
                  ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                  : null
              ),
              child: _selectedImage == null 
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Pilih foto makanan", style: TextStyle(color: Colors.grey))
                    ],
                  )
                : null,
            ),
            
            // AI Analyze Button
            if (_selectedImage != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeWithAi,
                  icon: _isAnalyzing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                  label: Text(_isAnalyzing ? 'Sedang Menganalisis...' : 'Hitung Kalori dengan AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            _buildTextField(_titleController, 'Nama Masakan', required: true),
            _buildTextField(_descController, 'Deskripsi Singkat', maxLines: 2, required: true),
            // _buildTextField(_imageUrlController, 'URL Gambar (Opsional)', hint: 'https://...'), // Removed

            const SizedBox(height: 20),
            _buildSectionTitle('Nutrisi (per porsi)'),
            Row(
              children: [
                Expanded(child: _buildTextField(_caloriesController, 'Kalori', isNumber: true, required: true)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(_proteinController, 'Protein (g)', isNumber: true, required: true)),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildTextField(_fatController, 'Lemak (g)', isNumber: true, required: true)),
                const SizedBox(width: 10),
                Expanded(child: _buildTextField(_carbsController, 'Karbo (g)', isNumber: true, required: true)),
              ],
            ),

            const SizedBox(height: 20),
            _buildSectionTitle('Preferensi & Kategori'),
            _buildCheckbox('Halal', _isHalal, (v) => setState(() => _isHalal = v!)),
            _buildCheckbox('Vegetarian', _isVegetarian, (v) => setState(() => _isVegetarian = v!)),
            _buildCheckbox('Vegan', _isVegan, (v) => setState(() => _isVegan = v!)),
            _buildCheckbox('Low Carb', _isLowCarb, (v) => setState(() => _isLowCarb = v!)),
            
            const SizedBox(height: 10),
            const Text("Waktu Makan:", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ['breakfast', 'lunch', 'dinner', 'snack'].map((type) {
                final isSelected = _selectedMealTypes.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) _selectedMealTypes.add(type);
                      else _selectedMealTypes.remove(type);
                    });
                  },
                );
              }).toList(),
            ),
             const SizedBox(height: 10),
            const Text("Tujuan Diet:", style: TextStyle(fontWeight: FontWeight.bold)),
             Wrap(
              spacing: 8,
              children: ['fatLoss', 'maintenance', 'muscleGain'].map((goal) {
                final isSelected = _selectedGoals.contains(goal);
                return FilterChip(
                  label: Text(goal),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) _selectedGoals.add(goal);
                      else _selectedGoals.remove(goal);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle('Bahan-bahan'),
            ..._ingredientControllers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(child: _buildTextField(entry.value, 'Bahan ${entry.key + 1}')),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeIngredientField(entry.key),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addIngredientField,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Bahan'),
            ),

            const SizedBox(height: 20),
             _buildSectionTitle('Cara Membuat'),
            ..._instructionControllers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(child: _buildTextField(entry.value, 'Langkah ${entry.key + 1}', maxLines: 2)),
                    IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeInstructionField(entry.key),
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: _addInstructionField,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Langkah'),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Simpan Resep', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
             const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, int maxLines = 1, bool required = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        validator: required ? (v) => v == null || v.isEmpty ? 'Wajib diisi' : null : null,
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
