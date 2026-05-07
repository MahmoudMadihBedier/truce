import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/di/injection.dart';
import 'package:truce/core/utils/shimmer_loader.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/coupons/presentation/cubit/coupons_cubit.dart';

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CouponsCubit>()..loadCoupons(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Exclusive Coupons | كوبونات حصرية'),
        ),
        body: BlocBuilder<CouponsCubit, CouponsState>(
          builder: (context, state) {
            if (state is CouponsLoading) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: ShimmerLoader(width: double.infinity, height: 100, borderRadius: 12),
                ),
              );
            } else if (state is CouponsLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.coupons.length,
                itemBuilder: (context, index) {
                  final coupon = state.coupons[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TruceTheme.accentGreen.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: TruceTheme.accentGreen.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coupon.storeName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(coupon.description, style: TextStyle(color: Colors.grey[700])),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: TruceTheme.accentGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                coupon.code,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('COPY CODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: TruceTheme.accentGreen)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is CouponsError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
