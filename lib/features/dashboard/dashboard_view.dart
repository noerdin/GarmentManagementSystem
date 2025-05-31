import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'dashboard_viewmodel.dart';

class DashboardView extends StackedView<DashboardViewModel> {
  const DashboardView({super.key});

  @override
  Widget builder(
      BuildContext context,
      DashboardViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Dashboard',
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
            icon: const Icon(Icons.logout),
            onPressed: viewModel.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: kcPrimaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 35,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: kcPrimaryColor,
                    ),
                  ),
                  verticalSpaceSmall,
                  Text(
                    viewModel.userName,
                    style: heading4Style(context).copyWith(color: Colors.white),
                  ),
                  Text(
                    viewModel.userRole,
                    style: subtitleStyle(context)
                        .copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: kcPrimaryColor),
              title: const Text('Dashboard'),
              selected: true,
              selectedTileColor: kcPrimaryColor.withOpacity(0.1),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined),
              title: const Text('Order'),
              onTap: () {
                Navigator.pop(context);
                viewModel.navigateToOrders();
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Material & Inventory'),
              onTap: () {
                Navigator.pop(context);
                viewModel.navigateToMaterials();
              },
            ),
            ListTile(
              leading: const Icon(Icons.precision_manufacturing_outlined),
              title: const Text('Production'),
              onTap: () {
                Navigator.pop(context);
                viewModel.navigateToProduction();
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Shipping'),
              onTap: () {
                Navigator.pop(context);
                viewModel.navigateToShipping();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                viewModel.logout();
              },
            ),
          ],
        ),
      ),
      body: viewModel.isBusy
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: viewModel.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Stats Grid
              Text(
                'Order Summary',
                style: heading3Style(context),
              ),
              verticalSpaceMedium,
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Total Orders',
                    value: viewModel.totalOrders.toString(),
                    icon: Icons.shopping_cart,
                    color: kcPrimaryColor,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Pending',
                    value: viewModel.pendingOrders.toString(),
                    icon: Icons.pending_actions,
                    color: kcWarningColor,
                  ),
                  _buildStatCard(
                    context,
                    title: 'In Production',
                    value: viewModel.inProductionOrders.toString(),
                    icon: Icons.precision_manufacturing,
                    color: kcInfoColor,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Completed',
                    value: viewModel.completedOrders.toString(),
                    icon: Icons.check_circle_outline,
                    color: kcSuccessColor,
                  ),
                ],
              ),
              verticalSpaceLarge,

              // Alert Section
              if (viewModel.overdueOrders > 0 ||
                  viewModel.lowStockMaterials.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alerts',
                      style: heading3Style(context),
                    ),
                    verticalSpaceMedium,
                    if (viewModel.overdueOrders > 0)
                      _buildAlertCard(
                        context,
                        title: 'Overdue Orders',
                        description:
                        'You have ${viewModel.overdueOrders} orders past their deadline',
                        icon: Icons.warning_amber_rounded,
                        color: kcErrorColor,
                        onTap: viewModel.navigateToOrders,
                      ),
                    if (viewModel.overdueOrders > 0) verticalSpaceSmall,
                    if (viewModel.lowStockMaterials.isNotEmpty)
                      _buildAlertCard(
                        context,
                        title: 'Low Stock Materials',
                        description:
                        '${viewModel.lowStockMaterials.length} materials are running low on stock',
                        icon: Icons.inventory_2_outlined,
                        color: kcWarningColor,
                        onTap: viewModel.navigateToMaterials,
                      ),
                    verticalSpaceLarge,
                  ],
                ),

              // Recent Production
              if (viewModel.recentProductions.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Production',
                          style: heading3Style(context),
                        ),
                        TextButton(
                          onPressed: viewModel.navigateToProduction,
                          child: const Text(
                            'View All',
                            style: TextStyle(color: kcPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceSmall,
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewModel.recentProductions.length > 3
                          ? 3
                          : viewModel.recentProductions.length,
                      separatorBuilder: (context, index) =>
                      verticalSpaceSmall,
                      itemBuilder: (context, index) {
                        final production =
                        viewModel.recentProductions[index];
                        return _buildProductionCard(
                            context, production, viewModel);
                      },
                    ),
                    verticalSpaceLarge,
                  ],
                ),

              // Recent Shipments
              if (viewModel.recentShipments.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Shipments',
                          style: heading3Style(context),
                        ),
                        TextButton(
                          onPressed: viewModel.navigateToShipping,
                          child: const Text(
                            'View All',
                            style: TextStyle(color: kcPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceSmall,
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewModel.recentShipments.length > 3
                          ? 3
                          : viewModel.recentShipments.length,
                      separatorBuilder: (context, index) =>
                      verticalSpaceSmall,
                      itemBuilder: (context, index) {
                        final shipment = viewModel.recentShipments[index];
                        return _buildShipmentCard(
                            context, shipment, viewModel);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
        required String value,
        required IconData icon,
        required Color color}) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
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
          ),
          verticalSpaceMedium,
          Text(
            title,
            style: subtitleStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context,
      {required String title,
        required String description,
        required IconData icon,
        required Color color,
        required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              horizontalSpaceMedium,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: heading4Style(context),
                    ),
                    verticalSpaceTiny,
                    Text(
                      description,
                      style: bodyStyle(context),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: kcSecondaryTextColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductionCard(
      BuildContext context, dynamic production, DashboardViewModel viewModel) {
    Color tagColor;
    switch (production.tahap) {
      case 'Cutting':
        tagColor = kcCuttingColor;
        break;
      case 'Sewing':
        tagColor = kcSewingColor;
        break;
      case 'Packing':
        tagColor = kcPackingColor;
        break;
      default:
        tagColor = kcInfoColor;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        production.tahap,
                        style: TextStyle(
                          color: tagColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    horizontalSpaceSmall,
                    if (production.subTahap.isNotEmpty)
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
                          production.subTahap,
                          style: const TextStyle(
                            color: kcSecondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  formatDate(production.tanggal),
                  style: captionStyle(context),
                ),
              ],
            ),
            verticalSpaceSmall,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID: ${production.orderId}',
                        style: bodyBoldStyle(context),
                      ),
                      verticalSpaceTiny,
                      Text(
                        'Operator: ${production.operator}',
                        style: bodySmallStyle(context),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Qty: ${production.jumlah}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (production.keterangan.isNotEmpty) ...[
              verticalSpaceSmall,
              Text(
                'Note: ${production.keterangan}',
                style: captionStyle(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShipmentCard(
      BuildContext context, dynamic shipment, DashboardViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    const Icon(
                      Icons.local_shipping,
                      color: kcSuccessColor,
                    ),
                    horizontalSpaceSmall,
                    Text(
                      'Order ID: ${shipment.orderId}',
                      style: bodyBoldStyle(context),
                    ),
                  ],
                ),
                Text(
                  formatDate(shipment.tanggal),
                  style: captionStyle(context),
                ),
              ],
            ),
            verticalSpaceSmall,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To: ${shipment.tujuan}',
                        style: bodyStyle(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (shipment.resi.isNotEmpty) ...[
                        verticalSpaceTiny,
                        Text(
                          'Tracking: ${shipment.resi}',
                          style: bodySmallStyle(context),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kcSuccessColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Qty: ${shipment.jumlahDikirim}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  DashboardViewModel viewModelBuilder(BuildContext context) =>
      DashboardViewModel();

  @override
  void onViewModelReady(DashboardViewModel viewModel) => viewModel.init();
}
