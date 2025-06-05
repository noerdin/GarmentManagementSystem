import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'enhanced_dashboard_viewmodel.dart';

class EnhancedDashboardView extends StackedView<EnhancedDashboardViewModel> {
  const EnhancedDashboardView({super.key});

  @override
  Widget builder(
      BuildContext context,
      EnhancedDashboardViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Production Dashboard',
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
            icon: const Icon(Icons.history),
            onPressed: viewModel.showHistoryDialog,
            tooltip: 'View History',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: viewModel.logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: _buildDrawer(context, viewModel),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: viewModel.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Row
              _buildQuickStatsRow(context, viewModel),
              verticalSpaceLarge,

              // Production Overview Charts
              _buildProductionCharts(context, viewModel),
              verticalSpaceLarge,

              // Order Status Grid
              _buildOrderStatusGrid(context, viewModel),
              verticalSpaceLarge,

              // Daily Production Progress
              _buildDailyProductionProgress(context, viewModel),
              verticalSpaceLarge,

              // Material Status
              _buildMaterialStatus(context, viewModel),
              verticalSpaceLarge,

              // Recent Activities
              _buildRecentActivities(context, viewModel),
              verticalSpaceLarge,

              // Production Performance
              _buildProductionPerformance(context, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, EnhancedDashboardViewModel viewModel) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: kcPrimaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person, size: 35, color: kcPrimaryColor),
                ),
                verticalSpaceSmall,
                Text(
                  viewModel.userName,
                  style: heading4Style(context).copyWith(color: Colors.white),
                ),
                Text(
                  viewModel.userRole,
                  style: subtitleStyle(context).copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', true, () {}),
          _buildDrawerItem(Icons.shopping_cart_outlined, 'Orders', false,
              viewModel.navigateToOrders),
          _buildDrawerItem(Icons.inventory_2_outlined, 'Materials', false,
              viewModel.navigateToMaterials),
          _buildDrawerItem(Icons.precision_manufacturing_outlined, 'Production', false,
              viewModel.navigateToProduction),
          _buildDrawerItem(Icons.local_shipping_outlined, 'Shipping', false,
              viewModel.navigateToShipping),
          _buildDrawerItem(Icons.history, 'History', false,
              viewModel.showHistoryDialog),
          const Divider(),
          _buildDrawerItem(Icons.logout, 'Logout', false, viewModel.logout),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, bool selected, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: selected ? kcPrimaryColor : Colors.grey[600]),
      title: Text(title),
      selected: selected,
      selectedTileColor: kcPrimaryColor.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildQuickStatsRow(BuildContext context, EnhancedDashboardViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            context,
            'Total Orders',
            viewModel.totalOrders.toString(),
            Icons.shopping_cart,
            kcPrimaryColor,
            '${viewModel.orderGrowth}%',
          ),
        ),
        horizontalSpaceMedium,
        Expanded(
          child: _buildQuickStatCard(
            context,
            'In Production',
            viewModel.activeProductions.toString(),
            Icons.precision_manufacturing,
            kcInfoColor,
            '${viewModel.productionEfficiency}%',
          ),
        ),
        horizontalSpaceMedium,
        Expanded(
          child: _buildQuickStatCard(
            context,
            'Completed Today',
            viewModel.completedToday.toString(),
            Icons.check_circle,
            kcSuccessColor,
            '${viewModel.completionRate}%',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(BuildContext context, String title, String value,
      IconData icon, Color color, String growth) {
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
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  growth,
                  style: captionStyle(context).copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          verticalSpaceMedium,
          Text(
            value,
            style: heading2Style(context).copyWith(color: color),
          ),
          Text(
            title,
            style: subtitleStyle(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionCharts(BuildContext context, EnhancedDashboardViewModel viewModel) {
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
          Text(
            'Production Overview',
            style: heading4Style(context),
          ),
          verticalSpaceMedium,
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Pie Chart untuk Production Stages
                Expanded(
                  flex: 1,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: viewModel.cuttingProgress.toDouble(),
                          title: 'Cutting\n${viewModel.cuttingProgress}%',
                          color: kcCuttingColor,
                          radius: 60,
                          titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: viewModel.sewingProgress.toDouble(),
                          title: 'Sewing\n${viewModel.sewingProgress}%',
                          color: kcSewingColor,
                          radius: 60,
                          titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: viewModel.finishingProgress.toDouble(),
                          title: 'Finishing\n${viewModel.finishingProgress}%',
                          color: kcPackingColor,
                          radius: 60,
                          titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                horizontalSpaceMedium,
                // Bar Chart untuk Daily Production
                Expanded(
                  flex: 2,
                  child: BarChart(
                    BarChartData(
                      maxY: 100,
                      barGroups: viewModel.weeklyProductionData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: kcPrimaryColor,
                              width: 20,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                              return Text(days[value.toInt() % 7], style: captionStyle(context));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusGrid(BuildContext context, EnhancedDashboardViewModel viewModel) {
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
          Text(
            'Order Status Distribution',
            style: heading4Style(context),
          ),
          verticalSpaceMedium,
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _buildStatusCard(context, 'Pending', viewModel.pendingOrders, kcWarningColor),
              _buildStatusCard(context, 'In Production', viewModel.inProductionOrders, kcInfoColor),
              _buildStatusCard(context, 'Completed', viewModel.completedOrders, kcSuccessColor),
              _buildStatusCard(context, 'Overdue', viewModel.overdueOrders, kcErrorColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: Text(
              title,
              style: bodyBoldStyle(context).copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProductionProgress(BuildContext context, EnhancedDashboardViewModel viewModel) {
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
              Text('Today\'s Production Progress', style: heading4Style(context)),
              Text('${viewModel.dailyTargetCompletion}% of target', style: subtitleStyle(context)),
            ],
          ),
          verticalSpaceMedium,
          Column(
            children: [
              _buildProgressRow(context, 'Cutting', viewModel.todayCutting, viewModel.targetCutting),
              _buildProgressRow(context, 'Sewing', viewModel.todaySewing, viewModel.targetSewing),
              _buildProgressRow(context, 'Finishing', viewModel.todayFinishing, viewModel.targetFinishing),
              _buildProgressRow(context, 'Washing', viewModel.todayWashing, viewModel.targetWashing),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(BuildContext context, String stage, int current, int target) {
    final progress = target > 0 ? current / target : 0.0;
    final color = _getStageColor(stage);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stage, style: bodyBoldStyle(context)),
              Text('$current / $target', style: subtitleStyle(context)),
            ],
          ),
          verticalSpaceTiny,
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'cutting': return kcCuttingColor;
      case 'sewing': return kcSewingColor;
      case 'finishing': return kcPackingColor;
      case 'washing': return kcInfoColor;
      default: return kcPrimaryColor;
    }
  }

  Widget _buildMaterialStatus(BuildContext context, EnhancedDashboardViewModel viewModel) {
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
              Text('Material Status', style: heading4Style(context)),
              TextButton(
                onPressed: viewModel.navigateToMaterials,
                child: const Text('View All'),
              ),
            ],
          ),
          verticalSpaceSmall,
          if (viewModel.lowStockMaterials.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kcWarningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kcWarningColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: kcWarningColor),
                  horizontalSpaceSmall,
                  Expanded(
                    child: Text(
                      '${viewModel.lowStockMaterials.length} materials are running low',
                      style: bodyStyle(context).copyWith(color: kcWarningColor),
                    ),
                  ),
                ],
              ),
            ),
            verticalSpaceSmall,
          ],
          Row(
            children: [
              Expanded(
                child: _buildMaterialStat(context, 'Total Materials', viewModel.totalMaterials),
              ),
              Expanded(
                child: _buildMaterialStat(context, 'Low Stock', viewModel.lowStockCount),
              ),
              Expanded(
                child: _buildMaterialStat(context, 'Out of Stock', viewModel.outOfStockCount),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialStat(BuildContext context, String title, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: heading3Style(context).copyWith(color: kcPrimaryColor),
        ),
        Text(
          title,
          style: captionStyle(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context, EnhancedDashboardViewModel viewModel) {
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
          Text('Recent Activities', style: heading4Style(context)),
          verticalSpaceMedium,
          ...viewModel.recentActivities.take(5).map((activity) =>
              _buildActivityItem(context, activity)).toList(),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActivityColor(activity['type']).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getActivityIcon(activity['type']),
              color: _getActivityColor(activity['type']),
              size: 16,
            ),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['description'],
                  style: bodyStyle(context),
                ),
                Text(
                  activity['time'],
                  style: captionStyle(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'order': return Icons.shopping_cart;
      case 'production': return Icons.precision_manufacturing;
      case 'shipping': return Icons.local_shipping;
      case 'material': return Icons.inventory_2;
      default: return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'order': return kcWarningColor;
      case 'production': return kcInfoColor;
      case 'shipping': return kcSuccessColor;
      case 'material': return kcSecondaryColor;
      default: return kcPrimaryColor;
    }
  }

  Widget _buildProductionPerformance(BuildContext context, EnhancedDashboardViewModel viewModel) {
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
          Text('Production Performance', style: heading4Style(context)),
          verticalSpaceMedium,
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetric(
                  context,
                  'Efficiency',
                  '${viewModel.overallEfficiency}%',
                  viewModel.overallEfficiency >= 80 ? kcSuccessColor : kcWarningColor,
                ),
              ),
              Expanded(
                child: _buildPerformanceMetric(
                  context,
                  'Quality Score',
                  '${viewModel.qualityScore}%',
                  viewModel.qualityScore >= 90 ? kcSuccessColor : kcWarningColor,
                ),
              ),
              Expanded(
                child: _buildPerformanceMetric(
                  context,
                  'On Time Delivery',
                  '${viewModel.onTimeDelivery}%',
                  viewModel.onTimeDelivery >= 85 ? kcSuccessColor : kcErrorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetric(BuildContext context, String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: heading3Style(context).copyWith(color: color),
        ),
        Text(
          title,
          style: captionStyle(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  EnhancedDashboardViewModel viewModelBuilder(BuildContext context) =>
      EnhancedDashboardViewModel();

  @override
  void onViewModelReady(EnhancedDashboardViewModel viewModel) => viewModel.init();
}