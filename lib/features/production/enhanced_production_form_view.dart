import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import '../../shared/loading_overlay.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'enhanced_production_form_viewmodel.dart';

class EnhancedProductionFormView extends StackedView<EnhancedProductionFormViewModel> {
  final String? productionId;

  const EnhancedProductionFormView({super.key, this.productionId});

  @override
  Widget builder(
      BuildContext context,
      EnhancedProductionFormViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          viewModel.isEditing ? 'Update Production' : 'Add Production Record',
          style: heading3Style(context).copyWith(color: Colors.white),
        ),
        backgroundColor: kcPrimaryColor,
      ),
      body: LoadingOverlay(
        isLoading: viewModel.isBusy,
        child: Form(
          key: viewModel.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information Card
                _buildCard(
                  context,
                  title: 'Basic Information',
                  children: [
                    _buildDropdown(
                      context,
                      label: 'Select Order',
                      value: viewModel.selectedOrderId,
                      items: viewModel.availableOrders.map((order) => order.orderId).toList(),
                      onChanged: viewModel.setSelectedOrder,
                      prefixIcon: Icons.shopping_cart,
                    ),
                    if (viewModel.selectedOrder != null) ...[
                      verticalSpaceSmall,
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kcInfoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Customer: ${viewModel.selectedOrder!.namaCustomer}',
                                style: bodyStyle(context)),
                            Text('Product: ${viewModel.selectedOrder!.namaProduk}',
                                style: bodyStyle(context)),
                            Text('Total Quantity: ${viewModel.selectedOrder!.jumlahTotal}',
                                style: bodyBoldStyle(context)),
                          ],
                        ),
                      ),
                    ],
                    verticalSpaceMedium,
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Operator Name',
                            controller: viewModel.operatorController,
                            validator: viewModel.validateRequired,
                            prefixIcon: Icons.person,
                          ),
                        ),
                        horizontalSpaceMedium,
                        Expanded(
                          child: _buildDateField(
                            context,
                            label: 'Production Date',
                            selectedDate: viewModel.selectedDate,
                            onTap: () => viewModel.selectDate(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Production Stages Card
                _buildCard(
                  context,
                  title: 'Production Stages',
                  children: [
                    // Bartek Stage
                    _buildStageSection(
                      context,
                      'Bartek',
                      kcCuttingColor,
                      [
                        _buildQuantityField('Bartek Quantity', viewModel.bartekController),
                      ],
                    ),
                    verticalSpaceSmall,

                    // Cutting Stage with Details
                    _buildStageSection(
                      context,
                      'Cutting Process',
                      kcCuttingColor,
                      [
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuantityField('Pattern Result', viewModel.hasilCuttingController),
                            ),
                            horizontalSpaceSmall,
                            Expanded(
                              child: _buildQuantityField('Numbering', viewModel.numberingController),
                            ),
                          ],
                        ),
                        verticalSpaceSmall,
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuantityField('Press', viewModel.pressController),
                            ),
                            horizontalSpaceSmall,
                            Expanded(
                              child: _buildQuantityField('QC Panel', viewModel.qcPanelController),
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpaceSmall,

                    // Sewing Stage
                    _buildStageSection(
                      context,
                      'Sewing',
                      kcSewingColor,
                      [
                        _buildQuantityField('Sewing Quantity', viewModel.sewingController),
                      ],
                    ),
                    verticalSpaceSmall,

                    // Finishing Stage
                    _buildStageSection(
                      context,
                      'Finishing',
                      kcPackingColor,
                      [
                        _buildQuantityField('Finishing Quantity', viewModel.finishingController),
                      ],
                    ),
                    verticalSpaceSmall,

                    // Washing Stage
                    _buildStageSection(
                      context,
                      'Washing',
                      kcInfoColor,
                      [
                        _buildQuantityField('Washing Quantity', viewModel.washingController),
                      ],
                    ),
                  ],
                ),
                verticalSpaceMedium,

                // Additional Information Card
                _buildCard(
                  context,
                  title: 'Additional Information',
                  children: [
                    _buildTextField(
                      label: 'Production Notes',
                      controller: viewModel.keteranganController,
                      maxLines: 3,
                      prefixIcon: Icons.note,
                      hintText: 'Any special notes or observations...',
                    ),
                    verticalSpaceMedium,
                    // Total Quantity Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kcPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Production Summary', style: bodyBoldStyle(context)),
                          verticalSpaceSmall,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Items Processed:', style: bodyStyle(context)),
                              Text('${viewModel.totalQuantity}',
                                  style: heading4Style(context).copyWith(color: kcPrimaryColor)),
                            ],
                          ),
                        ],
                      ),
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
                        onPressed: viewModel.isBusy ? null : viewModel.saveProduction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kcPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          viewModel.isEditing ? 'Update Production' : 'Save Production',
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

  Widget _buildStageSection(BuildContext context, String title, Color color, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.precision_manufacturing_outlined, color: Colors.white, size: 16),
              ),
              horizontalSpaceSmall,
              Text(title, style: bodyBoldStyle(context).copyWith(color: color)),
            ],
          ),
          verticalSpaceSmall,
          ...children,
        ],
      ),
    );
  }

  Widget _buildQuantityField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
      }) {
    return TextFormField(
      readOnly: true,
      onTap: onTap,
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

  @override
  EnhancedProductionFormViewModel viewModelBuilder(BuildContext context) =>
      EnhancedProductionFormViewModel(productionId: productionId);

  @override
  void onViewModelReady(EnhancedProductionFormViewModel viewModel) => viewModel.init();
}