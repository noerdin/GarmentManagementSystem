import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../ui/app_colors.dart';
import '../../ui/text_style.dart';
import '../../ui/ui_helpers.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget builder(
      BuildContext context,
      HomeViewModel viewModel,
      Widget? child,
      ) {
    return Scaffold(
      backgroundColor: kcBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Garment Production System',
          style: heading3Style(context).copyWith(color: Colors.white),
        ),
        backgroundColor: kcPrimaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to',
                        style: heading3Style(context),
                      ),
                      verticalSpaceTiny,
                      Text(
                        'Garment Production Management System',
                        style: heading2Style(context)
                            .copyWith(color: kcPrimaryColor),
                      ),
                      verticalSpaceMedium,
                      Text(
                        'A comprehensive solution for managing your garment production process from order to delivery.',
                        style: bodyStyle(context),
                      ),
                    ],
                  ),
                ),
              ),
              verticalSpaceLarge,

              // Main features section
              Text(
                'Main Features',
                style: heading3Style(context),
              ),
              verticalSpaceMedium,
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildFeatureCard(
                      context,
                      icon: Icons.shopping_cart,
                      title: 'Order Management',
                      description: 'Track and manage customer orders',
                      color: kcPrimaryColor,
                      onTap: viewModel.navigateToOrders,
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.inventory_2,
                      title: 'Inventory Management',
                      description: 'Manage materials and supplies',
                      color: kcSecondaryColor,
                      onTap: viewModel.navigateToMaterials,
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.precision_manufacturing,
                      title: 'Production Tracking',
                      description: 'Monitor production process',
                      color: kcCuttingColor,
                      onTap: viewModel.navigateToProduction,
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.local_shipping,
                      title: 'Shipping Management',
                      description: 'Track shipments and deliveries',
                      color: kcSewingColor,
                      onTap: viewModel.navigateToShipping,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              verticalSpaceMedium,
              Text(
                title,
                style: heading4Style(context),
                textAlign: TextAlign.center,
              ),
              verticalSpaceSmall,
              Text(
                description,
                style: captionStyle(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  HomeViewModel viewModelBuilder(
      BuildContext context,
      ) =>
      HomeViewModel();
}
