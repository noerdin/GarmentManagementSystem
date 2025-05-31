import 'package:csj/features/shipping/shipping_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';

class ShippingView extends StackedView<ShippingViewModel> {
  const ShippingView({super.key});

  @override
  Widget builder(
      BuildContext context,
      ShippingViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Shipping Management',
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
        onPressed: viewModel.showAddShippingDialog,
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

  Widget _buildBody(BuildContext context, ShippingViewModel viewModel) {
    if (viewModel.shipments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 80,
              color: kcPrimaryColor.withOpacity(0.5),
            ),
            verticalSpaceMedium,
            Text(
              'No Shipments Yet',
              style: heading3Style(context),
            ),
            verticalSpaceSmall,
            Text(
              'Start by adding a new shipment record',
              style: bodyStyle(context),
            ),
            verticalSpaceLarge,
            ElevatedButton.icon(
              onPressed: viewModel.showAddShippingDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: Text(
                'Add Shipment',
                style: buttonTextStyle(context),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refreshData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: viewModel.filterShipments,
                    decoration: InputDecoration(
                      hintText: 'Search by Order ID or Destination',
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
                    onPressed: viewModel.showFilterOptions,
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filter',
                    color: kcPrimaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Shipments list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewModel.filteredShipments.length,
              itemBuilder: (context, index) {
                final shipment = viewModel.filteredShipments[index];
                return _buildShipmentCard(context, shipment, viewModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(
      BuildContext context, dynamic shipment, ShippingViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => viewModel.showShipmentDetails(shipment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with shipping ID and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      shipment.shippingId,
                      style: const TextStyle(
                        color: kcPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    formatDate(shipment.tanggal),
                    style: captionStyle(context),
                  ),
                ],
              ),
              verticalSpaceMedium,

              // Order and destination info
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
                              'Order ID: ${shipment.orderId}',
                              style: bodyBoldStyle(context),
                            ),
                          ],
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
                            Expanded(
                              child: Text(
                                'To: ${shipment.tujuan}',
                                style: bodyStyle(context),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
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
              verticalSpaceMedium,

              // Tracking info (if available)
              if (shipment.resi.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 18,
                      color: kcSecondaryTextColor,
                    ),
                    horizontalSpaceSmall,
                    Expanded(
                      child: Text(
                        'Tracking: ${shipment.resi}',
                        style: bodyStyle(context),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.content_copy,
                        size: 18,
                        color: kcPrimaryColor,
                      ),
                      onPressed: () =>
                          viewModel.copyTrackingNumber(shipment.resi),
                      tooltip: 'Copy tracking number',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],

              // Notes (if available)
              if (shipment.keterangan.isNotEmpty) ...[
                verticalSpaceSmall,
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
                        'Notes: ${shipment.keterangan}',
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
  ShippingViewModel viewModelBuilder(BuildContext context) =>
      ShippingViewModel();

  @override
  void onViewModelReady(ShippingViewModel viewModel) => viewModel.init();
}
