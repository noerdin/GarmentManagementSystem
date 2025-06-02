import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'history_viewmodel.dart';

class HistoryView extends StackedView<HistoryViewModel> {
  const HistoryView({super.key});

  @override
  Widget builder(
      BuildContext context,
      HistoryViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Production History',
          style: heading3Style(context).copyWith(color: Colors.white),
        ),
        backgroundColor: kcPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: viewModel.exportReport,
            tooltip: 'Export Report',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, viewModel),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Summary Card
          Container(
            margin: const EdgeInsets.all(16),
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
                    Text('Filter Period', style: heading4Style(context)),
                    TextButton(
                      onPressed: () => _showFilterDialog(context, viewModel),
                      child: const Text('Change'),
                    ),
                  ],
                ),
                verticalSpaceSmall,
                Row(
                  children: [
                    Icon(Icons.date_range, color: kcPrimaryColor),
                    horizontalSpaceSmall,
                    Text(
                      '${formatDate(viewModel.startDate)} - ${formatDate(viewModel.endDate)}',
                      style: bodyBoldStyle(context),
                    ),
                  ],
                ),
                verticalSpaceSmall,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Total Orders', viewModel.totalOrdersInPeriod.toString()),
                    _buildSummaryItem('Completed', viewModel.completedOrdersInPeriod.toString()),
                    _buildSummaryItem('Production Records', viewModel.totalProductionRecords.toString()),
                    _buildSummaryItem('Shipments', viewModel.totalShipments.toString()),
                  ],
                ),
              ],
            ),
          ),

          // Tabs for different history types
          DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    labelColor: kcPrimaryColor,
                    unselectedLabelColor: kcSecondaryTextColor,
                    indicatorColor: kcPrimaryColor,
                    tabs: const [
                      Tab(text: 'Orders', icon: Icon(Icons.shopping_cart, size: 16)),
                      Tab(text: 'Production', icon: Icon(Icons.precision_manufacturing_outlined, size: 16)),
                      Tab(text: 'Shipping', icon: Icon(Icons.local_shipping, size: 16)),
                      Tab(text: 'Materials', icon: Icon(Icons.inventory, size: 16)),
                    ],
                    onTap: viewModel.setSelectedTab,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildOrderHistory(context, viewModel),
                      _buildProductionHistory(context, viewModel),
                      _buildShippingHistory(context, viewModel),
                      _buildMaterialHistory(context, viewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(value, style: heading4Style(context).copyWith(color: kcPrimaryColor)),
        Text(title, style: captionStyle(context)),
      ],
    );
  }

  Widget _buildOrderHistory(BuildContext context, HistoryViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.filteredOrders.isEmpty) {
      return _buildEmptyState('No orders found in selected period');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.filteredOrders.length,
      itemBuilder: (context, index) {
        final order = viewModel.filteredOrders[index];
        return _buildOrderHistoryCard(context, order, viewModel);
      },
    );
  }

  Widget _buildOrderHistoryCard(BuildContext context, dynamic order, HistoryViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        color: kcPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.orderId,
                        style: captionStyle(context).copyWith(
                          color: kcPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    horizontalSpaceSmall,
                    _buildStatusChip(order.status),
                  ],
                ),
                Text(formatDate(order.tanggalOrder), style: captionStyle(context)),
              ],
            ),
            verticalSpaceSmall,
            Text(order.namaProduk, style: bodyBoldStyle(context)),
            Text('Customer: ${order.namaCustomer}', style: bodyStyle(context)),
            verticalSpaceSmall,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantity: ${order.jumlahTotal}', style: subtitleStyle(context)),
                Text('Progress: ${(order.progress * 100).toInt()}%',
                    style: subtitleStyle(context).copyWith(color: kcPrimaryColor)),
              ],
            ),
            if (order.status == 'Selesai') ...[
              verticalSpaceTiny,
              Row(
                children: [
                  Icon(Icons.check_circle, color: kcSuccessColor, size: 16),
                  horizontalSpaceTiny,
                  Text('Completed', style: captionStyle(context).copyWith(color: kcSuccessColor)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductionHistory(BuildContext context, HistoryViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.filteredProductions.isEmpty) {
      return _buildEmptyState('No production records found in selected period');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.filteredProductions.length,
      itemBuilder: (context, index) {
        final production = viewModel.filteredProductions[index];
        return _buildProductionHistoryCard(context, production);
      },
    );
  }

  Widget _buildProductionHistoryCard(BuildContext context, dynamic production) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order: ${production.orderId}', style: bodyBoldStyle(context)),
                Text(formatDate(production.tanggal), style: captionStyle(context)),
              ],
            ),
            verticalSpaceSmall,
            Text('Operator: ${production.operator}', style: bodyStyle(context)),
            verticalSpaceSmall,
            // Production stages summary
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (production.tahap.bartek > 0)
                  _buildProductionStageChip('Bartek', production.tahap.bartek),
                if (production.tahap.cutting.hasilCutting > 0)
                  _buildProductionStageChip('Cutting', production.tahap.cutting.hasilCutting),
                if (production.tahap.sewing > 0)
                  _buildProductionStageChip('Sewing', production.tahap.sewing),
                if (production.tahap.finishing > 0)
                  _buildProductionStageChip('Finishing', production.tahap.finishing),
                if (production.tahap.washing > 0)
                  _buildProductionStageChip('Washing', production.tahap.washing),
              ],
            ),
            if (production.keterangan.isNotEmpty) ...[
              verticalSpaceSmall,
              Text('Notes: ${production.keterangan}', style: captionStyle(context)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShippingHistory(BuildContext context, HistoryViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.filteredShipments.isEmpty) {
      return _buildEmptyState('No shipments found in selected period');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.filteredShipments.length,
      itemBuilder: (context, index) {
        final shipment = viewModel.filteredShipments[index];
        return _buildShippingHistoryCard(context, shipment);
      },
    );
  }

  Widget _buildShippingHistoryCard(BuildContext context, dynamic shipment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order: ${shipment.orderId}', style: bodyBoldStyle(context)),
                Text(formatDate(shipment.tanggal), style: captionStyle(context)),
              ],
            ),
            verticalSpaceSmall,
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: kcSecondaryTextColor),
                horizontalSpaceTiny,
                Expanded(child: Text('To: ${shipment.tujuan}', style: bodyStyle(context))),
              ],
            ),
            verticalSpaceTiny,
            Row(
              children: [
                Icon(Icons.inventory, size: 16, color: kcSecondaryTextColor),
                horizontalSpaceTiny,
                Text('Quantity: ${shipment.jumlahDikirim}', style: bodyStyle(context)),
              ],
            ),
            if (shipment.resi.isNotEmpty) ...[
              verticalSpaceTiny,
              Row(
                children: [
                  Icon(Icons.local_shipping, size: 16, color: kcSecondaryTextColor),
                  horizontalSpaceTiny,
                  Expanded(child: Text('Tracking: ${shipment.resi}', style: bodyStyle(context))),
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: kcPrimaryColor),
                    onPressed: () => viewModel.copyTrackingNumber(shipment.resi),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialHistory(BuildContext context, HistoryViewModel viewModel) {
    if (viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.filteredMaterialTransactions.isEmpty) {
      return _buildEmptyState('No material transactions found in selected period');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.filteredMaterialTransactions.length,
      itemBuilder: (context, index) {
        final transaction = viewModel.filteredMaterialTransactions[index];
        return _buildMaterialHistoryCard(context, transaction);
      },
    );
  }

  Widget _buildMaterialHistoryCard(BuildContext context, dynamic transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(transaction.materialName, style: bodyBoldStyle(context)),
                Text(formatDate(transaction.date), style: captionStyle(context)),
              ],
            ),
            verticalSpaceSmall,
            Row(
              children: [
                Icon(
                  transaction.type == 'in' ? Icons.add : Icons.remove,
                  size: 16,
                  color: transaction.type == 'in' ? kcSuccessColor : kcWarningColor,
                ),
                horizontalSpaceTiny,
                Text(
                  '${transaction.type == 'in' ? '+' : '-'}${transaction.quantity}',
                  style: bodyStyle(context).copyWith(
                    color: transaction.type == 'in' ? kcSuccessColor : kcWarningColor,
                  ),
                ),
                horizontalSpaceSmall,
                Text('→ ${transaction.newStock}', style: bodyBoldStyle(context)),
              ],
            ),
            if (transaction.reason.isNotEmpty) ...[
              verticalSpaceTiny,
              Text('Reason: ${transaction.reason}', style: captionStyle(context)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Pending': color = kcWarningColor; break;
      case 'Produksi': color = kcInfoColor; break;
      case 'Selesai': color = kcSuccessColor; break;
      default: color = kcPrimaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: captionStyle(context).copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProductionStageChip(String stage, int quantity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kcInfoColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$stage: $quantity',
        style: captionStyle(context).copyWith(color: kcInfoColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: kcSecondaryTextColor.withOpacity(0.5)),
          verticalSpaceMedium,
          Text(message, style: bodyStyle(context)),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, HistoryViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Last 7 Days'),
              onTap: () {
                viewModel.setDateRange(
                  DateTime.now().subtract(const Duration(days: 7)),
                  DateTime.now(),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Last 30 Days'),
              onTap: () {
                viewModel.setDateRange(
                  DateTime.now().subtract(const Duration(days: 30)),
                  DateTime.now(),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Last 3 Months'),
              onTap: () {
                viewModel.setDateRange(
                  DateTime.now().subtract(const Duration(days: 90)),
                  DateTime.now(),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Custom Range'),
              onTap: () async {
                Navigator.pop(context);
                await viewModel.selectCustomDateRange(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  HistoryViewModel viewModelBuilder(BuildContext context) => HistoryViewModel();

  @override
  void onViewModelReady(HistoryViewModel viewModel) => viewModel.init();
}