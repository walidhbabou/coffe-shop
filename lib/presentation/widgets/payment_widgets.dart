import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/payment_info.dart';
import '../../../domain/viewmodels/auth_viewmodel.dart';
import '../../data/services/user_data_service.dart';
import '../../services/invoice_service.dart';
import '../../../data/models/invoice_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import './styled_button.dart';
import '../../../presentation/pages/Scan/scan_pay_page.dart';

// Widget pour le conteneur de chargement
Widget buildLoadingContainer({
  required Color primaryColor,
  double padding = 20,
}) {
  return Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 5,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.brown),
      strokeWidth: 3,
    ),
  );
}

// Widget pour le texte stylisé
Widget buildStyledText({
  required String text,
  required Color primaryColor,
  double fontSize = 16,
  Color? color,
  bool isBold = false,
  FontWeight fontWeight = FontWeight.normal,
}) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : fontWeight,
      color: color ?? primaryColor,
    ),
  );
}

// Widget pour la décoration des boîtes
BoxDecoration buildBoxDecoration({
  required Color color,
  Gradient? gradient,
  bool isCircle = false,
  bool hasElevation = false,
  bool hasBorder = false,
}) {
  return BoxDecoration(
    color: gradient == null ? color : null,
    gradient: gradient,
    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
    borderRadius: isCircle ? null : BorderRadius.circular(20),
    border: hasBorder ? Border.all(color: color.withOpacity(0.1), width: 1) : null,
    boxShadow: hasElevation ? [
      BoxShadow(
        color: color.withOpacity(0.1),
        blurRadius: 20,
        spreadRadius: 5,
        offset: hasElevation ? const Offset(0, 8) : Offset.zero,
      ),
    ] : null,
  );
}

// Widget pour le sélecteur de méthode de paiement
Widget buildPaymentMethodSelector({
  required String? selectedPaymentMethod,
  required VoidCallback onTap,
  required Color primaryColor,
}) {
  final isSelected = selectedPaymentMethod != null;
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.green : primaryColor.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.payment,
            color: isSelected ? Colors.green : primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildStyledText(
              text: selectedPaymentMethod ?? 'Choisir une méthode de paiement',
              fontSize: 16,
              color: isSelected ? Colors.green.shade700 : primaryColor.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              primaryColor: primaryColor,
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: primaryColor.withOpacity(0.4)),
        ],
      ),
    ),
  );
}

// Widget pour l'en-tête des instructions
Widget buildInstructionHeader({
  required Color primaryColor,
  required String title,
}) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
      ),
      const SizedBox(width: 12),
      buildStyledText(
        text: title,
        fontSize: 18,
        isBold: true,
        color: primaryColor.withOpacity(0.7),
        primaryColor: primaryColor,
      ),
    ],
  );
}

// Widget pour le conteneur modale
Widget buildModalContent({
  required String title,
  required Widget content,
  required Color primaryColor,
  bool hasAddButton = false,
  VoidCallback? onAdd,
}) {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildStyledText(
                text: title,
                fontSize: 22,
                isBold: true,
                color: primaryColor.withOpacity(0.7),
                primaryColor: primaryColor,
              ),
              if (hasAddButton && onAdd != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAdd,
                ),
            ],
          ),
        ),
        Expanded(child: content),
      ],
    ),
  );
}

// Widget pour l'état vide des cartes
Widget buildEmptyCardsState({
  required Color primaryColor,
  required VoidCallback onAdd,
}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.credit_card_off, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        buildStyledText(
          text: 'Aucune carte enregistrée',
          fontSize: 18,
          color: Colors.grey.shade600,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 24),
        StyledButton(
          text: 'Ajouter une carte',
          color: primaryColor,
          onPressed: onAdd,
        ),
      ],
    ),
  );
}

// Widget pour la confirmation de suppression
Widget buildDeleteConfirmation({
  required BuildContext context,
  required Color primaryColor,
  required String paymentMethodId,
  required VoidCallback onDelete,
}) {
  return AlertDialog(
    title: buildStyledText(
      text: 'Supprimer cette méthode de paiement',
      fontSize: 18,
      isBold: true,
      color: primaryColor.withOpacity(0.7),
      primaryColor: primaryColor,
    ),
    content: buildStyledText(
      text: 'Êtes-vous sûr de vouloir supprimer cette méthode de paiement?',
      color: primaryColor.withOpacity(0.6),
      primaryColor: primaryColor,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: buildStyledText(
          text: 'Annuler',
          fontWeight: FontWeight.w600,
          color: primaryColor.withOpacity(0.6),
          primaryColor: primaryColor,
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          onDelete();
        },
        child: buildStyledText(
          text: 'Supprimer',
          fontWeight: FontWeight.w600,
          color: Colors.red,
          primaryColor: primaryColor,
        ),
      ),
    ],
  );
}
