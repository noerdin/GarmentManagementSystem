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
          if (viewModel.similarTemplates.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: viewModel.showCopyFromTemplate,
              tooltip: 'Copy from Template',
            ),
          if (viewModel.materialRequirements.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'generate_shopping':
                    viewModel.generateShoppingList();
                    break;
                  case 'clear_all':
                    _showClearAllDialog(context, viewModel);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'generate_shopping',
                  child: ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text('Generate Shopping List'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: ListTile(
                    leading: Icon(Icons.clear_all),
                    title: Text('Clear All Materials'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: viewModel.isBusy,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
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
                    Row(
                      children: [
                        Icon(Icons.assignment, color: kcPrimaryColor),
                        horizontalSpaceSmall,
                        Text('Order ID: $orderId', style: bodyBoldStyle(context)),
                      ],
                    ),
                  ],

                  if (viewModel.selectedOrder != null) ...[
                    verticalSpaceSmall,
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kcInfoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kcInfoColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: kcInfoColor, size: 20),
                              horizontalSpaceSmall,
                              Text('Order Details', style: bodyBoldStyle(context).copyWith(color: kcInfoColor)),
                            ],
                          ),
                          verticalSpaceSmall,
                          _buildInfoRow(context, 'Product', viewModel.selectedOrder!.namaProduk),
                          _buildInfoRow(context, 'Color', viewModel.selectedOrder!.warna),
                          _buildInfoRow(context, 'Quantity', '${viewModel.selectedOrder!.jumlahTotal} pcs'),
                          _buildInfoRow(context, 'Customer', viewModel.selectedOrder!.namaCustomer),
                          _buildInfoRow(context, 'Deadline', formatDate(viewModel.selectedOrder!.deadlineProduksi)),
                        ],
                      ),
                    ),
                    verticalSpaceMedium,

                    // Similar Templates Alert
                    if (viewModel.similarTemplates.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kcSuccessColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kcSuccessColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: kcSuccessColor),
                                horizontalSpaceSmall,
                                Text('Smart Suggestions',
                                    style: bodyBoldStyle(context).copyWith(color: kcSuccessColor)),
                              ],
                            ),
                            verticalSpaceSmall,
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: viewModel.showCopyFromTemplate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kcSuccessColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Copy Template'),
                                ),
                                horizontalSpaceSmall,
                                OutlinedButton.icon(
                                  onPressed: viewModel.showTemplateHistory,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: kcSuccessColor),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  icon: Icon(Icons.history, size: 16, color: kcSuccessColor),
                                  label: Text('View All', style: TextStyle(color: kcSuccessColor)),
                                ),
                              ],
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Required Materials', style: bodyBoldStyle(context)),
                          if (viewModel.materialRequirements.isNotEmpty)
                            Text('${viewModel.materialRequirements.length} items',
                                style: captionStyle(context)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: viewModel.selectedOrder != null ? viewModel.addNewMaterial : null,
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
                    _buildEmptyMaterialsState(context, viewModel),
                  ] else ...[
                    // Materials List
                    ...viewModel.materialRequirements.asMap().entries.map((entry) {
                      final index = entry.key;
                      final material = entry.value;
                      return _buildMaterialRequirementCard(context, material, index, viewModel);
                    }).toList(),

                    verticalSpaceMedium,

                    // Summary Section
                    _buildMaterialSummary(context, viewModel),
                  ],
                ],
              ),
              verticalSpaceLarge,

              // Action Buttons
              _buildActionButtons(context, viewModel),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: bodyStyle(context)),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: Text(value, style: bodyBoldStyle(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMaterialsState(BuildContext context, MaterialPlanningViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kcBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kcLightGrey.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: kcSecondaryTextColor.withOpacity(0.5)),
          verticalSpaceMedium,
          Text('No Materials Added Yet', style: heading4Style(context)),
          verticalSpaceSmall,
          Text('Start by adding material requirements for this order',
              style: bodyStyle(context), textAlign: TextAlign.center),
          verticalSpaceLarge,
          ElevatedButton.icon(
            onPressed: viewModel.selectedOrder != null ? viewModel.addNewMaterial : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: kcPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add First Material'),
          ),
          if (viewModel.similarTemplates.isNotEmpty) ...[
            verticalSpaceSmall,
            Text('or', style: captionStyle(context)),
            verticalSpaceSmall,
            OutlinedButton.icon(
              onPressed: viewModel.showCopyFromTemplate,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: kcSuccessColor),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: Icon(Icons.copy, color: kcSuccessColor),
              label: Text('Copy from Similar Order', style: TextStyle(color: kcSuccessColor)),
            ),
          ],
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
    final totalCost = material.quantityNeeded * material.estimatedPrice;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: kcLightGrey.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    horizontalSpaceSmall,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: kcLightGrey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: captionStyle(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: kcInfoColor, size: 20),
                      onPressed: () => _editMaterial(context, viewModel, index, material),
                      tooltip: 'Edit Material',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    horizontalSpaceSmall,
                    IconButton(
                      icon: Icon(Icons.delete, color: kcErrorColor, size: 20),
                      onPressed: () => _confirmDeleteMaterial(context, viewModel, index, material),
                      tooltip: 'Remove Material',
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            verticalSpaceSmall,

            // Material Name
            Text(material.materialName, style: bodyBoldStyle(context)),
            verticalSpaceTiny,

            // Details Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${material.quantityNeeded} ${material.unit}',
                          style: bodyStyle(context)),
                      Text('Unit Price: Rp ${material.estimatedPrice.toStringAsFixed(0)}',
                          style: bodyStyle(context)),
                      if (material.supplier.isNotEmpty)
                        Text('Supplier: ${material.supplier}', style: captionStyle(context)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text('Total Cost', style: captionStyle(context).copyWith(color: kcPrimaryColor)),
                      Text('Rp ${totalCost.toStringAsFixed(0)}',
                          style: bodyBoldStyle(context).copyWith(color: kcPrimaryColor)),
                    ],
                  ),
                ),
              ],
            ),

            // Notes (if any)
            if (material.notes.isNotEmpty) ...[
              verticalSpaceSmall,
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kcBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes:', style: captionStyle(context).copyWith(fontWeight: FontWeight.w500)),
                    verticalSpaceTiny,
                    Text(material.notes, style: captionStyle(context)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialSummary(BuildContext context, MaterialPlanningViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kcPrimaryColor.withOpacity(0.1),
            kcPrimaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kcPrimaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: kcPrimaryColor),
              horizontalSpaceSmall,
              Text('Material Summary', style: bodyBoldStyle(context).copyWith(color: kcPrimaryColor)),
            ],
          ),
          verticalSpaceMedium,
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(context, 'Total Materials', '${viewModel.materialRequirements.length}'),
              ),
              Expanded(
                child: _buildSummaryItem(context, 'Estimated Cost', 'Rp ${viewModel.totalEstimatedCost.toStringAsFixed(0)}'),
              ),
            ],
          ),
          verticalSpaceSmall,
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(context, 'Cost per Unit', 'Rp ${viewModel.calculateCostPerUnit().toStringAsFixed(0)}'),
              ),
              Expanded(
                child: _buildSummaryItem(context, 'Fabric Items', '${viewModel.materialRequirements.where((m) => m.materialType == "Bahan").length}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: captionStyle(context)),
        verticalSpaceTiny,
        Text(value, style: bodyBoldStyle(context).copyWith(color: kcPrimaryColor)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, MaterialPlanningViewModel viewModel) {
    return Column(
      children: [
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
        if (viewModel.materialRequirements.isNotEmpty) ...[
          verticalSpaceMedium,
          OutlinedButton.icon(
            onPressed: viewModel.generateShoppingList,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: kcSecondaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            icon: Icon(Icons.shopping_cart, color: kcSecondaryColor),
            label: Text('Generate Shopping List', style: TextStyle(color: kcSecondaryColor)),
          ),
        ],
      ],
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

  void _editMaterial(BuildContext context, MaterialPlanningViewModel viewModel,
      int index, MaterialRequirement material) {
    // You can implement edit functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit functionality can be implemented here')),
    );
  }

  void _confirmDeleteMaterial(BuildContext context, MaterialPlanningViewModel viewModel,
      int index, MaterialRequirement material) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Material'),
        content: Text('Are you sure you want to remove "${material.materialName}" from the requirements?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              viewModel.removeMaterial(index);
            },
            style: TextButton.styleFrom(foregroundColor: kcErrorColor),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, MaterialPlanningViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Materials'),
        content: Text('Are you sure you want to remove all material requirements? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear all materials
              while (viewModel.materialRequirements.isNotEmpty) {
                viewModel.removeMaterial(0);
              }
            },
            style: TextButton.styleFrom(foregroundColor: kcErrorColor),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  MaterialPlanningViewModel viewModelBuilder(BuildContext context) =>
      MaterialPlanningViewModel(orderId: orderId);

  @override
  void onViewModelReady(MaterialPlanningViewModel viewModel) => viewModel.init();
}