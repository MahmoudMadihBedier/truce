import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/di/injection.dart';
import 'package:truce/features/coupons/presentation/cubit/coupons_cubit.dart';

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CouponsCubit(sl())..loadCoupons(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coupons & Discounts'),
        ),
        body: BlocBuilder<CouponsCubit, CouponsState>(
          builder: (context, state) {
            if (state is CouponsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CouponsError) {
              return Center(child: Text(state.message));
            } else if (state is CouponsLoaded) {
              if (state.coupons.isEmpty) {
                return const Center(child: Text('No coupons available at the moment.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.coupons.length,
                itemBuilder: (context, index) {
                  final coupon = state.coupons[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                coupon.storeName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Active',
                                  style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(coupon.description, style: Theme.of(context).textTheme.bodyLarge),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    coupon.code,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: coupon.code));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Coupon code copied!')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (coupon.expiresAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Expires: ${coupon.expiresAt!.toLocal().toString().split(' ')[0]}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
