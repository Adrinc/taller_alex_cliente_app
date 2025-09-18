import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/theme/theme.dart';

class PromocionesPage extends StatefulWidget {
  const PromocionesPage({super.key});

  @override
  State<PromocionesPage> createState() => _PromocionesPageState();
}

class _PromocionesPageState extends State<PromocionesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _walletAnimationController;

  // Datos de demo
  final List<Map<String, dynamic>> _activePromotions = [
    {
      'id': 'PROMO-001',
      'title': 'Cambio de Aceite + Filtros',
      'description':
          '2x1 en cambio de aceite incluye filtro de aceite y aire gratis',
      'discount': 50,
      'type': 'percentage',
      'validUntil': DateTime(2024, 12, 31),
      'minAmount': 800.0,
      'image': 'assets/images/promo1.jpg',
      'category': 'mantenimiento',
      'isNew': true,
      'terms': [
        'Válido solo para vehículos particulares',
        'No aplica con otras promociones',
        'Aceite sintético con costo adicional',
      ],
    },
    {
      'id': 'PROMO-002',
      'title': 'Afinación Completa',
      'description': 'Afinación mayor con 30% de descuento en mano de obra',
      'discount': 30,
      'type': 'percentage',
      'validUntil': DateTime(2024, 11, 15),
      'minAmount': 2000.0,
      'image': 'assets/images/promo2.jpg',
      'category': 'afinacion',
      'isNew': false,
      'terms': [
        'Incluye bujías, cables y filtros',
        'Válido de lunes a viernes',
        'Cita previa requerida',
      ],
    },
    {
      'id': 'PROMO-003',
      'title': 'Diagnóstico Gratis',
      'description':
          'Diagnóstico computarizado gratuito en servicios mayores a \$1500',
      'discount': 350,
      'type': 'fixed',
      'validUntil': DateTime(2024, 10, 31),
      'minAmount': 1500.0,
      'image': 'assets/images/promo3.jpg',
      'category': 'diagnostico',
      'isNew': true,
      'terms': [
        'Solo una vez por cliente',
        'Aplica en servicios de reparación',
        'Válido en todas las sucursales',
      ],
    },
  ];

  final List<Map<String, dynamic>> _myCoupons = [
    {
      'id': 'CUP-2024-001',
      'promoId': 'PROMO-001',
      'title': 'Cambio de Aceite 2x1',
      'discount': 50,
      'type': 'percentage',
      'validUntil': DateTime(2024, 12, 31),
      'status': 'disponible',
      'dateAdded': DateTime(2024, 9, 15),
      'usedDate': null,
    },
    {
      'id': 'CUP-2024-002',
      'promoId': 'PROMO-003',
      'title': 'Diagnóstico Gratis',
      'discount': 350,
      'type': 'fixed',
      'validUntil': DateTime(2024, 10, 31),
      'status': 'disponible',
      'dateAdded': DateTime(2024, 9, 10),
      'usedDate': null,
    },
    {
      'id': 'CUP-2024-003',
      'promoId': 'PROMO-002',
      'title': 'Afinación 30% OFF',
      'discount': 30,
      'type': 'percentage',
      'validUntil': DateTime(2024, 9, 15),
      'status': 'usado',
      'dateAdded': DateTime(2024, 8, 20),
      'usedDate': DateTime(2024, 9, 5),
    },
  ];

  final double _walletBalance = 1250.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _walletAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _walletAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _walletAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _availableCoupons {
    return _myCoupons
        .where((coupon) =>
            coupon['status'] == 'disponible' &&
            DateTime.now().isBefore(coupon['validUntil']))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TallerAlexColors.neumorphicBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TallerAlexColors.neumorphicBackground,
              TallerAlexColors.paleRose.withOpacity(0.1),
              TallerAlexColors.neumorphicBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      NeumorphicButton(
                        onPressed: () => context.go('/dashboard'),
                        padding: const EdgeInsets.all(12),
                        borderRadius: 12,
                        child: Icon(
                          Icons.arrow_back,
                          color: TallerAlexColors.primaryFuchsia,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Promociones',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: TallerAlexColors.textPrimary,
                          ),
                        ),
                      ),
                      // Wallet balance
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: TallerAlexColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: TallerAlexColors.primaryFuchsia
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${_walletBalance.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Wallet de cupones disponibles
              if (_availableCoupons.isNotEmpty)
                FadeIn(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildWalletCard(),
                  ),
                ),

              const SizedBox(height: 20),

              // Tabs
              FadeIn(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: NeumorphicCard(
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: TallerAlexColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: TallerAlexColors.textSecondary,
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(text: 'Promociones (${_activePromotions.length})'),
                        Tab(text: 'Mis Cupones (${_myCoupons.length})'),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPromotionsList(),
                    _buildMyCoupons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return NeumorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _walletAnimationController,
                builder: (context, child) => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TallerAlexColors.primaryFuchsia,
                        TallerAlexColors.primaryFuchsia.withOpacity(
                          0.8 + 0.2 * _walletAnimationController.value,
                        ),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wallet_giftcard,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cupones disponibles',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_availableCoupons.length} cupones listos para usar',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: TallerAlexColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _tabController.animateTo(1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: TallerAlexColors.primaryGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Ver todo',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableCoupons.take(3).length,
              itemBuilder: (context, index) {
                final coupon = _availableCoupons[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildMiniCouponCard(coupon),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCouponCard(Map<String, dynamic> coupon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TallerAlexColors.lightRose.withOpacity(0.3),
            TallerAlexColors.paleRose.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TallerAlexColors.primaryFuchsia.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coupon['title'],
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: TallerAlexColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                coupon['type'] == 'percentage'
                    ? '${coupon['discount']}% OFF'
                    : '\$${coupon['discount']} OFF',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: TallerAlexColors.primaryFuchsia,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Activo',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionsList() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _activePromotions.length,
        itemBuilder: (context, index) {
          final promotion = _activePromotions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildPromotionCard(promotion),
          );
        },
      ),
    );
  }

  Widget _buildPromotionCard(Map<String, dynamic> promotion) {
    final bool isExpiringSoon =
        promotion['validUntil'].difference(DateTime.now()).inDays < 7;

    return NeumorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con imagen y badge
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  gradient: TallerAlexColors.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(promotion['category']),
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              if (promotion['isNew'])
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'NUEVO',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (isExpiringSoon)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '¡Últimos días!',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y descuento
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        promotion['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TallerAlexColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: TallerAlexColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        promotion['type'] == 'percentage'
                            ? '${promotion['discount']}% OFF'
                            : '\$${promotion['discount']} OFF',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Descripción
                Text(
                  promotion['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TallerAlexColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TallerAlexColors.lightRose.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: TallerAlexColors.textLight,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Válido hasta: ${promotion['validUntil'].day}/${promotion['validUntil'].month}/${promotion['validUntil'].year}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: TallerAlexColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: TallerAlexColors.textLight,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Compra mínima: \$${promotion['minAmount'].toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: TallerAlexColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicButton(
                        onPressed: () => _showPromotionDetails(promotion),
                        child: Text(
                          'Ver detalles',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: TallerAlexColors.primaryFuchsia,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeumorphicButton(
                        onPressed: () => _addCouponToWallet(promotion),
                        backgroundColor: TallerAlexColors.primaryFuchsia,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Agregar cupón',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyCoupons() {
    if (_myCoupons.isEmpty) {
      return FadeIn(
        duration: const Duration(milliseconds: 800),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: TallerAlexColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.wallet_giftcard,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'No tienes cupones',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: TallerAlexColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explora las promociones disponibles y agrega cupones a tu wallet',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: TallerAlexColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                NeumorphicButton(
                  onPressed: () => _tabController.animateTo(0),
                  backgroundColor: TallerAlexColors.primaryFuchsia,
                  child: Text(
                    'Ver promociones',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _myCoupons.length,
        itemBuilder: (context, index) {
          final coupon = _myCoupons[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildCouponCard(coupon),
          );
        },
      ),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    final bool isActive = coupon['status'] == 'disponible' &&
        DateTime.now().isBefore(coupon['validUntil']);
    final bool isExpired = DateTime.now().isAfter(coupon['validUntil']);
    final bool isUsed = coupon['status'] == 'usado';

    return NeumorphicCard(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    TallerAlexColors.lightRose.withOpacity(0.3),
                    TallerAlexColors.paleRose.withOpacity(0.2),
                  ],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? TallerAlexColors.primaryGradient
                          : LinearGradient(
                              colors: [
                                TallerAlexColors.textLight,
                                TallerAlexColors.textLight.withOpacity(0.7),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_offer,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? TallerAlexColors.textPrimary
                                : TallerAlexColors.textLight,
                          ),
                        ),
                        Text(
                          coupon['id'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: TallerAlexColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCouponStatusColor(coupon['status'], isExpired)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCouponStatusText(coupon['status'], isExpired),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            _getCouponStatusColor(coupon['status'], isExpired),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Descuento
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Descuento: ',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: TallerAlexColors.textSecondary,
                      ),
                    ),
                    Text(
                      coupon['type'] == 'percentage'
                          ? '${coupon['discount']}% OFF'
                          : '\$${coupon['discount']} OFF',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? TallerAlexColors.primaryFuchsia
                            : TallerAlexColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Fechas
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: TallerAlexColors.textLight,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Válido hasta: ${coupon['validUntil'].day}/${coupon['validUntil'].month}/${coupon['validUntil'].year}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: TallerAlexColors.textSecondary,
                    ),
                  ),
                ],
              ),

              if (isUsed && coupon['usedDate'] != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Usado el: ${coupon['usedDate'].day}/${coupon['usedDate'].month}/${coupon['usedDate'].year}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],

              if (isActive) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicButton(
                        onPressed: () => _useCoupon(coupon),
                        backgroundColor: TallerAlexColors.primaryFuchsia,
                        child: Text(
                          'Usar cupón',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    NeumorphicButton(
                      onPressed: () => _shareCoupon(coupon),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.share,
                        color: TallerAlexColors.primaryFuchsia,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'mantenimiento':
        return Icons.build;
      case 'afinacion':
        return Icons.tune;
      case 'diagnostico':
        return Icons.search;
      default:
        return Icons.local_offer;
    }
  }

  Color _getCouponStatusColor(String status, bool isExpired) {
    if (isExpired) return Colors.red;
    switch (status) {
      case 'disponible':
        return Colors.green;
      case 'usado':
        return Colors.blue;
      default:
        return TallerAlexColors.textLight;
    }
  }

  String _getCouponStatusText(String status, bool isExpired) {
    if (isExpired) return 'Vencido';
    switch (status) {
      case 'disponible':
        return 'Disponible';
      case 'usado':
        return 'Usado';
      default:
        return 'Inactivo';
    }
  }

  void _showPromotionDetails(Map<String, dynamic> promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TallerAlexColors.neumorphicBackground,
              TallerAlexColors.paleRose.withOpacity(0.1),
              TallerAlexColors.neumorphicBackground,
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      promotion['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: TallerAlexColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: TallerAlexColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Descripción
              Text(
                promotion['description'],
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: TallerAlexColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Términos y condiciones
              Text(
                'Términos y condiciones:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TallerAlexColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              ...promotion['terms'].map<Widget>((term) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: TallerAlexColors.primaryFuchsia,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            term,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: TallerAlexColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              const Spacer(),

              // Botón para agregar
              NeumorphicButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _addCouponToWallet(promotion);
                },
                backgroundColor: TallerAlexColors.primaryFuchsia,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Agregar cupón a mi wallet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  void _addCouponToWallet(Map<String, dynamic> promotion) {
    // Verificar si ya tiene un cupón de esta promoción
    final hasCoupon = _myCoupons.any((coupon) =>
        coupon['promoId'] == promotion['id'] &&
        coupon['status'] == 'disponible');

    if (hasCoupon) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ya tienes un cupón de esta promoción'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '¡Cupón agregado!',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: TallerAlexColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'El cupón "${promotion['title']}" se ha agregado a tu wallet exitosamente.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: TallerAlexColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          NeumorphicButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: TallerAlexColors.primaryFuchsia,
              ),
            ),
          ),
          NeumorphicButton(
            onPressed: () {
              Navigator.of(context).pop();
              _tabController.animateTo(1);
            },
            backgroundColor: TallerAlexColors.primaryFuchsia,
            child: Text(
              'Ver wallet',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _useCoupon(Map<String, dynamic> coupon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TallerAlexColors.neumorphicBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Usar cupón',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: TallerAlexColors.textPrimary,
          ),
        ),
        content: Text(
          '¿Deseas usar este cupón ahora? Se aplicará automáticamente en tu próxima cita.',
          style: GoogleFonts.poppins(
            color: TallerAlexColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                color: TallerAlexColors.textSecondary,
              ),
            ),
          ),
          NeumorphicButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/agendar-cita');
            },
            backgroundColor: TallerAlexColors.primaryFuchsia,
            child: Text(
              'Agendar cita',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareCoupon(Map<String, dynamic> coupon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Compartiendo cupón "${coupon['title']}"...'),
        action: SnackBarAction(
          label: 'Copiar código',
          onPressed: () {
            // TODO: Copiar al portapapeles
          },
        ),
      ),
    );
  }
}
