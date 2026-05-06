import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/utils/local_strings.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/prices/presentation/prices_cubit.dart';
import 'package:truce/features/settings/presentation/settings_cubit.dart';

class MarketRatesPage extends StatelessWidget {
  const MarketRatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalStrings.get('market_rates', locale)),
        leading: const BackButton(),
      ),
      body: BlocBuilder<PricesCubit, PricesState>(
        builder: (context, state) {
          if (state is PricesLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(LocalStrings.get('currency_rates', locale), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...state.currencyRates.map((c) => _buildRateCard('${c.code}/EGP', c.rateToEgp.toString(), Icons.currency_exchange)),
                const SizedBox(height: 24),
                Text(LocalStrings.get('gold_prices', locale), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...state.goldPrices.map((g) => _buildRateCard('${LocalStrings.get('gold', locale)} ${g.carat}', '${g.sell} EGP', Icons.brightness_high)),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildRateCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: TruceTheme.accentGreen),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TruceTheme.accentGreen)),
      ),
    );
  }
}
