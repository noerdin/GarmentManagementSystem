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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.showAddOrderDialog,
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
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Production'),
                Tab(text: 'Completed'),
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
                    onChanged: viewModel.filterOrders,
                    decoration: InputDecoration(
                      hintText: 'Search by Order ID or Customer',
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
                    onPressed: viewModel.toggleOverdueFilter,
                    icon: Icon(
                      Icons.warning_amber_rounded,
                      color: viewModel.showOverdueOnly
                          ? kcErrorColor
                          : kcPrimaryColor,
                    ),
                    tooltip: 'Overdue Filter',
                  ),
                ),
              ],
            ),
          ),

          // Order Stats
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
                  title: 'Pending',
                  value: viewModel.pendingCount.toString(),
                  color: kcWarningColor,
                ),
                _buildDivider(),
                _buildStatColumn(
                  context,
                  title: 'In Production',
                  value: viewModel.productionCount.toString(),
                  color: kcInfoColor,
                ),
                _buildDivider(),
                _buildStatColumn(
                  context,
                  title: 'Completed',
                  value: viewModel.completedCount.toString(),
                  color: kcSuccessColor,
                ),
              ],
            ),
          ),
          verticalSpaceMedium,

          // Orders List
          Expanded(
            child: viewModel.displayedOrders.isEmpty
                ? _buildEmptyState(context, viewModel)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.displayedOrders.length,
              itemBuilder: (context, index) {
                final order = viewModel.displayedOrders[index];
                return _buildOrderCard(context, order, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, OrdersViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: kcPrimaryColor.withOpacity(0.5),
          ),
          verticalSpaceMedium,
          Text(
            viewModel.showOverdueOnly ? 'No Overdue Orders' : 'No Orders Found',
            style: heading3Style(context),
          ),
          verticalSpaceSmall,
          Text(
            viewModel.showOverdueOnly
                ? 'All orders are on schedule'
                : 'Start by creating a new order',
            style: bodyStyle(context),
            textAlign: TextAlign.center,
          ),
          verticalSpaceLarge,
          if (!viewModel.showOverdueOnly)
            ElevatedButton.icon(
              onPressed: viewModel.showAddOrderDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Create Order',
                style: buttonTextStyle(context),
              ),
            ),
        ],
      ),
    );
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

  Widget _buildOrderCard(
      BuildContext context, dynamic order, OrdersViewModel viewModel) {
    Color statusColor;
    switch (order.status) {
      case 'Pending':
        statusColor = kcWarningColor;
        break;
      case 'Produksi':
        statusColor = kcInfoColor;
        break;
      case 'Selesai':
        statusColor = kcSuccessColor;
        break;
      default:
        statusColor = kcPrimaryColor;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: order.isOverdue
            ? BorderSide(color: kcErrorColor.withOpacity(0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => viewModel.showOrderDetails(order),
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
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kcPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.orderId,
                          style: const TextStyle(
                            color: kcPrimaryColor,
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
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.displayStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatDate(order.tanggalOrder),
                    style: captionStyle(context),
                  ),
                ],
              ),
              verticalSpaceMedium,

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
                          style: bodyBoldStyle(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        verticalSpaceTiny,
                        Text(
                          'Color: ${order.warna}',
                          style: bodySmallStyle(context),
                        ),
                        verticalSpaceSmall,
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 18,
                              color: kcSecondaryTextColor,
                            ),
                            horizontalSpaceSmall,
                            Text(
                              'Customer: ${order.namaCustomer}',
                              style: bodyStyle(context),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
                          color: kcPrimaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Qty: ${order.jumlahTotal}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      verticalSpaceSmall,
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: kcSecondaryTextColor,
                          ),
                          horizontalSpaceTiny,
                          Text(
                            'Due: ${formatDate(order.deadlineProduksi)}',
                            style: subtitleStyle(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              verticalSpaceMedium,

              // Progress and overdue warning
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: subtitleStyle(context),
                      ),
                      Text(
                        '${(order.progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: kcPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  verticalSpaceTiny,
                  customProgressIndicator(
                    value: order.progress,
                    color: order.isOverdue ? kcErrorColor : kcPrimaryColor,
                  ),
                  if (order.isOverdue) ...[
                    verticalSpaceSmall,
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: kcErrorColor,
                          size: 16,
                        ),
                        horizontalSpaceTiny,
                        Text(
                          'Overdue by ${-order.daysRemaining} days',
                          style: const TextStyle(
                            color: kcErrorColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ] else if (order.daysRemaining <= 3 &&
                      order.status != 'Selesai') ...[
                    verticalSpaceSmall,
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: kcWarningColor,
                          size: 16,
                        ),
                        horizontalSpaceTiny,
                        Text(
                          'Due in ${order.daysRemaining} days',
                          style: const TextStyle(
                            color: kcWarningColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  OrdersViewModel viewModelBuilder(BuildContext context) => OrdersViewModel();

  @override
  void onViewModelReady(OrdersViewModel viewModel) => viewModel.init();
}
