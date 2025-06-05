import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'materials_viewmodel.dart';

class MaterialsView extends StackedView<MaterialsViewModel> {
  final String? orderId; // Added orderId parameter
  final bool showOrderContext; // Flag to show order-related features

  const MaterialsView({
    super.key,
    this.orderId,
    this.showOrderContext = false,
  });

  @override
  Widget builder(
      BuildContext context,
      MaterialsViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          showOrderContext && orderId != null
              ? 'Materials for Order'
              : 'Materials & Inventory',
          style: heading3Style(context).copyWith(color: Colors.white),
        ),
        backgroundColor: kcPrimaryColor,
        actions: [
          if (showOrderContext) ...[
            IconButton(
              icon: const Icon(Icons.timeline),
              onPressed: viewModel.navigateToMaterialPlanning,
              tooltip: 'Material Planning',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => viewModel.showAddMaterialDialog(orderContext: orderId),
        backgroundColor: kcPrimaryColor,
        child: const Icon(Icons.add),
      ),
      body: viewModel.isBusy
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, MaterialsViewModel viewModel) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Order Context Section (when orderId is provided)
          if (showOrderContext && viewModel.selectedOrder != null) ...[
            _buildOrderContextCard(context, viewModel),
            verticalSpaceSmall,
          ],

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: kcPrimaryColor,
              unselectedLabelColor: kcSecondaryTextColor,
              indicatorColor: kcPrimaryColor,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Bahan'),
                Tab(text: 'Aksesoris'),
              ],
              onTap: viewModel.setSelectedTab,
            ),
          ),

          // Search and filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: viewModel.filterMaterials,
                    decoration: InputDecoration(
                      hintText: 'Search materials...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                horizontalSpaceSmall,
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: viewModel.toggleLowStockFilter,
                    icon: Icon(
                      Icons.filter_list,
                      color: viewModel.showLowStockOnly
                          ? kcWarningColor
                          : kcPrimaryColor,
                    ),
                    tooltip: 'Low Stock Filter',
                  ),
                ),
                if (showOrderContext) ...[
                  horizontalSpaceSmall,
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: viewModel.toggleOrderRelevantFilter,
                      icon: Icon(
                        Icons.assignment,
                        color: viewModel.showOrderRelevantOnly
                            ? kcInfoColor
                            : kcPrimaryColor,
                      ),
                      tooltip: 'Order Relevant Materials',
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Inventory Summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  title: 'Bahan',
                  value: viewModel.totalBahan.toString(),
                  color: kcPrimaryColor,
                ),
                _buildDivider(),
                _buildStatColumn(
                  context,
                  title: 'Aksesoris',
                  value: viewModel.totalAksesoris.toString(),
                  color: kcSecondaryColor,
                ),
                _buildDivider(),
                _buildStatColumn(
                  context,
                  title: 'Low Stock',
                  value: viewModel.lowStockCount.toString(),
                  color: kcWarningColor,
                ),
                if (showOrderContext) ...[
                  _buildDivider(),
                  _buildStatColumn(
                    context,
                    title: 'Needed',
                    value: viewModel.orderRelevantCount.toString(),
                    color: kcInfoColor,
                  ),
                ],
              ],
            ),
          ),
          verticalSpaceMedium,

          // Quick Actions for Order Context
          if (showOrderContext && orderId != null) ...[
            _buildQuickActionsCard(context, viewModel),
            verticalSpaceSmall,
          ],

          // Materials List
          Expanded(
            child: viewModel.displayedMaterials.isEmpty
                ? _buildEmptyState(context, viewModel)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.displayedMaterials.length,
              itemBuilder: (context, index) {
                final material = viewModel.displayedMaterials[index];
                return _buildMaterialCard(context, material, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderContextCard(BuildContext context, MaterialsViewModel viewModel) {
    final order = viewModel.selectedOrder!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: defaultBoxShadow,
        border: Border.all(color: kcInfoColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment, color: kcInfoColor),
              horizontalSpaceSmall,
              Text('Order Context', style: bodyBoldStyle(context).copyWith(color: kcInfoColor)),
            ],
          ),
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
                Text('Order ID: ${order.orderId}', style: bodyBoldStyle(context)),
                Text('Product: ${order.namaProduk}', style: bodyStyle(context)),
                Text('Color: ${order.warna}', style: bodyStyle(context)),
                Text('Quantity: ${order.jumlahTotal}', style: bodyStyle(context)),
                Text('Customer: ${order.namaCustomer}', style: bodyStyle(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, MaterialsViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: defaultBoxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: bodyBoldStyle(context)),
          verticalSpaceMedium,
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: viewModel.navigateToMaterialPlanning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcPrimaryColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.timeline),
                  label: const Text('Plan Materials'),
                ),
              ),
              horizontalSpaceSmall,
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => viewModel.showAddMaterialDialog(orderContext: orderId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kcSuccessColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Material'),
                ),
              ),
            ],
          ),
          verticalSpaceSmall,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: viewModel.checkMaterialRequirements,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kcInfoColor),
                  ),
                  icon: const Icon(Icons.check_circle_outline, color: kcInfoColor),
                  label: Text('Check Requirements',
                      style: TextStyle(color: kcInfoColor)),
                ),
              ),
              horizontalSpaceSmall,
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: viewModel.generateShoppingList,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kcSecondaryColor),
                  ),
                  icon: const Icon(Icons.shopping_cart_outlined, color: kcSecondaryColor),
                  label: Text('Shopping List',
                      style: TextStyle(color: kcSecondaryColor)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MaterialsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: kcPrimaryColor.withOpacity(0.5),
          ),
          verticalSpaceMedium,
          Text(
            'No Materials Found',
            style: heading3Style(context),
          ),
          verticalSpaceSmall,
          Text(
            _getEmptyStateMessage(viewModel),
            style: bodyStyle(context),
            textAlign: TextAlign.center,
          ),
          verticalSpaceLarge,
          ElevatedButton.icon(
            onPressed: () => viewModel.showAddMaterialDialog(orderContext: orderId),
            style: ElevatedButton.styleFrom(
              backgroundColor: kcPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'Add Material',
              style: buttonTextStyle(context),
            ),
          ),
          if (showOrderContext) ...[
            verticalSpaceSmall,
            TextButton.icon(
              onPressed: viewModel.navigateToMaterialPlanning,
              icon: const Icon(Icons.timeline),
              label: const Text('Or Plan Materials for Order'),
            ),
          ],
        ],
      ),
    );
  }

  String _getEmptyStateMessage(MaterialsViewModel viewModel) {
    if (viewModel.showLowStockOnly) {
      return 'No low stock materials found';
    } else if (viewModel.showOrderRelevantOnly) {
      return 'No materials relevant to this order found';
    } else if (showOrderContext) {
      return 'Start by planning materials for this order\nor add materials to your inventory';
    } else {
      return 'Start by adding materials to your inventory';
    }
  }

  Widget _buildStatColumn(
      BuildContext context, {
        required String title,
        required String value,
        required Color color,
      }) {
    return Column(
      children: [
        Text(
          title,
          style: subtitleStyle(context),
        ),
        verticalSpaceSmall,
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: kcLightGrey,
    );
  }

  Widget _buildMaterialCard(
      BuildContext context, dynamic material, MaterialsViewModel viewModel) {
    final isLowStock = material.isLowStock;
    final isOrderRelevant = showOrderContext && viewModel.isMaterialRelevantToOrder(material);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLowStock
            ? BorderSide(color: kcWarningColor.withOpacity(0.5), width: 1.5)
            : isOrderRelevant
            ? BorderSide(color: kcInfoColor.withOpacity(0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => viewModel.showMaterialDetails(material),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with material type and ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: material.jenis == 'Bahan'
                              ? kcPrimaryColor.withOpacity(0.1)
                              : kcSecondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          material.jenis,
                          style: TextStyle(
                            color: material.jenis == 'Bahan'
                                ? kcPrimaryColor
                                : kcSecondaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      horizontalSpaceSmall,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kcLightGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          material.materialId,
                          style: const TextStyle(
                            color: kcSecondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      if (isLowStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kcWarningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: kcWarningColor,
                                size: 14,
                              ),
                              horizontalSpaceTiny,
                              Text(
                                'Low Stock',
                                style: TextStyle(
                                  color: kcWarningColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (isOrderRelevant && !isLowStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kcInfoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.assignment,
                                color: kcInfoColor,
                                size: 14,
                              ),
                              horizontalSpaceTiny,
                              Text(
                                'Needed',
                                style: TextStyle(
                                  color: kcInfoColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              verticalSpaceMedium,

              // Material name and details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.nama,
                          style: bodyBoldStyle(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        verticalSpaceSmall,
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: kcSecondaryTextColor,
                            ),
                            horizontalSpaceSmall,
                            Text(
                              'Location: ${material.lokasi}',
                              style: captionStyle(context),
                            ),
                          ],
                        ),
                        verticalSpaceTiny,
                        Row(
                          children: [
                            const Icon(
                              Icons.update,
                              size: 18,
                              color: kcSecondaryTextColor,
                            ),
                            horizontalSpaceSmall,
                            Text(
                              'Updated: ${formatDate(material.lastUpdated)}',
                              style: captionStyle(context),
                            ),
                          ],
                        ),
                        if (showOrderContext && isOrderRelevant) ...[
                          verticalSpaceTiny,
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: kcInfoColor,
                              ),
                              horizontalSpaceSmall,
                              Text(
                                'Relevant to current order',
                                style: captionStyle(context).copyWith(color: kcInfoColor),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isLowStock ? kcWarningColor : kcPrimaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Stock: ${material.stok} ${material.satuan}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                      Text(
                        'Price: Rp ${material.hargaPerUnit.toStringAsFixed(0)}/${material.satuan}',
                        style: subtitleStyle(context),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  MaterialsViewModel viewModelBuilder(BuildContext context) =>
      MaterialsViewModel();

  @override
  void onViewModelReady(MaterialsViewModel viewModel) => viewModel.init();
}
