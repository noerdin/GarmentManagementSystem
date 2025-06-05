import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'orders_viewmodel.dart';

class OrdersView extends StackedView<OrdersViewModel> {
  const OrdersView({super.key});

  @override
  Widget builder(
      BuildContext context,
      OrdersViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Order Management',
          style: heading3Style(context).copyWith(color: Colors.white),
        ),
        backgroundColor: kcPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.refreshData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: viewModel.exportOrders,
            tooltip: 'Export Orders',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: viewModel.showAddOrderDialog,
        backgroundColor: kcPrimaryColor,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
      body: viewModel.isBusy
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, OrdersViewModel viewModel) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: kcPrimaryColor,
              unselectedLabelColor: kcSecondaryTextColor,
              indicatorColor: kcPrimaryColor,
              tabs: const [
                Tab(text: 'All', icon: Icon(Icons.list_alt, size: 16)),
                Tab(text: 'Pending', icon: Icon(Icons.pending_actions, size: 16)),
                Tab(text: 'Production', icon: Icon(Icons.precision_manufacturing, size: 16)),
                Tab(text: 'Completed', icon: Icon(Icons.check_circle, size: 16)),
              ],
              onTap: viewModel.setSelectedTab,
            ),
          ),

          // Search and filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: viewModel.filterOrders,
                    decoration: InputDecoration(
                      hintText: 'Search by Order ID, Customer, or Product',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: kcBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),
                ),
                horizontalSpaceSmall,
                Container(
                  decoration: BoxDecoration(
                    color: viewModel.showOverdueOnly ? kcErrorColor : kcBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: viewModel.showOverdueOnly ? kcErrorColor : kcLightGrey,
                    ),
                  ),
                  child: IconButton(
                    onPressed: viewModel.toggleOverdueFilter,
                    icon: Icon(
                      Icons.warning_amber_rounded,
                      color: viewModel.showOverdueOnly ? Colors.white : kcErrorColor,
                    ),
                    tooltip: 'Show Overdue Only',
                  ),
                ),
                horizontalSpaceSmall,
                Container(
                  decoration: BoxDecoration(
                    color: kcBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kcLightGrey),
                  ),
                  child: IconButton(
                    onPressed: viewModel.showFilterOptions,
                    icon: const Icon(Icons.filter_list, color: kcPrimaryColor),
                    tooltip: 'More Filters',
                  ),
                ),
              ],
            ),
          ),

          // Order Stats Summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: defaultBoxShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  title: 'Total',
                  value: viewModel.orders.length.toString(),
                  color: kcPrimaryColor,
                  icon: Icons.list_alt,
                ),
                _buildDivider(),
                _buildStatColumn(
                  context,
                  title: 'Pending',
                  value: viewModel.pendingCount.toString(),
                  color: kcWarningColor,
                  icon: Icons.pending_actions,
                ),
                _buildDivider(),
                _buildStatColumn(
                  context,
                  title: 'Production',
                  value: viewModel.productionCount.toString(),
                  color: kcInfoColor,
                  icon: Icons.precision_manufacturing,
                ),
                _buildDivider(),
                _buildStatColumn(
                  context,
                  title: 'Completed',
                  value: viewModel.completedCount.toString(),
                  color: kcSuccessColor,
                  icon: Icons.check_circle,
                ),
                if (viewModel.overdueCount > 0) ...[
                  _buildDivider(),
                  _buildStatColumn(
                    context,
                    title: 'Overdue',
                    value: viewModel.overdueCount.toString(),
                    color: kcErrorColor,
                    icon: Icons.warning,
                  ),
                ],
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: viewModel.displayedOrders.isEmpty
                ? _buildEmptyState(context, viewModel)
                : RefreshIndicator(
              onRefresh: viewModel.refreshData,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: viewModel.displayedOrders.length,
                itemBuilder: (context, index) {
                  final order = viewModel.displayedOrders[index];
                  return _buildEnhancedOrderCard(context, order, viewModel);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, OrdersViewModel viewModel) {
    String title = 'No Orders Found';
    String message = 'Start by creating your first order';
    IconData icon = Icons.shopping_cart_outlined;

    if (viewModel.showOverdueOnly) {
      title = 'No Overdue Orders';
      message = 'All orders are on schedule';
      icon = Icons.check_circle_outline;
    } else if (viewModel.selectedTab > 0) {
      final tabNames = ['', 'Pending', 'Production', 'Completed'];
      title = 'No ${tabNames[viewModel.selectedTab]} Orders';
      message = 'No orders in this category';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: kcPrimaryColor.withOpacity(0.5),
            ),
            verticalSpaceMedium,
            Text(
              title,
              style: heading3Style(context),
              textAlign: TextAlign.center,
            ),
            verticalSpaceSmall,
            Text(
              message,
              style: bodyStyle(context),
              textAlign: TextAlign.center,
            ),
            if (!viewModel.showOverdueOnly) ...[
              verticalSpaceLarge,
              ElevatedButton.icon(
                onPressed: viewModel.showAddOrderDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  'Create First Order',
                  style: buttonTextStyle(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
      BuildContext context, {
        required String title,
        required String value,
        required Color color,
        required IconData icon,
      }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        verticalSpaceTiny,
        Text(
          value,
          style: heading4Style(context).copyWith(color: color),
        ),
        Text(
          title,
          style: captionStyle(context),
          textAlign: TextAlign.center,
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

  Widget _buildEnhancedOrderCard(
      BuildContext context, dynamic order, OrdersViewModel viewModel) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case 'Pending':
        statusColor = kcWarningColor;
        statusIcon = Icons.pending_actions;
        break;
      case 'Produksi':
        statusColor = kcInfoColor;
        statusIcon = Icons.precision_manufacturing;
        break;
      case 'Selesai':
        statusColor = kcSuccessColor;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = kcPrimaryColor;
        statusIcon = Icons.help_outline;
    }

    final isOverdue = order.isOverdue;
    final daysRemaining = order.daysRemaining;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? BorderSide(color: kcErrorColor.withOpacity(0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => viewModel.showOrderDetails(order),
        onLongPress: () => _showOrderActions(context, order, viewModel),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order ID, status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 12, color: statusColor),
                            horizontalSpaceTiny,
                            Text(
                              order.displayStatus,
                              style: captionStyle(context).copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Order Date',
                        style: captionStyle(context),
                      ),
                      Text(
                        formatDate(order.tanggalOrder),
                        style: bodyStyle(context).copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpaceSmall,

              // Product and customer info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.namaProduk,
                          style: heading4Style(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        verticalSpaceTiny,
                        Row(
                          children: [
                            Icon(Icons.palette, size: 16, color: kcSecondaryTextColor),
                            horizontalSpaceTiny,
                            Text(
                              'Color: ${order.warna}',
                              style: bodyStyle(context),
                            ),
                          ],
                        ),
                        verticalSpaceTiny,
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 16, color: kcSecondaryTextColor),
                            horizontalSpaceTiny,
                            Expanded(
                              child: Text(
                                order.namaCustomer,
                                style: bodyStyle(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  horizontalSpaceMedium,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kcPrimaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${order.jumlahTotal} pcs',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                      if (order.estimasiMargin > 0) ...[
                        Text(
                          'Est. Price',
                          style: captionStyle(context),
                        ),
                        Text(
                          'Rp ${order.estimasiMargin.toStringAsFixed(0)}',
                          style: bodyStyle(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: kcSuccessColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              verticalSpaceSmall,

              // Size Breakdown
              if (order.ukuran.isNotEmpty) ...[
                Text(
                  'Size Distribution:',
                  style: captionStyle(context),
                ),
                verticalSpaceTiny,
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: order.ukuran.entries.map<Widget>((entry) {
                    if (entry.value > 0) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: kcInfoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: captionStyle(context).copyWith(
                            color: kcInfoColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ),
                verticalSpaceSmall,
              ],

              // Progress and overdue warning
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: bodyStyle(context).copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${(order.progress * 100).toInt()}%',
                        style: bodyStyle(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOverdue ? kcErrorColor : kcPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  verticalSpaceTiny,
                  customProgressIndicator(
                    value: order.progress,
                    color: isOverdue ? kcErrorColor : kcPrimaryColor,
                  ),
                  verticalSpaceSmall,

                  // Deadline Information
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: isOverdue ? kcErrorColor : kcSecondaryTextColor,
                          ),
                          horizontalSpaceTiny,
                          Text(
                            'Deadline: ${formatDate(order.deadlineProduksi)}',
                            style: bodyStyle(context).copyWith(
                              color: isOverdue ? kcErrorColor : null,
                            ),
                          ),
                        ],
                      ),
                      if (isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kcErrorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning, size: 12, color: kcErrorColor),
                              horizontalSpaceTiny,
                              Text(
                                'Overdue ${-daysRemaining} days',
                                style: captionStyle(context).copyWith(
                                  color: kcErrorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (daysRemaining <= 3 && order.status != 'Selesai')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kcWarningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer, size: 12, color: kcWarningColor),
                              horizontalSpaceTiny,
                              Text(
                                'Due in $daysRemaining days',
                                style: captionStyle(context).copyWith(
                                  color: kcWarningColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Notes (if any)
              if (order.catatan.isNotEmpty) ...[
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
                      Text(
                        'Notes:',
                        style: captionStyle(context).copyWith(fontWeight: FontWeight.w500),
                      ),
                      verticalSpaceTiny,
                      Text(
                        order.catatan,
                        style: captionStyle(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderActions(BuildContext context, dynamic order, OrdersViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order Actions',
              style: heading4Style(context),
            ),
            verticalSpaceMedium,
            ListTile(
              leading: const Icon(Icons.visibility, color: kcInfoColor),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                viewModel.showOrderDetails(order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: kcPrimaryColor),
              title: const Text('Edit Order'),
              onTap: () {
                Navigator.pop(context);
                viewModel.editOrder(order.orderId);
              },
            ),
            if (order.status != 'Selesai') ...[
              ListTile(
                leading: const Icon(Icons.update, color: kcWarningColor),
                title: const Text('Update Status'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.showUpdateStatusDialog(order);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.content_copy, color: kcSecondaryColor),
              title: const Text('Duplicate Order'),
              onTap: () {
                Navigator.pop(context);
                viewModel.duplicateOrder(order);
              },
            ),
            if (order.status == 'Pending') ...[
              ListTile(
                leading: const Icon(Icons.delete, color: kcErrorColor),
                title: const Text('Delete Order'),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.deleteOrder(order);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  OrdersViewModel viewModelBuilder(BuildContext context) => OrdersViewModel();

  @override
  void onViewModelReady(OrdersViewModel viewModel) => viewModel.init();
}
