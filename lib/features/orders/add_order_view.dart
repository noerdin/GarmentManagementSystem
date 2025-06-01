import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../shared/loading_overlay.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'add_order_viewmodel.dart';

class AddOrderView extends StackedView<AddOrderViewModel> {
  final String? orderId; // For editing existing orders

  const AddOrderView({super.key, this.orderId});

  @override
  Widget builder(
      BuildContext context,
      AddOrderViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          viewModel.isEditing ? 'Edit Order' : 'Add New Order',
          style: heading3Style(context).copyWith(color: Colors.white),
        ),
        backgroundColor: kcPrimaryColor,
        actions: [
          if (viewModel.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: viewModel.deleteOrder,
              tooltip: 'Delete Order',
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: viewModel.isBusy,
        loadingText: viewModel.isEditing ? 'Updating order...' : 'Creating order...',
        child: Form(
          key: viewModel.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information Card
                _buildCard(
                  context,
                  title: 'Customer Information',
                  children: [
                    _buildTextField(
                      label: 'Customer Name',
                      controller: viewModel.customerNameController,
                      validator: viewModel.validateRequired,
                      prefixIcon: Icons.person,
                    ),
                    verticalSpaceMedium,
                    _buildTextField(
                      label: 'Customer Address (Optional)',
                      controller: viewModel.customerAddressController,
                      maxLines: 2,
                      prefixIcon: Icons.location_on,
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Product Information Card
                _buildCard(
                  context,
                  title: 'Product Information',
                  children: [
                    _buildTextField(
                      label: 'Product Name',
                      controller: viewModel.productNameController,
                      validator: viewModel.validateRequired,
                      prefixIcon: Icons.shopping_bag,
                    ),
                    verticalSpaceMedium,
                    _buildDropdown(
                      context,
                      label: 'Product Category',
                      value: viewModel.selectedCategory,
                      items: viewModel.productCategories,
                      onChanged: viewModel.setSelectedCategory,
                      prefixIcon: Icons.category,
                    ),
                    verticalSpaceMedium,
                    _buildDropdown(
                      context,
                      label: 'Color',
                      value: viewModel.selectedColor,
                      items: viewModel.availableColors,
                      onChanged: viewModel.setSelectedColor,
                      prefixIcon: Icons.palette,
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Size & Quantity Card
                _buildCard(
                  context,
                  title: 'Size & Quantity',
                  children: [
                    Text(
                      'Select sizes and quantities:',
                      style: bodyStyle(context),
                    ),
                    verticalSpaceSmall,
                    ...viewModel.availableSizes.map((size) =>
                        _buildSizeQuantityRow(context, viewModel, size),
                    ).toList(),
                    verticalSpaceSmall,
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kcPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Quantity:',
                            style: bodyBoldStyle(context),
                          ),
                          Text(
                            '${viewModel.totalQuantity}',
                            style: heading4Style(context).copyWith(
                              color: kcPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Deadline & Priority Card
                _buildCard(
                  context,
                  title: 'Schedule & Priority',
                  children: [
                    _buildDateField(
                      context,
                      label: 'Production Deadline',
                      selectedDate: viewModel.selectedDeadline,
                      onTap: () => viewModel.selectDeadline(context),
                      validator: viewModel.validateDeadline,
                    ),
                    verticalSpaceMedium,
                    _buildDropdown(
                      context,
                      label: 'Priority',
                      value: viewModel.selectedPriority,
                      items: viewModel.priorityLevels,
                      onChanged: viewModel.setSelectedPriority,
                      prefixIcon: Icons.flag,
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Notes Card
                _buildCard(
                  context,
                  title: 'Additional Notes',
                  children: [
                    _buildTextField(
                      label: 'Order Notes (Optional)',
                      controller: viewModel.notesController,
                      maxLines: 3,
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
                        onPressed: viewModel.isBusy ? null : viewModel.saveOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kcPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          viewModel.isEditing ? 'Update Order' : 'Create Order',
                          style: buttonTextStyle(context),
                        ),
                      ),
                    ),
                  ],
                ),
                verticalSpaceLarge,
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
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
      }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
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

  Widget _buildDateField(
      BuildContext context, {
        required String label,
        required DateTime? selectedDate,
        required VoidCallback onTap,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
        ),
      ),
      controller: TextEditingController(
        text: selectedDate != null ? formatDate(selectedDate) : '',
      ),
    );
  }

  Widget _buildSizeQuantityRow(
      BuildContext context,
      AddOrderViewModel viewModel,
      String size,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              size,
              style: bodyBoldStyle(context),
            ),
          ),
          horizontalSpaceMedium,
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) => viewModel.updateSizeQuantity(size, value),
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  AddOrderViewModel viewModelBuilder(BuildContext context) =>
      AddOrderViewModel(orderId: orderId);

  @override
  void onViewModelReady(AddOrderViewModel viewModel) => viewModel.init();
}