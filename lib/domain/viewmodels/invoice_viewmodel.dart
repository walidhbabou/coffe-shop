// Placeholder for InvoiceViewModel
import 'package:flutter/material.dart';
import '../../services/invoice_service.dart';
import '../../data/models/invoice_model.dart';
import './auth_viewmodel.dart'; // Corrected import path

class InvoiceViewModel extends ChangeNotifier {
  final InvoiceService _invoiceService = InvoiceService();
  List<Invoice> _userInvoices = [];
  bool _isLoading = false;
  String? _error;

  List<Invoice> get userInvoices => _userInvoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // This might be initialized with a user ID from AuthViewModel later
  // For now, we can have a method to load invoices for a specific user

  void loadUserInvoices(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _invoiceService.getUserInvoices(userId).listen(
      (invoices) {
        _userInvoices = invoices;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
        print('Error loading user invoices: $e');
      },
    );
  }

  // Potentially add methods here to interact with invoices (e.g., view details)
}
