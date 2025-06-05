import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../models/material_requirement_model.dart';
import '../../shared/loading_overlay.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'material_planning_viewmodel.dart';

class MaterialPlanningView extends StackedView<MaterialPlanningViewModel> {
  final String? orderId;

  const MaterialPlanningView({super.key, this.orderId});

  @override
  Widget builder(
      BuildContext context,
      MaterialPlanningViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Material Planning',
          style: heading3Style(context).copyWith(color: Colors.white),
        ),
        backgroundColor: kcPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: viewModel.showTemplateHistory,
            tooltip: 'View Templates',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: viewModel.showCopyFromTemplate,
            tooltip: 'Copy from Template',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: viewModel.isBusy,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Selection Card
              _buildCard(
                context,
                title: 'Order Information',
                children: [
                  if (orderId == null) ...[
                    _buildDropdown(
                      context,
                      label: 'Select Order',
                      value: viewModel.selectedOrderId,
                      items: viewModel.availableOrders.map((order) => order.orderId).toList(),
                      onChanged: viewModel.setSelectedOrder,
                      prefixIcon: Icons.shopping_cart,
                    ),
                  ] else ...[
                    Text('Order ID: $orderId', style: bodyBoldStyle(context)),
                  ],

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
                          Text('Product: ${viewModel.selectedOrder!.namaProduk}',
                              style: bodyBoldStyle(context)),
                          Text('Color: ${viewModel.selectedOrder!.warna}',
                              style: bodyStyle(context)),
                          Text('Quantity: ${viewModel.selectedOrder!.jumlahTotal}',
                              style: bodyStyle(context)),
                          Text('Customer: ${viewModel.selectedOrder!.namaCustomer}',
                              style: bodyStyle(context)),
                        ],
                      ),
                    ),
                    verticalSpaceMedium,

                    // Check for similar templates
                    if (viewModel.similarTemplates.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kcSuccessColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kcSuccessColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: kcSuccessColor),
                                horizontalSpaceSmall,
                                Text('Similar Templates Found',
                                    style: bodyBoldStyle(context).copyWith(color: kcSuccessColor)),
                              ],
                            ),
                            verticalSpaceSmall,
                            Text('Found ${viewModel.similarTemplates.length} similar orders. '
                                'You can copy material requirements from them.',
                                style: bodyStyle(context)),
                            verticalSpaceSmall,
                            ElevatedButton.icon(
                              onPressed: viewModel.showCopyFromTemplate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kcSuccessColor,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.copy),
                              label: const Text('Copy from Template'),
                            ),
                          ],
                        ),
                      ),
                      verticalSpaceMedium,
                    ],
                  ],
                ],
              ),

              // Material Requirements Card
              _buildCard(
                context,
                title: 'Material Requirements',
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Required Materials', style: bodyBoldStyle(context)),
                      ElevatedButton.icon(
                        onPressed: viewModel.addNewMaterial,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kcPrimaryColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Material'),
                      ),
                    ],
                  ),
                  verticalSpaceMedium,

                  if (viewModel.materialRequirements.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: kcLightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kcLightGrey),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: kcSecondaryTextColor),
                          verticalSpaceSmall,
                          Text('No materials added yet', style: bodyStyle(context)),
                          Text('Click "Add Material" to start planning', style: captionStyle(context)),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...viewModel.materialRequirements.asMap().entries.map((entry) {
                      final index = entry.key;
                      final material = entry.value;
                      return _buildMaterialRequirementCard(context, material, index, viewModel);
                    }).toList(),

                    verticalSpaceMedium,
                    // Summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kcPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Material Summary', style: bodyBoldStyle(context)),
                          verticalSpaceSmall,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Materials:', style: bodyStyle(context)),
                              Text('${viewModel.materialRequirements.length}',
                                  style: bodyBoldStyle(context)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Estimated Cost:', style: bodyStyle(context)),
                              Text('Rp ${viewModel.totalEstimatedCost.toStringAsFixed(0)}',
                                  style: bodyBoldStyle(context).copyWith(color: kcPrimaryColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
                      onPressed: viewModel.materialRequirements.isEmpty || viewModel.isBusy
                          ? null
                          : viewModel.saveMaterialTemplate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Save Material Template',
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
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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

  Widget _buildMaterialRequirementCard(
      BuildContext context,
      MaterialRequirement material,
      int index,
      MaterialPlanningViewModel viewModel
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: kcLightGrey.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: material.materialType == 'Bahan'
                            ? kcPrimaryColor.withOpacity(0.1)
                            : kcSecondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        material.materialType,
                        style: captionStyle(context).copyWith(
                          color: material.materialType == 'Bahan' ? kcPrimaryColor : kcSecondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: kcErrorColor),
                  onPressed: () => viewModel.removeMaterial(index),
                  iconSize: 20,
                ),
              ],
            ),
            verticalSpaceSmall,
            Text(material.materialName, style: bodyBoldStyle(context)),
            verticalSpaceTiny,
            Row(
              children: [
                Expanded(
                  child: Text('Quantity: ${material.quantityNeeded} ${material.unit}',
                      style: bodyStyle(context)),
                ),
                Text('Est. Price: Rp ${material.estimatedPrice.toStringAsFixed(0)}',
                    style: bodyStyle(context).copyWith(color: kcPrimaryColor)),
              ],
            ),
            if (material.supplier.isNotEmpty) ...[
              verticalSpaceTiny,
              Text('Supplier: ${material.supplier}', style: captionStyle(context)),
            ],
            if (material.notes.isNotEmpty) ...[
              verticalSpaceTiny,
              Text('Notes: ${material.notes}', style: captionStyle(context)),
            ],
          ],
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

  @override
  MaterialPlanningViewModel viewModelBuilder(BuildContext context) =>
      MaterialPlanningViewModel(orderId: orderId);

  @override
  void onViewModelReady(MaterialPlanningViewModel viewModel) => viewModel.init();
}