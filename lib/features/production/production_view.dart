import 'package:csj/features/production/production_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';

class ProductionView extends StackedView<ProductionViewModel> {
  const ProductionView({super.key});

  @override
  Widget builder(
      BuildContext context,
      ProductionViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Production Management',
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
        onPressed: viewModel.showAddProductionDialog,
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

  Widget _buildBody(BuildContext context, ProductionViewModel viewModel) {
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
                Tab(text: 'Cutting'),
                Tab(text: 'Sewing'),
                Tab(text: 'Packing'),
              ],
              onTap: viewModel.setSelectedTab,
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: viewModel.filterProductions,
              decoration: InputDecoration(
                hintText: 'Search by Order ID or Operator',
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

          // Production Stats
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
                  title: 'Cutting',
                  value: viewModel.cuttingTotal.toString(),
                  color: kcCuttingColor,
                ),
                _buildDivider(),
                _buildStatColumn(
                  context,
                  title: 'Sewing',
                  value: viewModel.sewingTotal.toString(),
                  color: kcSewingColor,
                ),
                _buildDivider(),
                _buildStatColumn(
                  context,
                  title: 'Packing',
                  value: viewModel.packingTotal.toString(),
                  color: kcPackingColor,
                ),
              ],
            ),
          ),
          verticalSpaceMedium,

          // Production List
          Expanded(
            child: viewModel.displayedProductions.isEmpty
                ? _buildEmptyState(context, viewModel)
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.displayedProductions.length,
              itemBuilder: (context, index) {
                final production = viewModel.displayedProductions[index];
                return _buildProductionCard(
                    context, production, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ProductionViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.precision_manufacturing_outlined,
            size: 80,
            color: kcPrimaryColor.withOpacity(0.5),
          ),
          verticalSpaceMedium,
          Text(
            'No Production Records',
            style: heading3Style(context),
          ),
          verticalSpaceSmall,
          Text(
            'Start by adding a new production record',
            style: bodyStyle(context),
          ),
          verticalSpaceLarge,
          ElevatedButton.icon(
            onPressed: viewModel.showAddProductionDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: kcPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'Add Production Record',
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

  Widget _buildProductionCard(
      BuildContext context, dynamic production, ProductionViewModel viewModel) {
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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => viewModel.showProductionDetails(production),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with stage and date
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
              verticalSpaceMedium,

              // Order and operator info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_cart_outlined,
                              size: 18,
                              color: kcSecondaryTextColor,
                            ),
                            horizontalSpaceSmall,
                            Text(
                              'Order ID: ${production.orderId}',
                              style: bodyBoldStyle(context),
                            ),
                          ],
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
                              'Operator: ${production.operator}',
                              style: bodyStyle(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                      'Qty: ${production.jumlah}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Notes (if available)
              if (production.keterangan.isNotEmpty) ...[
                verticalSpaceMedium,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note_outlined,
                      size: 18,
                      color: kcSecondaryTextColor,
                    ),
                    horizontalSpaceSmall,
                    Expanded(
                      child: Text(
                        'Notes: ${production.keterangan}',
                        style: captionStyle(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  ProductionViewModel viewModelBuilder(BuildContext context) =>
      ProductionViewModel();

  @override
  void onViewModelReady(ProductionViewModel viewModel) => viewModel.init();
}
