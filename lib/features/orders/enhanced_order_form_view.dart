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
      resizeToAvoidBottomInset: true, // Prevent keyboard overflow
      appBar: AppBar(
        title: Text(
          viewModel.isEditing ? 'Edit Order' : 'Create New Order',
          style: heading3Style(context).copyWith(color: Colors.white),
        ),
        backgroundColor: kcPrimaryColor,
        actions: [
          if (viewModel.isEditing && !viewModel.isBusy)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: viewModel.deleteOrder,
              tooltip: 'Delete Order',
            ),
          if (!viewModel.isBusy)
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: viewModel.exportOrderDetails,
              tooltip: 'Export Details',
            ),
        ],
      ),
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: viewModel.isBusy || viewModel.isLoadingOrder,
          loadingText: viewModel.isLoadingOrder
              ? 'Loading order data...'
              : viewModel.isEditing
                  ? 'Updating order...'
                  : 'Creating order...',
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Indicator for form completion
                  if (!viewModel.isEditing) ...[
                    _buildFormProgressIndicator(context, viewModel),
                    verticalSpaceMedium,
                  ],

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
                              readOnly: viewModel.isEditing,
                              enabled: true,
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              readOnly:
                                  true, // Auto-calculated from size breakdown
                            ),
                          ),
                        ],
                      ),
                      verticalSpaceMedium,
                      _buildDateField(
                        context,
                        label: 'Order Date',
                        selectedDate: viewModel.selectedOrderDate,
                        onTap: viewModel.isEditing ? () {} : () => viewModel.selectOrderDate(context),
                        validator: viewModel.validateRequired,
                        readOnly: viewModel.isEditing, // Usually don't change order date when editing
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
                        readOnly: false,
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

                      // FIXED: Using Wrap instead of GridView to prevent overflow
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: viewModel.availableSizes
                            .map((size) => _buildSizeQuantityCard(context, viewModel, size))
                            .toList(),
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
                            Text('Total Quantity:',
                                style: bodyBoldStyle(context)),
                            Text(
                              '${viewModel.totalQuantity}',
                              style: heading4Style(context)
                                  .copyWith(color: kcPrimaryColor),
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
                        readOnly: false,
                      ),
                      verticalSpaceMedium,
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              context,
                              label: 'Priority Level',
                              value: viewModel.selectedPriority,
                              items: viewModel.priorityLevels,
                              onChanged: viewModel.setSelectedPriority,
                              prefixIcon: Icons.flag,
                            ),
                          ),
                          horizontalSpaceMedium,
                          Expanded(
                            child: _buildTextField(
                              label: 'Estimated Price (Rp)',
                              controller: viewModel.estimatedPriceController,
                              prefixIcon: Icons.attach_money,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (viewModel.selectedDeadline != null) ...[
                        verticalSpaceSmall,
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kcInfoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: kcInfoColor, size: 16),
                              horizontalSpaceSmall,
                              Text(
                                'Estimated Delivery: ${viewModel.getEstimatedDeliveryDate()}',
                                style: captionStyle(context)
                                    .copyWith(color: kcInfoColor),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                        hintText:
                            'Describe logo placement, print details, etc.',
                      ),
                      verticalSpaceMedium,
                      _buildTextField(
                        label: 'Additional Notes',
                        controller: viewModel.notesController,
                        maxLines: 2,
                        prefixIcon: Icons.note,
                        hintText: 'Any special requirements or instructions...',
                      ),
                    ],
                  ),
                  verticalSpaceLarge,

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: viewModel.isBusy
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: kcPrimaryColor),
                          ),
                          child: Text(
                            'Cancel',
                            style: buttonTextStyle(context)
                                .copyWith(color: kcPrimaryColor),
                          ),
                        ),
                      ),
                      horizontalSpaceMedium,
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              viewModel.isBusy ? null : viewModel.saveOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kcPrimaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            viewModel.isEditing
                                ? 'Update Order'
                                : 'Create Order',
                            style: buttonTextStyle(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  verticalSpaceLarge,

                  // Additional actions for editing mode
                  if (viewModel.isEditing &&
                      viewModel.existingOrder != null) ...[
                    _buildCard(
                      context,
                      title: 'Order Status',
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                _getStatusColor(viewModel.existingOrder!.status)
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getStatusIcon(viewModel.existingOrder!.status),
                                color: _getStatusColor(
                                    viewModel.existingOrder!.status),
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Status: ${viewModel.existingOrder!.displayStatus}',
                                      style: bodyBoldStyle(context),
                                    ),
                                    Text(
                                      'Progress: ${(viewModel.existingOrder!.progress * 100).toInt()}%',
                                      style: bodyStyle(context),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        Text(
                          'Note: Status and progress can be updated from the Orders list view.',
                          style: captionStyle(context),
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
      ),
    );
  }

  // Helper method untuk mendapatkan lebar card yang responsif
  double _getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth - 64) / 3; // 64 = padding (16*2) + spacing (8*2)
  }

  Widget _buildFormProgressIndicator(
      BuildContext context, EnhancedOrderFormViewModel viewModel) {
    final completion = viewModel.getFormCompletionPercentage();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Form Completion', style: bodyBoldStyle(context)),
              Text('${(completion * 100).toInt()}%',
                  style:
                      bodyBoldStyle(context).copyWith(color: kcPrimaryColor)),
            ],
          ),
          verticalSpaceSmall,
          customProgressIndicator(value: completion, color: kcPrimaryColor),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title, required List<Widget> children}) {
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
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
        ),
        filled: !enabled || readOnly,
        fillColor: (!enabled || readOnly) ? Colors.grey[100] : null,
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
    bool enabled = true,
    bool readOnly = false,
  }) {
    return TextFormField(
      readOnly: true,
      onTap: (readOnly || !enabled) ? null : onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: enabled ? const Icon(Icons.arrow_drop_down) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
        ),
        filled: readOnly || !enabled,
        fillColor: (readOnly || !enabled) ? Colors.grey[100] : null,
      ),
      controller: TextEditingController(
        text: selectedDate != null ? formatDate(selectedDate) : '',
      ),
    );
  }

  Widget _buildSizeQuantityCard(
      BuildContext context, EnhancedOrderFormViewModel viewModel, String size) {
    final currentQuantity = viewModel.getSizeQuantity(size);
    final cardWidth = _getCardWidth(context);

    return SizedBox(
      width: cardWidth,
      height: 80, // Fixed height untuk mencegah overflow
      child: Container(
        padding: const EdgeInsets.all(6), // Padding dikurangi
        decoration: BoxDecoration(
          border: Border.all(
              color: currentQuantity > 0 ? kcPrimaryColor : kcLightGrey),
          borderRadius: BorderRadius.circular(8),
          color: currentQuantity > 0 ? kcPrimaryColor.withOpacity(0.1) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label size
            Container(
              height: 22, // Fixed height untuk label
              child: Center(
                child: Text(
                  size,
                  style: bodyBoldStyle(context).copyWith(
                    color: currentQuantity > 0 ? kcPrimaryColor : null,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Input field
            Flexible(
              child: Container(
                height: 40, // Fixed height untuk input
                child: TextFormField(
                  initialValue:
                      currentQuantity > 0 ? currentQuantity.toString() : '',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) =>
                      viewModel.updateSizeQuantity(size, value),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(fontSize: 10),
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return kcWarningColor;
      case 'Produksi':
        return kcInfoColor;
      case 'Selesai':
        return kcSuccessColor;
      default:
        return kcPrimaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending_actions;
      case 'Produksi':
        return Icons.precision_manufacturing;
      case 'Selesai':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  EnhancedOrderFormViewModel viewModelBuilder(BuildContext context) =>
      EnhancedOrderFormViewModel(orderId: orderId);

  @override
  void onViewModelReady(EnhancedOrderFormViewModel viewModel) =>
      viewModel.init();
}
