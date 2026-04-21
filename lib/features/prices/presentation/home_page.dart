import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/features/prices/presentation/prices_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Truce Egypt Dashboard')),
      body: BlocBuilder<PricesCubit, PricesState>(
        builder: (context, state) {
          if (state is PricesInitial) {
            context.read<PricesCubit>().loadDashboard();
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PricesLoading) return const Center(child: CircularProgressIndicator());
          if (state is PricesError) return Center(child: Text(state.message));
          if (state is PricesLoaded) {
            return ListView(
              children: [
                _buildGoldTicker(state.goldPrices),
                _buildCurrencyTicker(state.currencyRates),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Recent Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                ...state.products.map((p) => ListTile(
                  title: Text('${p.nameEn} | ${p.nameAr}'),
                  subtitle: Text('Lowest: EGP ${p.prices.isNotEmpty ? p.prices.first.price : "N/A"}'),
                )),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildGoldTicker(List<dynamic> prices) {
    return Container(
      height: 50,
      color: Colors.amber[100],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: prices.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${prices[i].carat}: ${prices[i].sell} EGP'),
        ),
      ),
    );
  }

  Widget _buildCurrencyTicker(List<dynamic> rates) {
    return Container(
      height: 50,
      color: Colors.blue[100],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: rates.length,
        itemBuilder: (context, i) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('${rates[i].code}: ${rates[i].rateToEgp} EGP'),
        ),
      ),
    );
  }
}
