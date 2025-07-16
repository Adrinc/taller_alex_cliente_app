import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nethive_neo/providers/nethive/empresas_negocios_provider.dart';
import 'package:nethive_neo/pages/empresa_negocios/widgets/empresa_selector_sidebar.dart';
import 'package:nethive_neo/pages/empresa_negocios/widgets/negocios_table.dart';
import 'package:nethive_neo/theme/theme.dart';

class EmpresaNegociosPage extends StatefulWidget {
  const EmpresaNegociosPage({Key? key}) : super(key: key);

  @override
  State<EmpresaNegociosPage> createState() => _EmpresaNegociosPageState();
}

class _EmpresaNegociosPageState extends State<EmpresaNegociosPage> {
  bool showMapView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Consumer<EmpresasNegociosProvider>(
        builder: (context, provider, child) {
          return Row(
            children: [
              // Sidebar izquierdo con empresas
              SizedBox(
                width: 300,
                child: EmpresaSelectorSidebar(
                  provider: provider,
                  onEmpresaSelected: (empresaId) {
                    provider.setEmpresaSeleccionada(empresaId);
                  },
                ),
              ),

              // Área principal
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con título y switch
                      _buildHeader(provider),

                      const SizedBox(height: 16),

                      // Contenido principal (tabla o mapa)
                      Expanded(
                        child: showMapView
                            ? _buildMapView()
                            : _buildTableView(provider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(EmpresasNegociosProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.empresaSeleccionada != null
                      ? 'Sucursales de ${provider.empresaSeleccionada!.nombre}'
                      : 'Selecciona una empresa para ver sus sucursales',
                  style: TextStyle(
                    color: AppTheme.of(context).primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (provider.empresaSeleccionada != null)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${provider.negocios.length} sucursales',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        provider.empresaSeleccionada!.nombre,
                        style: TextStyle(
                          color: AppTheme.of(context).secondaryText,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Switch para cambiar vista
          Column(
            children: [
              Text(
                'Vista de Mapa',
                style: TextStyle(
                  color: AppTheme.of(context).primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Switch(
                value: showMapView,
                onChanged: (value) {
                  setState(() {
                    showMapView = value;
                  });
                },
                activeColor: AppTheme.of(context).primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(EmpresasNegociosProvider provider) {
    if (provider.empresaSeleccionada == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business,
              size: 80,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'Selecciona una empresa para ver sus sucursales',
              style: TextStyle(
                color: AppTheme.of(context).secondaryText,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header de la tabla
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sucursales',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Mostrando 1 a ${provider.negocios.length} de ${provider.negocios.length} sucursales',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Tabla de negocios
          Expanded(
            child: NegociosTable(provider: provider),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 80,
              color: Colors.blue[700],
            ),
            const SizedBox(height: 16),
            Text(
              'Vista de Mapa',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Próximamente se implementará el mapa con las ubicaciones de las sucursales',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
