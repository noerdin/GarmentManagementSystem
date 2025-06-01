import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ui/app_colors.dart';
import '../ui/text_style.dart';
import '../ui/ui_helpers.dart';

class StockUpdateDialog extends StatefulWidget {
  final String materialName;
  final int currentStock;
  final String unit;
  final Function(int newStock, String reason) onStockUpdate;

  const StockUpdateDialog({
    super.key,
    required this.materialName,
    required this.currentStock,
    required this.unit,
    required this.onStockUpdate,
  });

  @override
  State<StockUpdateDialog> createState() => _StockUpdateDialogState();
}

class _StockUpdateDialogState extends State<StockUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  String _operationType = 'add'; // 'add' or 'subtract'
  int _newStock = 0;

  @override
  void initState() {
    super.initState();
    _newStock = widget.currentStock;
    _quantityController.addListener(_calculateNewStock);
  }

  void _calculateNewStock() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      if (_operationType == 'add') {
        _newStock = widget.currentStock + quantity;
      } else {
        _newStock = widget.currentStock - quantity;
      }
    });
  }

  void _setOperationType(String type) {
    setState(() {
      _operationType = type;
      _calculateNewStock();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.inventory,
                    color: kcPrimaryColor,
                    size: 28,
                  ),
                  horizontalSpaceSmall,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Stock',
                          style: heading3Style(context),
                        ),
                        Text(
                          widget.materialName,
                          style: subtitleStyle(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              verticalSpaceLarge,

              // Current Stock Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kcPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Stock:',
                      style: bodyBoldStyle(context),
                    ),
                    Text(
                      '${widget.currentStock} ${widget.unit}',
                      style: bodyBoldStyle(context).copyWith(
                        color: kcPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpaceMedium,

              // Operation Type Selection
              Text(
                'Operation Type:',
                style: bodyBoldStyle(context),
              ),
              verticalSpaceSmall,
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.add, color: kcSuccessColor, size: 20),
                          horizontalSpaceTiny,
                          Text('Stock In', style: bodyStyle(context)),
                        ],
                      ),
                      value: 'add',
                      groupValue: _operationType,
                      onChanged: (value) => _setOperationType(value!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.remove, color: kcWarningColor, size: 20),
                          horizontalSpaceTiny,
                          Text('Stock Out', style: bodyStyle(context)),
                        ],
                      ),
                      value: 'subtract',
                      groupValue: _operationType,
                      onChanged: (value) => _setOperationType(value!),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              verticalSpaceMedium,

              // Quantity Input
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  prefixIcon: Icon(
                    _operationType == 'add' ? Icons.add : Icons.remove,
                    color: _operationType == 'add' ? kcSuccessColor : kcWarningColor,
                  ),
                  suffixText: widget.unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  if (_operationType == 'subtract' && quantity > widget.currentStock) {
                    return 'Cannot subtract more than current stock';
                  }
                  return null;
                },
              ),
              verticalSpaceMedium,

              // New Stock Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _newStock < 0
                      ? kcErrorColor.withOpacity(0.1)
                      : _newStock < 10
                      ? kcWarningColor.withOpacity(0.1)
                      : kcSuccessColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _newStock < 0
                        ? kcErrorColor
                        : _newStock < 10
                        ? kcWarningColor
                        : kcSuccessColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Stock:',
                      style: bodyBoldStyle(context),
                    ),
                    Row(
                      children: [
                        Text(
                          '$_newStock ${widget.unit}',
                          style: bodyBoldStyle(context).copyWith(
                            color: _newStock < 0
                                ? kcErrorColor
                                : _newStock < 10
                                ? kcWarningColor
                                : kcSuccessColor,
                          ),
                        ),
                        if (_newStock < 0) ...[
                          horizontalSpaceSmall,
                          Icon(Icons.error, color: kcErrorColor, size: 20),
                        ] else if (_newStock < 10) ...[
                          horizontalSpaceSmall,
                          Icon(Icons.warning, color: kcWarningColor, size: 20),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              if (_newStock < 0) ...[
                verticalSpaceSmall,
                Text(
                  'Warning: This operation will result in negative stock!',
                  style: captionStyle(context).copyWith(color: kcErrorColor),
                ),
              ] else if (_newStock < 10) ...[
                verticalSpaceSmall,
                Text(
                  'Warning: Stock will be below recommended minimum level.',
                  style: captionStyle(context).copyWith(color: kcWarningColor),
                ),
              ],

              verticalSpaceMedium,

              // Reason Input
              TextFormField(
                controller: _reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Reason (Optional)',
                  prefixIcon: const Icon(Icons.note),
                  hintText: 'e.g., Production usage, Received shipment, Damage, etc.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kcPrimaryColor, width: 2),
                  ),
                ),
              ),
              verticalSpaceLarge,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: kcPrimaryColor),
                      ),
                      child: Text(
                        'Cancel',
                        style: buttonTextStyle(context).copyWith(
                          color: kcPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                  horizontalSpaceMedium,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _newStock < 0 ? null : () {
                        if (_formKey.currentState!.validate()) {
                          widget.onStockUpdate(
                            _newStock,
                            _reasonController.text.isEmpty
                                ? '${_operationType == 'add' ? 'Stock In' : 'Stock Out'} - ${_quantityController.text} ${widget.unit}'
                                : _reasonController.text,
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kcPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Update Stock',
                        style: buttonTextStyle(context),
                      ),
                    ),
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
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}