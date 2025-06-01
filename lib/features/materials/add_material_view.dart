import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../shared/loading_overlay.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'add_material_viewmodel.dart';

class AddMaterialView extends StackedView<AddMaterialViewModel> {
  final String? materialId; // For editing existing materials

  const AddMaterialView({super.key, this.materialId});

  @override
  Widget builder(
      BuildContext context,
      AddMaterialViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          viewModel.isEditing ? 'Edit Material' : 'Add New Material',
          style: heading3Style(context).copyWith(color: Colors.white),
        ),
        backgroundColor: kcPrimaryColor,
        actions: [
          if (viewModel.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: viewModel.deleteMaterial,
              tooltip: 'Delete Material',
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: viewModel.isBusy,
        loadingText: viewModel.isEditing ? 'Updating material...' : 'Adding material...',
        child: Form(
          key: viewModel.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Material Information Card
                _buildCard(
                  context,
                  title: 'Material Information',
                  children: [
                    _buildTextField(
                      label: 'Material Name',
                      controller: viewModel.nameController,
                      validator: viewModel.validateRequired,
                      prefixIcon: Icons.inventory_2,
                    ),
                    verticalSpaceMedium,
                    _buildDropdown(
                      context,
                      label: 'Material Type',
                      value: viewModel.selectedType,
                      items: viewModel.materialTypes,
                      onChanged: viewModel.setSelectedType,
                      prefixIcon: Icons.category,
                      validator: viewModel.validateRequired,
                    ),
                    verticalSpaceMedium,
                    _buildDropdown(
                      context,
                      label: 'Unit of Measurement',
                      value: viewModel.selectedUnit,
                      items: viewModel.unitOptions,
                      onChanged: viewModel.setSelectedUnit,
                      prefixIcon: Icons.straighten,
                      validator: viewModel.validateRequired,
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Stock Information Card
                _buildCard(
                  context,
                  title: 'Stock Information',
                  children: [
                    _buildTextField(
                      label: 'Current Stock',
                      controller: viewModel.stockController,
                      validator: viewModel.validateStock,
                      prefixIcon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    verticalSpaceMedium,
                    _buildTextField(
                      label: 'Minimum Stock Level',
                      controller: viewModel.minStockController,
                      validator: viewModel.validateMinStock,
                      prefixIcon: Icons.warning,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    verticalSpaceSmall,
                    Text(
                      'System will alert when stock falls below minimum level',
                      style: captionStyle(context),
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Location & Pricing Card
                _buildCard(
                  context,
                  title: 'Location & Pricing',
                  children: [
                    _buildDropdown(
                      context,
                      label: 'Storage Location',
                      value: viewModel.selectedLocation,
                      items: viewModel.storageLocations,
                      onChanged: viewModel.setSelectedLocation,
                      prefixIcon: Icons.location_on,
                      validator: viewModel.validateRequired,
                    ),
                    verticalSpaceMedium,
                    _buildTextField(
                      label: 'Price per Unit (Rp)',
                      controller: viewModel.priceController,
                      validator: viewModel.validatePrice,
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Supplier Information Card
                _buildCard(
                  context,
                  title: 'Supplier Information (Optional)',
                  children: [
                    _buildTextField(
                      label: 'Supplier Name',
                      controller: viewModel.supplierController,
                      prefixIcon: Icons.business,
                    ),
                    verticalSpaceMedium,
                    _buildTextField(
                      label: 'Supplier Contact',
                      controller: viewModel.supplierContactController,
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Additional Notes Card
                _buildCard(
                  context,
                  title: 'Additional Information',
                  children: [
                    _buildTextField(
                      label: 'Material Description',
                      controller: viewModel.descriptionController,
                      maxLines: 3,
                      prefixIcon: Icons.description,
                    ),
                    verticalSpaceMedium,
                    _buildTextField(
                      label: 'Notes',
                      controller: viewModel.notesController,
                      maxLines: 2,
                      prefixIcon: Icons.note,
                    ),
                  ],
                ),
                verticalSpaceLarge,

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: viewModel.isBusy ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: kcPrimaryColor),
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
                        onPressed: viewModel.isBusy ? null : viewModel.saveMaterial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kcPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          viewModel.isEditing ? 'Update Material' : 'Add Material',
                          style: buttonTextStyle(context),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpaceLarge,

                // Quick Stock Actions (for editing)
                if (viewModel.isEditing) ...[
                  _buildCard(
                    context,
                    title: 'Quick Stock Actions',
                    children: [
                      Text(
                        'Adjust stock without creating a new entry',
                        style: captionStyle(context),
                      ),
                      verticalSpaceMedium,
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: viewModel.showStockInDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kcSuccessColor,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Stock In'),
                            ),
                          ),
                          horizontalSpaceMedium,
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: viewModel.showStockOutDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kcWarningColor,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.remove),
                              label: const Text('Stock Out'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  verticalSpaceLarge,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        required List<Widget> children,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: defaultBoxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: heading4Style(context),
          ),
          verticalSpaceMedium,
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>(
      BuildContext context, {
        required String label,
        required T? value,
        required List<T> items,
        required void Function(T?) onChanged,
        IconData? prefixIcon,
        String? Function(T?)? validator,
      }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
    );
  }

  @override
  AddMaterialViewModel viewModelBuilder(BuildContext context) =>
      AddMaterialViewModel(materialId: materialId);

  @override
  void onViewModelReady(AddMaterialViewModel viewModel) => viewModel.init();
}