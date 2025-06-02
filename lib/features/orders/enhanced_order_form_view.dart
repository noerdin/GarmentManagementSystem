import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../shared/loading_overlay.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'enhanced_order_form_viewmodel.dart';

class EnhancedOrderFormView extends StackedView<EnhancedOrderFormViewModel> {
  final String? orderId; // For editing existing orders

  const EnhancedOrderFormView({super.key, this.orderId});

  @override
  Widget builder(
      BuildContext context,
      EnhancedOrderFormViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          viewModel.isEditing ? 'Edit Order' : 'Create New Order',
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
                // Order ID Card
                _buildCard(
                  context,
                  title: 'Order Information',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            label: 'Order ID',
                            controller: viewModel.orderIdController,
                            validator: viewModel.validateOrderId,
                            prefixIcon: Icons.tag,
                            hintText: 'e.g., ORD2025001',
                            enabled: !viewModel.isEditing, // Disable when editing
                          ),
                        ),
                        horizontalSpaceMedium,
                        Expanded(
                          child: _buildTextField(
                            label: 'Quantity Total',
                            controller: viewModel.quantityController,
                            validator: viewModel.validateRequired,
                            prefixIcon: Icons.numbers,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceMedium,
                    _buildDateField(
                      context,
                      label: 'Order Date',
                      selectedDate: viewModel.selectedOrderDate,
                      onTap: () => viewModel.selectOrderDate(context),
                      validator: viewModel.validateRequired,
                    ),
                  ],
                ),
                verticalSpaceMedium,

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
                      label: 'Customer Contact',
                      controller: viewModel.customerContactController,
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    verticalSpaceMedium,
                    _buildTextField(
                      label: 'Customer Address',
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
                    _buildTextField(
                      label: 'Product Category',
                      controller: viewModel.productCategoryController,
                      validator: viewModel.validateRequired,
                      prefixIcon: Icons.category,
                      hintText: 'e.g., T-Shirt, Polo, Jacket, Dress',
                    ),
                    verticalSpaceMedium,
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Color',
                            controller: viewModel.colorController,
                            validator: viewModel.validateRequired,
                            prefixIcon: Icons.palette,
                            hintText: 'e.g., Navy Blue, Red, Black',
                          ),
                        ),
                        horizontalSpaceMedium,
                        Expanded(
                          child: _buildTextField(
                            label: 'Material Type',
                            controller: viewModel.materialTypeController,
                            prefixIcon: Icons.texture,
                            hintText: 'e.g., Cotton, Polyester',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Size & Quantity Breakdown Card
                _buildCard(
                  context,
                  title: 'Size Distribution',
                  children: [
                    Text(
                      'Specify quantity for each size:',
                      style: bodyStyle(context),
                    ),
                    verticalSpaceSmall,
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: viewModel.availableSizes.map((size) =>
                          _buildSizeQuantityCard(context, viewModel, size),
                      ).toList(),
                    ),
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
                          Text('Total Quantity:', style: bodyBoldStyle(context)),
                          Text(
                            '${viewModel.totalQuantity}',
                            style: heading4Style(context).copyWith(color: kcPrimaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Production Details Card
                _buildCard(
                  context,
                  title: 'Production Details',
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
                      label: 'Priority Level',
                      value: viewModel.selectedPriority,
                      items: viewModel.priorityLevels,
                      onChanged: viewModel.setSelectedPriority,
                      prefixIcon: Icons.flag,
                    ),
                    verticalSpaceMedium,
                    _buildTextField(
                      label: 'Estimated Price (Rp)',
                      controller: viewModel.estimatedPriceController,
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Special Instructions Card
                _buildCard(
                  context,
                  title: 'Special Instructions',
                  children: [
                    _buildTextField(
                      label: 'Design Specifications',
                      controller: viewModel.designSpecsController,
                      maxLines: 3,
                      prefixIcon: Icons.design_services,
                      hintText: 'Describe logo placement, print details, etc.',
                    ),
                    verticalSpaceMedium,
                    _buildTextField(
                      label: 'Additional Notes',
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
                          style: buttonTextStyle(context).copyWith(color: kcPrimaryColor),
                        ),
                      ),
                    ),
                    horizontalSpaceMedium,
                    Expanded(
                      flex: 2,
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

  Widget _buildCard(BuildContext context, {required String title, required List<Widget> children}) {
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
          Text(title, style: heading4Style(context)),
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
    String? hintText,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
        ),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : null,
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildSizeQuantityCard(BuildContext context, EnhancedOrderFormViewModel viewModel, String size) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: kcLightGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(size, style: bodyBoldStyle(context)),
          verticalSpaceTiny,
          Expanded(
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => viewModel.updateSizeQuantity(size, value),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  EnhancedOrderFormViewModel viewModelBuilder(BuildContext context) =>
      EnhancedOrderFormViewModel(orderId: orderId);

  @override
  void onViewModelReady(EnhancedOrderFormViewModel viewModel) => viewModel.init();
}