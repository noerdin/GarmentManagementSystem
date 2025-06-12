import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ui/app_colors.dart';
import '../ui/text_style.dart';
import '../ui/ui_helpers.dart';

class AddMaterialDialog extends StatefulWidget {
  final List<String> materialTypes;
  final List<String> unitOptions;
  final String? productType; // For auto-suggestions

  const AddMaterialDialog({
    super.key,
    required this.materialTypes,
    required this.unitOptions,
    this.productType,
  });

  @override
  State<AddMaterialDialog> createState() => _AddMaterialDialogState();
}

class _AddMaterialDialogState extends State<AddMaterialDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Selected values
  String _selectedType = 'Bahan';
  String _selectedUnit = 'meter';

  // Material suggestions
  List<String> _materialSuggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.materialTypes.first;
    _selectedUnit = widget.unitOptions.first;
    _generateMaterialSuggestions();

    // Listen to name changes for suggestions
    _nameController.addListener(_onNameChanged);
  }

  void _generateMaterialSuggestions() {
    if (widget.productType == null) return;

    final productType = widget.productType!.toLowerCase();

    if (productType.contains('t-shirt') || productType.contains('kaos')) {
      _materialSuggestions = [
        'Cotton Fabric',
        'Thread - Cotton',
        'Thread - Polyester',
        'Size Label',
        'Brand Label',
        'Care Label',
        'Plastic Bag',
        'Hangtag',
      ];
    } else if (productType.contains('polo')) {
      _materialSuggestions = [
        'Polo Cotton Fabric',
        'Collar Fabric',
        'Buttons',
        'Thread - Various Colors',
        'Size Label',
        'Brand Label',
        'Plastic Bag',
      ];
    } else if (productType.contains('jacket') || productType.contains('jaket')) {
      _materialSuggestions = [
        'Outer Fabric',
        'Lining Fabric',
        'Zipper',
        'Thread - Various Colors',
        'Velcro',
        'Care Instructions Label',
        'Hangtag',
        'Plastic Bag',
      ];
    } else {
      _materialSuggestions = [
        'Fabric',
        'Thread',
        'Labels',
        'Packaging',
        'Buttons',
        'Zipper',
      ];
    }
  }

  void _onNameChanged() {
    final text = _nameController.text.toLowerCase();
    if (text.isNotEmpty && text.length >= 2) {
      setState(() {
        _showSuggestions = _materialSuggestions.any((s) =>
            s.toLowerCase().contains(text));
      });
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  List<String> _getFilteredSuggestions() {
    final text = _nameController.text.toLowerCase();
    return _materialSuggestions.where((s) =>
        s.toLowerCase().contains(text)).toList();
  }

  void _selectSuggestion(String suggestion) {
    _nameController.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });

    // Auto-fill some fields based on material type
    _autoFillFields(suggestion);
  }

  void _autoFillFields(String materialName) {
    final lowerName = materialName.toLowerCase();

    // Auto-select material type
    if (lowerName.contains('fabric') || lowerName.contains('cloth')) {
      setState(() {
        _selectedType = 'Bahan';
        _selectedUnit = 'meter';
      });
    } else if (lowerName.contains('thread') || lowerName.contains('benang')) {
      setState(() {
        _selectedType = 'Aksesoris';
        _selectedUnit = 'roll';
      });
    } else if (lowerName.contains('label') || lowerName.contains('tag')) {
      setState(() {
        _selectedType = 'Aksesoris';
        _selectedUnit = 'piece';
      });
    } else if (lowerName.contains('button') || lowerName.contains('zipper')) {
      setState(() {
        _selectedType = 'Aksesoris';
        _selectedUnit = 'piece';
      });
    }

    // Auto-suggest prices (you can adjust these)
    if (lowerName.contains('fabric')) {
      _priceController.text = '25000';
    } else if (lowerName.contains('thread')) {
      _priceController.text = '15000';
    } else if (lowerName.contains('label')) {
      _priceController.text = '500';
    } else if (lowerName.contains('button')) {
      _priceController.text = '1000';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_box,
                    color: kcPrimaryColor,
                    size: 24,
                  ),
                ),
                horizontalSpaceSmall,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Material Requirement',
                        style: heading3Style(context),
                      ),
                      if (widget.productType != null)
                        Text(
                          'For ${widget.productType}',
                          style: captionStyle(context),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            verticalSpaceLarge,

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Material Name with suggestions
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Material Name *',
                              prefixIcon: Icon(Icons.inventory_2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: kcPrimaryColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Material name is required';
                              }
                              return null;
                            },
                          ),

                          // Suggestions dropdown
                          if (_showSuggestions && _getFilteredSuggestions().isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: kcLightGrey),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Column(
                                children: _getFilteredSuggestions().take(5).map((suggestion) =>
                                    ListTile(
                                      dense: true,
                                      title: Text(suggestion, style: bodyStyle(context)),
                                      leading: Icon(Icons.lightbulb_outline,
                                          color: kcWarningColor, size: 16),
                                      onTap: () => _selectSuggestion(suggestion),
                                    )
                                ).toList(),
                              ),
                            ),
                        ],
                      ),
                      verticalSpaceMedium,

                      // Material Type Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Material Type *',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kcPrimaryColor, width: 2),
                          ),
                        ),
                        items: widget.materialTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      verticalSpaceMedium,

                      // Quantity and Unit Row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: InputDecoration(
                                labelText: 'Quantity *',
                                prefixIcon: Icon(Icons.numbers),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: kcPrimaryColor, width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Quantity is required';
                                }
                                final quantity = double.tryParse(value);
                                if (quantity == null || quantity <= 0) {
                                  return 'Enter valid quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                          horizontalSpaceSmall,
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedUnit,
                              decoration: InputDecoration(
                                labelText: 'Unit *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: kcPrimaryColor, width: 2),
                                ),
                              ),
                              items: widget.unitOptions.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      verticalSpaceMedium,

                      // Estimated Price
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Estimated Price per Unit (Rp) *',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kcPrimaryColor, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Price is required';
                          }
                          final price = double.tryParse(value);
                          if (price == null || price <= 0) {
                            return 'Enter valid price';
                          }
                          return null;
                        },
                      ),
                      verticalSpaceMedium,

                      // Supplier (Optional)
                      TextFormField(
                        controller: _supplierController,
                        decoration: InputDecoration(
                          labelText: 'Preferred Supplier (Optional)',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kcPrimaryColor, width: 2),
                          ),
                        ),
                      ),
                      verticalSpaceMedium,

                      // Notes (Optional)
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          prefixIcon: Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: kcPrimaryColor, width: 2),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            verticalSpaceLarge,

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: kcPrimaryColor),
                    ),
                    child: Text(
                      'Cancel',
                      style: buttonTextStyle(context).copyWith(
                        color: kcPrimaryColor,
                      ),
                    ),
                  ),
                ),
                horizontalSpaceMedium,
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveMaterial,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Add Material',
                      style: buttonTextStyle(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveMaterial() {
    if (_formKey.currentState!.validate()) {
      final result = {
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'quantity': _quantityController.text.trim(),
        'unit': _selectedUnit,
        'price': _priceController.text.trim(),
        'supplier': _supplierController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      Navigator.pop(context, result);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}